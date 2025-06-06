# === CONFIGURATION ===
$BSGLauncherPath = "C:\Battlestate Games\BsgLauncher\BsgLauncher.exe"
$TarkovProcessName = "EscapeFromTarkov.exe"
$PowerSchemeGUID = "e9a42b02-d5df-448d-aa00-03f14749eb61"
$EmptyStandbyTool = "C:\Tools\EmptyStandbyList.exe"
$GraphicsIniPath = "C:\Users\edwin\AppData\Roaming\Battlestate Games\Escape from Tarkov\Settings\Graphics.ini"
$GameIniPath = "C:\Users\edwin\AppData\Roaming\Battlestate Games\Escape from Tarkov\Settings\Game.ini"
$PostFxPath = "C:\Users\edwin\AppData\Roaming\Battlestate Games\Escape from Tarkov\Settings\PostFx.ini"

Write-Host "[*] Using High Performance power plan (Ultimate not supported)..."
powercfg /setactive SCHEME_MIN

# === Write graphics.ini with optimized settings ===
Write-Host "[*] Applying optimized Graphics.ini settings..."
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
        "Width": 2560,
        "Height": 1440
      },
      "WindowAspectRatio": {
        "X": 16,
        "Y": 9
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
  "AnisotropicFiltering": "Disable",
  "OverallVisibility": 1000.0,
  "LodBias": 2.0,
  "MipStreamingBufferSize": 32,
  "MipStreamingIOCount": 768,
  "Ssao": "ColoredHighestQuality",
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
  "VolumetricLight": false,
  "DLSSMode": "Off",
  "FSR2Mode": "Off",
  "FSR3Mode": "Off",
  "DLSSPreset": "Default",
  "InApplyDisplaySettingsProcess": false,
  "DLSSEnabled": false,
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
        Write-Host "[*] SetAffinityToLogicalCores set to false in Game.ini."
    } catch {
        Write-Host "[!] Failed to modify Game.ini: $_"
    }
} else {
    Write-Host "[!] Game.ini not found at $GameIniPath"
}

# === Apply PostFx.ini settings ===
Write-Host "[*] Applying PostFx settings..."

$postFxSettings = @'
{
  "EnablePostFx": true,
  "Brightness": 6,
  "Saturation": 32,
  "Clarity": 82,
  "Colorfulness": 80,
  "LumaSharpen": 10,
  "AdaptiveSharpen": 3,
  "ColorFilterType": "Feather",
  "Intensity": 50,
  "ColorBlindnessType": "None",
  "ColorBlindnessIntensity": 0
}
'@

try {
    $postFxSettings | Set-Content -Path $PostFxPath -Encoding UTF8
    Write-Host "[*] PostFx.ini updated successfully."
} catch {
    Write-Host "[!] Failed to write PostFx.ini: $_"
}

# === Start BSG Launcher ===
Write-Host "[*] Launching BSG Launcher..."
Start-Process -FilePath $BSGLauncherPath

# === Clear standby memory ===
if (Test-Path $EmptyStandbyTool) {
    Write-Host "[*] Clearing Standby Memory List..."
    Start-Process -FilePath $EmptyStandbyTool -ArgumentList "workingsets" -Wait
} else {
    Write-Host "[!] EmptyStandbyList.exe not found at $EmptyStandbyTool"
}

# === Wait for Tarkov to launch ===
Write-Host "[*] Waiting for EscapeFromTarkov.exe to start..."
do {
    Start-Sleep -Seconds 1
    $tarkovProc = Get-Process -Name ($TarkovProcessName -replace ".exe","") -ErrorAction SilentlyContinue
} while (-not $tarkovProc)

# === Set process priority to High ===
Write-Host "[*] Setting process priority to High..."
try {
    $tarkovProc.PriorityClass = 'High'
} catch {
    Write-Host "[!] Failed to set process priority: $_"
}

# === Set I/O priority to High (WMIC call) ===
Write-Host "[*] Setting I/O priority to High..."
Start-Process wmic -ArgumentList "process where name='$TarkovProcessName' CALL setiolevel 3" -Wait -WindowStyle Hidden

# === Close the BSG Launcher ===
Write-Host "[*] Closing BSG Launcher..."
Stop-Process -Name "BsgLauncher" -Force -ErrorAction SilentlyContinue

Write-Host "[*] Done. Raid smart. Help out Timmy's."

# === Countdown before closing ===
for ($i = 5; $i -ge 1; $i--) {
    Write-Host "Closing in $i seconds..." -NoNewline
    Start-Sleep -Seconds 1
    Write-Host "`r" + (" " * 30) + "`r" -NoNewline  # Clear line for countdown refresh
}
