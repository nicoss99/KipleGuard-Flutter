# Restores Flutter run configs when Android Studio replaces staging_debug.xml
# with a broken _template__of_Flutter.xml. Run from repo root:
#   powershell -ExecutionPolicy Bypass -File scripts/repair_android_studio_run_configs.ps1

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$runDir = Join-Path $root '.idea\runConfigurations'
$template = Join-Path $runDir '_template__of_Flutter.xml'

if (Test-Path $template) {
    Remove-Item $template -Force
    Write-Host "Removed $template"
}

$stagingDebug = Join-Path $runDir 'staging_debug.xml'
@'
<component name="ProjectRunConfigurationManager">
  <configuration default="true" name="staging_debug" type="FlutterRunConfigurationType" factoryName="Flutter">
    <option name="additionalArgs" value="--dart-define=API_ENV=dev" />
    <option name="buildFlavor" value="dev" />
    <option name="filePath" value="$PROJECT_DIR$/lib/main_dev.dart" />
    <method v="2" />
  </configuration>
</component>
'@ | Set-Content -Path $stagingDebug -Encoding UTF8

Write-Host "Wrote $stagingDebug"
Write-Host "Restart Android Studio. Select run config: staging_debug"
