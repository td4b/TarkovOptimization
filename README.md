# TarkovOptimization
Powershell script and Tools to optimize Tarkov (EFT)

This sets some basic settings for high end PC's to optimize FPS and performance, the script includes the standbylist cleaner .exe.

Move this to a location accessible for the scirpt. Options are located at the top of `tarkov.ps1`

Ensure these path's are all correct for your system.

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
