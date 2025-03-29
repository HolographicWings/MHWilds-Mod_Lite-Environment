# Lite Environment - Installation Guide  

## Description  
This mod **Disables the Wind Simulation, Global Illumination and Volumetric Fog** in *Monster Hunter Wilds*, which fix heavy lags with Old Gen GPUs.  
It also provides some in-game toggles via the **REFramework UI**.  

---  

## Installation requirements:  

- [**REFramework**](https://github.com/praydog/REFramework-nightly/releases). (Required)  
- A basic understanding of words. (placing files in the correct directory)  
- To not be offended by my jokes. (fully optional) *You surely have more braincells than me anyway.*  

---  

## Installation guide:  

### Step 1: (After installed [**REFramework**](https://github.com/praydog/REFramework-nightly/releases))  
- Download the mod's archive from the Releases tab. *(Anyway, it's not the first time you download something on github).*  

### Step 2:  
- Navigate to your *Monster Hunter Wilds* installation folder.  
  *Typically located at:*  
  `"C:\Program Files (x86)\Steam\steamapps\common\MonsterHunterWilds\"`  
- Drop the content of the archive inside. *(The mod should follow the path "MonsterHunterWilds\reframework\autorun\lite_environment.lua")*  

### Step 3: *(The hardest part)*  
- **Start Monster Hunter Wilds**.  

### Step 4: *(To disable GI and Fog/Compare)*  
- **Open REFramework UI (Press `Insert` key by default).**  
- **Scroll down and navigate to "Script Generated UI" then to "Lite Environment"**  
- **Toggle the checkboxes to enable or disable the settings.**  
  *The values will be saved and persists after restarting the game.*  

---  

## Medias:  

### Comparison ImgSlide (5 Pictures):  
[ImgSlide](https://imgsli.com/MzU3OTkw/1/2)  

### Comparison video:  
[![Comparison Video](https://img.youtube.com/vi/It6TIwB-5LI/0.jpg)](https://www.youtube.com/watch?v=It6TIwB-5LI)  

### Benchmark:  
[![Benchmark Video](https://img.youtube.com/vi/f0q7qkqJiHY/0.jpg)](https://www.youtube.com/watch?v=f0q7qkqJiHY)  

---  

## Compatibility:  

- [Disable Post Processing Effects by TonWonton](https://www.nexusmods.com/monsterhunterwilds/mods/221): ✅Compatible

---  

## Uninstallation:  

- Delete the **lite_environment.lua** file from:  
  `"MonsterHunterWilds\reframework\autorun\"`  
  *Or directly the* `"reframework"` *folder if it's the only mod you installed.*  
- *(Optional)* Delete the configuration file:  
  `"MonsterHunterWilds\reframework\data\lite_environment.json"`  

---  

## Troubleshooting:  

- **Mod not working?**  
  Ensure REFramework is installed and working.  
  Check that the script is in `"MonsterHunterWilds\reframework\autorun\"`.  

---  

## Compatibility convention:
### **ModID of this mod:** "*LiteEnvironmentMod*"

**In order of managing compatibility between REFramework scripts, i propose a convention using a mod header stored in a Global variable.**

To make it, you must add one of theses two things:

__Simple method:__ (Can be placed anywhere while it's ran once, but at the begining of the script is recommended)
```lua
﻿﻿_G["YourModID"] = true
```
__Advanced method:__ (Must be placed AFTER your settings table)
```lua
﻿﻿-- Mod header
local settings =
{
    --- Your settings here
}

﻿﻿-- Mod header
local mod = {
    name = "Your Mod Name",
    id = "YourModID",
    version = "1.0.0",
    author = "Your Name",
    settings = settings -- 
}
_G[mod.id] = mod -- Globalize mod header
```
Ofc replace "YourModID" by something else.



### **Checking if Another Script is Loaded:**

Due to the alphabetical load order of scripts, the only reliable way i found to check for other mods is to use this approach.

Steps to Ensure Proper Detection:
- Declare a boolean at the beginning of your script for every mod you want to check.
- Create an `on_loaded` function anywhere to handle actions once all scripts are loaded. (optional)
- Declare a `scripts_loaded` boolean combined with the `re.on_frame` callback at the end of the script.

Example:
At the Beginning of Your Script:
```lua
-- Settings table
local settings =
{
    -- Settings variables here
}
-- Mod header
local mod = {
    -- Header here
}
_G[mod.id] = mod -- Globalize mod header

-- Compatibility measures fields
local ExempleMod_Measure = false -- One boolean for each mod to check
```
Define the `on_loaded` Function: (Optional)
```lua
﻿local function on_loaded()
    -- Actions to take once all scripts are loaded
end
```
Check for Other Mods in the `on_frame` Callback:
```lua
﻿-- Compatibility measures & on_loaded calling
local scripts_loaded = false -- To ensure that "re.on_frame" is only called only once
re.on_frame(function()
    if not scripts_loaded then
        -- Check if the target mod is present
        ExempleMod_Measure = _G["TargetModID"] ~= nil -- Define true or false depending of if the mod is found (do that for every boolean you declared at the begining)
        
        -- Mark scripts as loaded and call on_loaded
        scripts_loaded = true
        on_loaded()
    end
end)
```
If a mod uses the advanced method, `_G["ModID"].version` or `.settings` could be used by exemple. (But only in a `re.on_frame`, `re.on_draw_ui` callbacks, `on_loaded` function or in an hooked method from the game)

---  

## Credits:  
- **REFramework:** [Praydog](https://github.com/praydog)
- **GI Disabler:** [SnakeyHips](https://www.nexusmods.com/monsterhunterwilds/mods/331)
- **Volumetric Fog Disabler:** [TonWonton](https://www.nexusmods.com/monsterhunterwilds/mods/221)
- **The Wrench&Gear image on the banner of the mod:** [www.flaticon.com](https://www.flaticon.com/kr/free-icon/repair_9759793)
- **The Cutout 1080 Ti image on the banner of the mod:** [www.notebookcheck.com](https://www.notebookcheck.com/NVIDIA-GeForce-GTX-1080-Ti-Desktop.199808.0.html)
