-- Settings table
local settings =
{
	wind_simulation = false, -- Disabled by default
	global_illumination = true, -- Enabled by default
	volumetric_fog = true, -- Enabled by default
	cutscene_restore_GI = true, -- Enabled by default
	cutscene_restore_VF = true -- Enabled by default
}

-- Mod header
local mod = {
	name = "Lite Environment",
	id = "LiteEnvironmentMod",
	version = "2.1.1",
	author = "HolographicWings",
	settings = settings
}
_G[mod.id] = mod -- Globalize mod header

log.info(string.format("%s v%s is loading", mod.name, mod.version))

local scripts_loaded = false
local config_path = "lite_environment.json" -- Stored in \MonsterHunterWilds\reframework\data
local wind_manager, environment_manager, graphics_manager

-- Watchdog (Anti infinite loop security)
local start_time = os.clock()
local wd_time = 10.0 -- Timeout duration

-- Compatibility measures fields
local DPPE_CM = false -- Boolean for "Disable Post Processing Effects" mod from TonWonton

-- Write to the configuration file
local function save_config()
	json.dump_file(config_path, settings)
end

-- Read the configuration file
local function load_config()
	local loadedTable = json.load_file(config_path)
	if type(loadedTable) == "table" then
		for key, val in pairs(settings) do
			if loadedTable[key] ~= nil then
				settings[key] = loadedTable[key]
			end
		end
	else
		log.warn(string.format("[%s] Failed to load config file. Regenerating with default settings.", mod.name))
		save_config()
	end
end

-- Apply the wind simulation setting
local function apply_ws_setting()
	if not wind_manager then return end
	
	local wind_manager_base = sdk.to_managed_object(wind_manager):call("get_Instance")
	
	if wind_manager_base then
		wind_manager_base:set_field("_Stop", not settings.wind_simulation) -- Enable or disable wind simulation
	end
end

-- Apply the global illumination setting
local function apply_gi_setting(overwrite)
	if not environment_manager then return end

	local dpgi_component = environment_manager:call("get_DPGIComponent")

	if dpgi_component then
		if overwrite == true then
			dpgi_component:call("set_Enabled", true) -- Force ON
		else
			dpgi_component:call("set_Enabled", settings.global_illumination) -- Enable or disable global illumination
		end
	end
end

-- Apply the volumetric fog setting
local function apply_vf_setting(overwrite)
	if not graphics_manager then return end
	if DPPE_CM then return end -- Disable VF control if "Disable Post Processing Effects" mod is present
	local graphics_setting = graphics_manager:call("get_NowGraphicsSetting")

	if graphics_setting then
		if overwrite == true then
			graphics_setting:call("set_VolumetricFogControl_Enable", true) -- Force ON
		else
			graphics_setting:call("set_VolumetricFogControl_Enable", settings.volumetric_fog) -- Enable or disable volumetric fog
		end
		graphics_manager:call("setGraphicsSetting", graphics_setting) -- Apply setting change
	end
end

local function on_loaded()
	-- Finding RE Managed singletons
	wind_manager = sdk.get_managed_singleton("app.WindManager")
	environment_manager = sdk.get_managed_singleton("app.EnvironmentManager")
	graphics_manager = sdk.get_managed_singleton("app.GraphicsManager")
	demo_mediator = sdk.get_managed_singleton("app.DemoMediator")
	
	if not (wind_manager and environment_manager and graphics_manager) then -- Ensure to retry if the script loaded before the game
		if os.clock() - start_time < wd_time then -- Watchdog (Anti infinite loop security)
			return -- Retry next frame
		else
			log.warn(string.format("[%s] One or several managers not found after %.0f seconds. Continuing anyway (some features may not work).", mod.name, wd_time)) -- Continue anyway
		end
	end

	DPPE_CM = _G["DisablePostProcessingEffects"] ~= nil -- Define true or false depending of if the mod is found
	
	load_config() -- Load the configuration file on startup
	apply_ws_setting() -- Apply wind simulation setting immediately after loading config
	apply_gi_setting() -- Apply global illumination setting immediately after loading config
	apply_vf_setting() -- Apply volumetric fog setting immediately after loading config
	
	scripts_loaded = true
	log.info(string.format("%s v%s is loaded", mod.name, mod.version))
end

-- Hook the Camera's onSceneLoadFadeIn method (to apply the Global Illumination setting after loadings)
sdk.hook(sdk.find_type_definition("app.CameraManager"):get_method("onSceneLoadFadeIn"), nil,
	apply_gi_setting
)

-- Cutscenes Workaround
local skip_softlist = {1,2,3,4,5,6,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,42,43,44,45,46,47,48,49,51,52,56,57,59,100,102,103,104,130,1001,1002,1003,1004,2013} -- List of cutscenes that might require to restore GI and VF
local skip_hardlist_GI = {10,11,19,28,29,37,38,44,103} -- List of cutscenes that where Global Illumination is MANDATORY
local skip_hardlist_VF= {11,17,20,27,29,130,2013} -- List of cutscenes that where Volumetric Fog is MANDATORY
local is_restored = false

