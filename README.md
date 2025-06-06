# TarkovOptimization
Powershell script and Tools to optimize Tarkov (EFT)

This sets some basic settings for high end PC's to optimize FPS and performance, the script includes the standbylist cleaner .exe.

Move this to a location accessible for the scirpt. Options are located at the top of `tarkov.ps1`

Ensure these path's are all correct for your system.

!!IMPORTANT!!

This pins your graphical settings and PostFX settings, if you want to change those you need to update the powershell script as that pins the settings in your game (preventing them from changing between game patches). 

Additionally I recommend enabling digital vibrance in nvidia control panel. I use 90% vibrance. 

Example:
```powershell
$BSGLauncherPath = "C:\Battlestate Games\BsgLauncher\BsgLauncher.exe"
$TarkovProcessName = "EscapeFromTarkov.exe"
$PowerSchemeGUID = "e9a42b02-d5df-448d-aa00-03f14749eb61"
$EmptyStandbyTool = "C:\Tools\EmptyStandbyList.exe"
$GraphicsIniPath = "C:\Users\edwin\AppData\Roaming\Battlestate Games\Escape from Tarkov\Settings\Graphics.ini"
$GameIniPath = "C:\Users\edwin\AppData\Roaming\Battlestate Games\Escape from Tarkov\Settings\Game.ini"
$PostFxPath = "C:\Users\edwin\AppData\Roaming\Battlestate Games\Escape from Tarkov\Settings\PostFx.ini"
```

Execute the script by opening a powershell window and running:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\Path\To\Your\Script.ps1"
```

This will star tarkov and ensure the affinity and I/O management is prioritized and additionally clean the standby list as well as set optimal graphic settings for frame-rate.

If you need to change visual settings, you can modify the Graphics.ini json here:
https://github.com/td4b/TarkovOptimization/blob/main/tarkov.ps1#L16-L90

Additionally game cpu core usage (virtual), head bobbing and field of view are pinned here:
https://github.com/td4b/TarkovOptimization/blob/main/tarkov.ps1#L98-L100
