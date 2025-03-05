# Wind Simulation Disabler - Installation Guide  

## Description  
This mod **Disables the Wind Simulation** in *Monster Hunter Wilds*, which fixes heavy lags with Pascal GPUs.  
It also provides an in-game toggle via the **REFramework UI**.  

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
- Drop the content of the archive inside. *(The mod should follow the path "MonsterHunterWilds\reframework\autorun\wind_simulation_disabler.lua")*  

### Step 3: *(The hardest part)*  
- **Start Monster Hunter Wilds**.  

### Step 4: *(To disable/compare)*  
- **Open REFramework UI (Press `Insert` key by default).**  
- **Scroll down and navigate to "Script Generated UI" then to "Wind Simulation Disabler"**  
- **Toggle the "Enabled" checkbox.**  
  *The value will be saved and persists after restarting the game.*  

---  

## Videos:  

### Comparison:  
[![Comparison Video](https://img.youtube.com/vi/It6TIwB-5LI/0.jpg)](https://www.youtube.com/watch?v=It6TIwB-5LI)  

### Benchmark:  
[![Benchmark Video](https://img.youtube.com/vi/f0q7qkqJiHY/0.jpg)](https://www.youtube.com/watch?v=f0q7qkqJiHY)  

---  

## Uninstallation:  

- Delete the **wind_simulation_disabler.lua** file from:  
  `"MonsterHunterWilds\reframework\autorun\"`  
  *Or directly the* `"reframework"` *folder if it's the only mod you installed.*  
- *(Optional)* Delete the configuration file:  
  `"MonsterHunterWilds\reframework\data\wind_simulation_disabler.txt"`  

---  

## Troubleshooting:  

- **Mod not working?**  
  Ensure REFramework is installed and working.  
  Check that the script is in `"MonsterHunterWilds\reframework\autorun\"`.  

---  

## Credits:  
- **REFramework:** [Praydog](https://github.com/praydog)
- **The Wrench&Gear image on the banner of the mod:** [www.flaticon.com](https://www.flaticon.com/kr/free-icon/repair_9759793)
- **The Cutout 1080 Ti image on the banner of the mod:** [www.notebookcheck.com](https://www.notebookcheck.com/NVIDIA-GeForce-GTX-1080-Ti-Desktop.199808.0.html)
