param([switch]$SkipSync)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$configPath = Join-Path $projectRoot '.cache\android-toolchain.json'
$localToolchain = if (Test-Path -LiteralPath $configPath) { Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json } else { $null }

function Find-ToolEnvironment([string]$Name, [string]$LocalValue) {
    $value = [Environment]::GetEnvironmentVariable($Name, 'Process')
    if (!$value) { $value = [Environment]::GetEnvironmentVariable($Name, 'User') }
    if (!$value) { $value = $LocalValue }
    return $value
}

$env:JAVA_HOME = Find-ToolEnvironment 'JAVA_HOME' $localToolchain.javaHome
$env:ANDROID_HOME = Find-ToolEnvironment 'ANDROID_HOME' $localToolchain.sdkRoot
$env:GRADLE_USER_HOME = Find-ToolEnvironment 'GRADLE_USER_HOME' $localToolchain.gradleUserHome
$env:ANDROID_USER_HOME = Find-ToolEnvironment 'ANDROID_USER_HOME' $localToolchain.androidUserHome
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME

if (!$env:JAVA_HOME -or !(Test-Path -LiteralPath (Join-Path $env:JAVA_HOME 'bin\javac.exe'))) {
    throw 'JDK 21 is required. Set JAVA_HOME to an installed JDK 21 directory.'
}
if (!$env:ANDROID_HOME -or !(Test-Path -LiteralPath (Join-Path $env:ANDROID_HOME 'platforms\android-36\android.jar'))) {
    throw 'Android SDK Platform 36 is required. Set ANDROID_HOME to the SDK directory.'
}
$apksigner = Join-Path $env:ANDROID_HOME 'build-tools\35.0.0\apksigner.bat'
if (!(Test-Path -LiteralPath $apksigner)) { throw 'Android SDK Build Tools 35.0.0 are required.' }
$env:Path = "$($env:JAVA_HOME)\bin;$env:Path"
if ($env:GRADLE_USER_HOME) {
    $buildTemp = Join-Path $env:GRADLE_USER_HOME 'tmp'
    New-Item -ItemType Directory -Path $buildTemp -Force | Out-Null
    $env:TEMP = $buildTemp
    $env:TMP = $buildTemp
    $env:JAVA_OPTS = "$($env:JAVA_OPTS) -Djava.io.tmpdir=`"$buildTemp`""
}

Push-Location $projectRoot
try {
    if (!$SkipSync) {
        & npm.cmd run android:sync
        if ($LASTEXITCODE -ne 0) { throw 'Nuxt build or Capacitor sync failed.' }
    }
    $sdkProperty = 'sdk.dir=' + $env:ANDROID_HOME.Replace('\', '/')
    $sdkProperty | Set-Content -LiteralPath (Join-Path $projectRoot 'android\local.properties') -Encoding ascii

    $gradleArguments = @('assembleDebug', '--no-daemon', '--max-workers=2', '--console=plain')
    $cdnInit = Join-Path $projectRoot '.cache\google-cdn.init.gradle'
    if (Test-Path -LiteralPath $cdnInit) { $gradleArguments += @('--init-script', $cdnInit) }
    Push-Location (Join-Path $projectRoot 'android')
    try {
        & '.\gradlew.bat' @gradleArguments
        if ($LASTEXITCODE -ne 0) { throw 'Android Gradle build failed.' }
    }
    finally { Pop-Location }

    $builtApk = Join-Path $projectRoot 'android\app\build\outputs\apk\debug\app-debug.apk'
    & $apksigner verify --verbose $builtApk
    if ($LASTEXITCODE -ne 0) { throw 'APK signature verification failed.' }
    $artifactRoot = Join-Path $projectRoot 'artifacts\android'
    New-Item -ItemType Directory -Path $artifactRoot -Force | Out-Null
    $outputApk = Join-Path $artifactRoot 'nuxt-capacitor-debug.apk'
    Copy-Item -LiteralPath $builtApk -Destination $outputApk -Force
    Write-Output "APK: $outputApk"
    Get-FileHash -LiteralPath $outputApk -Algorithm SHA256 | Format-List
}
finally { Pop-Location }
