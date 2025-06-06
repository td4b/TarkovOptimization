# === BANNER ===
Write-Host @'
  ______ ______ _______    ____        _   _           _              
 |  ____|  ____|__   __|  / __ \      | | (_)         (_)             
 | |__  | |__     | |    | |  | |_ __ | |_ _ _ __ ___  _ _______ _ __ 
 |  __| |  __|    | |    | |  | | '_ \| __| | '_ ` _ \| |_  / _ \ '__|
 | |____| |       | |    | |__| | |_) | |_| | | | | | | |/ /  __/ |   
 |______|_|       |_|     \____/| .__/ \__|_|_| |_| |_|_/___\___|_|   
                                | |                                   
                                |_|                                                                   
'@ -ForegroundColor Green

# === CONFIGURATION ===
$BSGLauncherPath = "C:\Battlestate Games\BsgLauncher\BsgLauncher.exe"
$TarkovProcessName = "EscapeFromTarkov.exe"
$PowerSchemeGUID = "e9a42b02-d5df-448d-aa00-03f14749eb61"
$EmptyStandbyTool = "C:\Tools\EmptyStandbyList.exe"
$GraphicsIniPath = "C:\Users\edwin\AppData\Roaming\Battlestate Games\Escape from Tarkov\Settings\Graphics.ini"
$GameIniPath = "C:\Users\edwin\AppData\Roaming\Battlestate Games\Escape from Tarkov\Settings\Game.ini"
$PostFxPath = "C:\Users\edwin\AppData\Roaming\Battlestate Games\Escape from Tarkov\Settings\PostFx.ini"

Write-Host "[*] Using High Performance power plan (Ultimate not supported)..." -ForegroundColor Green
powercfg /setactive SCHEME_MIN

# === Write graphics.ini with optimized settings ===
Write-Host "[*] Applying optimized Graphics.ini settings..." -ForegroundColor Green
$graphicsSettings = @'
{
  "Version": 5,
  "Stored": [
    {
      "Index": 0,
      "FullScreenResolution": {
        "Width": 2560,
        "Height": 1440
      },
      "FullScreenAspectRatio": {
        "X": 16,
        "Y": 9
      },
      "WindowResolution": {
        "Width": 2544,
        "Height": 1353
      },
      "WindowAspectRatio": {
        "X": 19,
        "Y": 10
      }
    }
  ],
  "DisplaySettings": {
    "Display": 0,
    "FullScreenMode": 0,
    "Resolution": {
      "Width": 2560,
      "Height": 1440
    },
    "AspectRatio": {
      "X": 16,
      "Y": 9
    }
  },
  "GraphicsQuality": null,
  "ShadowsQuality": 0,
  "TextureQuality": 2,
  "CloudsQuality": "Low",
  "SDMode": null,
  "VSync": false,
  "LobbyFramerate": 60,
  "GameFramerate": 165,
  "DisableGameFramerateLimit": false,
  "SuperSampling": "Off",
  "AnisotropicFiltering": "Enable",
  "OverallVisibility": 1000.0,
  "LodBias": 2.0,
  "MipStreamingBufferSize": 32,
  "MipStreamingIOCount": 768,
  "Ssao": "FastestPerformance",
  "Sharpen": 0.6,
  "SSR": "Medium",
  "AntiAliasing": "TAA_High",
  "NVidiaReflex": "OnAndBoost",
  "HighQualityFog": false,
  "GrassShadow": false,
  "ChromaticAberrations": false,
  "Noise": false,
  "ZBlur": false,
  "HighQualityColor": true,
  "MipStreaming": false,
  "SdTarkovStreets": false,
  "VolumetricLight": true,
  "DLSSMode": "Quality",
  "FSR2Mode": "Off",
  "FSR3Mode": "Off",
  "DLSSPreset": "B",
  "InApplyDisplaySettingsProcess": false,
  "DLSSEnabled": true,
  "FSR2Enabled": false,
  "FSR3Enabled": false,
  "ShadowDistance": 30.0,
  "SuperSamplingFactor": 1.0
}
'@
$graphicsSettings | Set-Content -Path $GraphicsIniPath -Encoding UTF8

# === Enforce SetAffinityToLogicalCores = false in Game.ini ===
if (Test-Path $GameIniPath) {
    try {
        $gameConfig = Get-Content $GameIniPath -Raw | ConvertFrom-Json
        $gameConfig.SetAffinityToLogicalCores = $false
        $gameConfig.HeadBobbing = 0.2
        $gameConfig.FieldOfView = 56
        $gameConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $GameIniPath -Encoding UTF8
        Write-Host "[*] SetAffinityToLogicalCores set to false in Game.ini." -ForegroundColor Green
    } catch {
        Write-Host "[!] Failed to modify Game.ini: $_" -ForegroundColor Green
    }
} else {
    Write-Host "[!] Game.ini not found at $GameIniPath" -ForegroundColor Green
}

# === Apply PostFx.ini settings ===
Write-Host "[*] Applying PostFx settings..." -ForegroundColor Green
$postFxSettings = @'
{
  "EnablePostFx": true,
  "Brightness": 75,
  "Saturation": 42,
  "Clarity": 31,
  "Colorfulness": 54,
  "LumaSharpen": 61,
  "AdaptiveSharpen": 83,
  "ColorFilterType": "Stefano",
  "Intensity": 30,
  "ColorBlindnessType": "None",
  "ColorBlindnessIntensity": 3
}
'@
try {
    $postFxSettings | Set-Content -Path $PostFxPath -Encoding UTF8
    Write-Host "[*] PostFx.ini updated successfully." -ForegroundColor Green
} catch {
    Write-Host "[!] Failed to write PostFx.ini: $_" -ForegroundColor Green
}

# === Start BSG Launcher ===
Write-Host "[*] Launching BSG Launcher..." -ForegroundColor Green
Start-Process -FilePath $BSGLauncherPath

# === Clear standby memory ===
if (Test-Path $EmptyStandbyTool) {
    Write-Host "[*] Clearing Standby Memory List..." -ForegroundColor Green
    Start-Process -FilePath $EmptyStandbyTool -ArgumentList "workingsets" -Wait
} else {
    Write-Host "[!] EmptyStandbyList.exe not found at $EmptyStandbyTool" -ForegroundColor Green
}

# === Wait for Tarkov to launch ===
Write-Host "[*] Waiting for EscapeFromTarkov.exe to start..." -ForegroundColor Green
do {
    Start-Sleep -Seconds 1
    $tarkovProc = Get-Process -Name ($TarkovProcessName -replace ".exe","") -ErrorAction SilentlyContinue
} while (-not $tarkovProc)

# === Set process priority to High ===
Write-Host "[*] Setting process priority to High..." -ForegroundColor Green
try {
    $tarkovProc.PriorityClass = 'High'
} catch {
    Write-Host "[!] Failed to set process priority: $_" -ForegroundColor Green
}

# === Set I/O priority to High (WMIC call) ===
Write-Host "[*] Setting I/O priority to High..." -ForegroundColor Green
Start-Process wmic -ArgumentList "process where name='$TarkovProcessName' CALL setiolevel 3" -Wait -WindowStyle Hidden

# === Close the BSG Launcher ===
Write-Host "[*] Closing BSG Launcher..." -ForegroundColor Green
Stop-Process -Name "BsgLauncher" -Force -ErrorAction SilentlyContinue

Write-Host "[*] Done. Raid smart. Help out Timmy's." -ForegroundColor Green

# === Countdown before closing ===
for ($i = 5; $i -ge 1; $i--) {
    Write-Host "Closing in $i seconds..." -ForegroundColor Green -NoNewline
    Start-Sleep -Seconds 1
    Write-Host "`r" + (" " * 30) + "`r" -NoNewline
}
