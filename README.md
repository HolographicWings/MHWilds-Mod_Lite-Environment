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

## Compatibility:
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

The goal is to allow other mods to know if your is loaded, on the purpose of adapting the behavior of our mods in the case some conflicts happens.
To check if another mod exists:
```
﻿if _G["ModID"] then
    -- Mod found
else
    -- Mod not found
end
```
If a mod use the advanced method, "`_G["ModID"].version`" or "`.settings`" could be used by exemple.

---  

## Credits:  
- **REFramework:** [Praydog](https://github.com/praydog)
- **GI Disabler:** [SnakeyHips](https://www.nexusmods.com/monsterhunterwilds/mods/331)
- **Volumetric Fog Disabler:** [TonWonton](https://www.nexusmods.com/monsterhunterwilds/mods/221)
- **The Wrench&Gear image on the banner of the mod:** [www.flaticon.com](https://www.flaticon.com/kr/free-icon/repair_9759793)
- **The Cutout 1080 Ti image on the banner of the mod:** [www.notebookcheck.com](https://www.notebookcheck.com/NVIDIA-GeForce-GTX-1080-Ti-Desktop.199808.0.html)
