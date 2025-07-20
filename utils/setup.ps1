$userDir = [Environment]::GetEnvironmentVariable("USERPROFILE")
$homeDir = [Environment]::GetEnvironmentVariable("HOME", "User")

if ([String]::isNullOrEmpty($homeDir)) {
    [Environment]::SetEnvironmentVariable("HOME", $userDir, "User")
    $homeDir = [Environment]::GetEnvironmentVariable("HOME", "User")
    echo "環境変数HOMEを${userDir}に設定しました。"
}

$scriptDir = Split-Path $MyInvocation.MyCommand.Path
Push-Location (Split-Path $scriptDir)
$sourceDir = (Resolve-Path "sources/emacs.d").Path
Pop-Location

$targetDir = "$homeDir\.emacs.d"

if (Test-Path $targetDir) {
    echo "既に ${targetDir} が存在します。"
    echo "削除した後、再度このスクリプトを実行してください。"
    exit
}

New-Item -Value $sourceDir -Path $targetDir -ItemType Junction