-- Contains Util
local function contains(tab, val)
	for i = 1, #tab do
		if tab[i] == val then
			return true
		end
	end
	return false
end

sdk.hook(sdk.find_type_definition("app.DemoMediator"):get_method("onPlayStart"), function() -- Cutscene start

	if not demo_mediator then
		return sdk.PreHookResult.CALL_ORIGINAL
	end
	local current_event = demo_mediator:call("get_CurrentTimelineEventID") -- Get the cutscene's ID
	if not current_event then
		return sdk.PreHookResult.CALL_ORIGINAL
	end
	
	if contains(settings.cutscene_restore_GI and skip_softlist or skip_hardlist_GI, current_event) then -- Restore GI if "Restore Global Illumination during Cutscenes" setting is checked or if the cutscene is in hardlist
		print("Restore GI for the cutscene")
		apply_gi_setting(true)
		is_restored = true
	end
	
	if contains(settings.cutscene_restore_VF and skip_softlist or skip_hardlist_VF, current_event) then -- Restore GI if "Restore Volumetric Fog during Cutscenes" setting is checked or if the cutscene is in hardlist
		print("Restore VF for the cutscene")
		apply_vf_setting(true)
		is_restored = true
	end
		
	return sdk.PreHookResult.CALL_ORIGINAL
end, nil)
sdk.hook(sdk.find_type_definition("app.DemoMediator"):get_method("unload"), nil, function() -- Cutscene stop
	if is_restored == true then -- Avoid double execution, unload is always called twice
		print("Reapplied GI and VF settings")
		apply_gi_setting() -- Reverse the GI change after cutscene's end
		apply_vf_setting() -- Reverse the VF change after cutscene's end
		is_restored = false -- Avoid double execution
	end
	return sdk.PreHookResult.CALL_ORIGINAL
end)

-- REFramework UI rendering
local ui_node_title = string.format("%s v%s", mod.name, mod.version)
re.on_draw_ui(function()
	local ws_changed, gi_changed, vf_changed, crgi_changed, crvf_changed = false

	-- Create new REFramework UI Node
	if imgui.tree_node(ui_node_title) then
		ws_changed = imgui.checkbox("Disable Wind Simulation", not settings.wind_simulation) -- Add a checkbox to disable the Wind Simulation
		if imgui.is_item_hovered() then
			imgui.set_tooltip("Huge performance improvement.\n\nThe vegetation and tissues sway will not longer\ndepend of the wind intensity and direction.")
		end
		
		gi_changed = imgui.checkbox("Disable Global Illumination", not settings.global_illumination) -- Add a checkbox to disable the Global Illumination
		if imgui.is_item_hovered() then
			imgui.set_tooltip("Medium performance improvement.\n\nHighly deteriorate the visual quality.")
		end
		
		imgui.begin_disabled(DPPE_CM)
		vf_changed = imgui.checkbox(not DPPE_CM and "Disable Volumetric Fog" or "(Disabled for compatibility) Disable Volumetric Fog", not settings.volumetric_fog) -- Add a checkbox to disable the Volumetric Fog
		if imgui.is_item_hovered() then
			imgui.set_tooltip("Medium performance improvement.\n\nHighly deteriorate the visual quality.")
		end
		imgui.end_disabled()
		
		if imgui.collapsing_header("Cutscenes Settings") then
			imgui.indent(25)
			crgi_changed = imgui.checkbox("Restore GI during Cutscenes", settings.cutscene_restore_GI) -- Add a checkbox to Restore Global Illumination during Cutscenes
			if imgui.is_item_hovered() then
				imgui.set_tooltip("Enable again the Global Illumination during Cutscenes.")
			end
			
			crvf_changed = imgui.checkbox("Restore VF during Cutscenes", settings.cutscene_restore_VF) -- Add a checkbox to Restore Volumetric Fog during Cutscenes
			if imgui.is_item_hovered() then
				imgui.set_tooltip("Enable again the Disable Volumetric during Cutscenes.")
			end
		end
		
		-- On "Wind Simulation" toggled
		if ws_changed then
			settings.wind_simulation = not settings.wind_simulation
			apply_ws_setting()
			save_config()
		end
		-- On "Global Illumination" toggled
		if gi_changed then
			settings.global_illumination = not settings.global_illumination
			apply_gi_setting()
			save_config()
		end
		-- On "Volumetric Fog" toggled
		if vf_changed then
			settings.volumetric_fog = not settings.volumetric_fog
			apply_vf_setting()
			save_config()
		end
		
		-- On "Restore Global Illumination during Cutscenes" toggled
		if crgi_changed then
			settings.cutscene_restore_GI = not settings.cutscene_restore_GI
			save_config()
		end
		-- On "Restore Volumetric Fog during Cutscenes" toggled
		if crvf_changed then
			settings.cutscene_restore_VF = not settings.cutscene_restore_VF
			save_config()
		end

		imgui.tree_pop()
	end
end)

re.on_frame(function() -- "re.on_frame" begin to be invoked only once all the Scripts are loaded
	if not scripts_loaded then
		on_loaded()
	end
end)