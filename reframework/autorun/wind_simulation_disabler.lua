local enabled = true -- Enabled by default
local config_path = "wind_simulation_disabler.txt" -- Stored in \MonsterHunterWilds\reframework\data

-- Write to the configuration file
local function save_config()
    local file = io.open(config_path, "w")
    if file then
        file:write(tostring(enabled)) -- Saved as text
        file:close()
    end
end

-- Read the configuration file
local function load_config()
    local file = io.open(config_path, "r")
    if file then
        local content = file:read("*all")
        enabled = content == "true" -- Text to boolean
        file:close()
    end
end

-- Apply the wind simulation setting
local function apply_wind_setting()
    local wind_manager = sdk.get_managed_singleton("app.WindManager")
    if wind_manager then
        local wind_manager_base = sdk.to_managed_object(wind_manager):call("get_Instance")
        if wind_manager_base then
            wind_manager_base:set_field("_Stop", enabled) -- Enable or disable wind simulation
        end
    end
end

load_config() -- Load the configuration file on startup
apply_wind_setting() -- Apply setting immediately after loading config

-- REFramework UI rendering
re.on_draw_ui(function()
    local changed = false

    if imgui.tree_node("Wind Simulation Disabler") then
        changed, enabled = imgui.checkbox("Enabled", enabled) -- Add a checkbox to disable the wind simulation
        
        if changed then
            apply_wind_setting()
            save_config()
        end

        imgui.tree_pop()
    end
end)