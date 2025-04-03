-- Settings table
local settings =
{
	wind_simulation = false, -- Disabled by default
	global_illumination = true, -- Enabled by default
	volumetric_fog = true -- Enabled by default
}

-- Mod header
local mod = {
	name = "Lite Environment",
	id = "LiteEnvironmentMod",
	version = "2.0.3p",
	author = "HolographicWings",
	settings = settings
}
_G[mod.id] = mod -- Globalize mod header

log.info(string.format("%s v%s is loading", mod.name, mod.version))

local scripts_loaded = false
local config_path = "lite_environment.json" -- Stored in \MonsterHunterWilds\reframework\data
local wind_manager, environment_manager, graphics_manager

-- Watchdog (Anti loop security)
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
		log.warn(string.format("[%s]Failed to load config file or file is invalid. Regenerating with default settings.", mod.name))
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
local function apply_gi_setting()
	if not environment_manager then return end

	local dpgi_component = environment_manager:call("get_DPGIComponent")

	if dpgi_component then
		dpgi_component:call("set_Enabled", settings.global_illumination) -- Enable or disable global illumination
	end
end

-- Apply the volumetric fog setting
local function apply_vf_setting()
	if not graphics_manager then return end
	if DPPE_CM then return end -- Disable VF control if "Disable Post Processing Effects" mod is present
	local graphics_setting = graphics_manager:call("get_NowGraphicsSetting")

	if graphics_setting then
		graphics_setting:call("set_VolumetricFogControl_Enable", settings.volumetric_fog) -- Enable or disable volumetric fog
		graphics_manager:call("setGraphicsSetting", graphics_setting) -- Apply setting change
	end
end

local function on_loaded()
	-- Finding RE Managed singletons
	wind_manager = sdk.get_managed_singleton("app.WindManager")
	environment_manager = sdk.get_managed_singleton("app.EnvironmentManager")
	graphics_manager = sdk.get_managed_singleton("app.GraphicsManager")
	
	if not (wind_manager and environment_manager and graphics_manager) then
		if os.clock() - start_time < wd_time then -- Watchdog (Anti loop security)
			return -- Retry next frame
		else
			log.warn(string.format("[%s]One or several managers not found after %.0f seconds. Continuing anyway (some features may not work).", mod.name, wd_time)) -- Continue anyway
		end
	end -- Ensure to retry if the script loaded before the game

	DPPE_CM = _G["DisablePostProcessingEffects"] ~= nil -- Define true or false depending of if the mod is found
	
	load_config() -- Load the configuration file on startup
	apply_ws_setting() -- Apply wind simulation setting immediately after loading config
	apply_gi_setting() -- Apply global illumination setting immediately after loading config
	apply_vf_setting() -- Apply volumetric fog setting immediately after loading config
	
	scripts_loaded = true
	log.info(string.format("%s v%s is loaded", mod.name, mod.version))
end

-- Hook the Camera's onSceneLoadFadeIn method (to apply the Global Illumination setting after loadings)
sdk.hook(
	sdk.find_type_definition("app.CameraManager"):get_method("onSceneLoadFadeIn"),
	function() end,
	apply_gi_setting
)
-- (alternative hook in case the first one isn't enough)
-- Hook the Camera's onCut method (to apply the Global Illumination setting after cuts)
-- sdk.hook(
	-- sdk.find_type_definition("app.CameraManager"):get_method("onCut"),
	-- function() end,
	-- apply_gi_setting
-- )

-- REFramework UI rendering
local ui_node_title = string.format("%s v%s", mod.name, mod.version)
re.on_draw_ui(function()
	local ws_changed, gi_changed, vf_changed = false

	-- Create new REFramework UI Node
	if imgui.tree_node(ui_node_title) then
		ws_changed = imgui.checkbox("Disable Wind Simulation", not settings.wind_simulation) -- Add a checkbox to disable the wind simulation
		if imgui.is_item_hovered() then
			imgui.set_tooltip("Huge performance improvement.\n\nThe vegetation and tissues sway will not longer\ndepend of the wind intensity and direction.")
		end
		
		gi_changed = imgui.checkbox("Disable Global Illumination", not settings.global_illumination) -- Add a checkbox to disable the global illumination
		if imgui.is_item_hovered() then
			imgui.set_tooltip("Medium performance improvement.\n\nHighly deteriorate the visual quality.")
		end
		
		imgui.begin_disabled(DPPE_CM)
		vf_changed = imgui.checkbox(not DPPE_CM and "Disable Volumetric Fog" or "(Disabled for compatibility) Disable Volumetric Fog", not settings.volumetric_fog) -- Add a checkbox to disable the volumetric fog
		if imgui.is_item_hovered() then
			imgui.set_tooltip("Medium performance improvement.\n\nHighly deteriorate the visual quality.")
		end
		imgui.end_disabled()

		-- On wind simulation toggled
		if ws_changed then
			settings.wind_simulation = not settings.wind_simulation
			apply_ws_setting()
		end
		-- On global illumination toggled
		if gi_changed then
			settings.global_illumination = not settings.global_illumination
			apply_gi_setting()
		end
		-- On volumetric fog toggled
		if vf_changed then
			settings.volumetric_fog = not settings.volumetric_fog
			apply_vf_setting()
		end

		if ws_changed or gi_changed or vf_changed then
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