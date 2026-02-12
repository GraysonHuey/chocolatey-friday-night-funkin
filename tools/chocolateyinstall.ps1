$ErrorActionPreference = 'Stop'

$packageName = $env:ChocolateyPackageName
$toolsDir    = Split-Path -Parent $MyInvocation.MyCommand.Definition
$installDir  = Join-Path $toolsDir 'app'

$tag = 'v0.8.1'

if ($IsWindows) {
  $file     = 'funkin-windows-64bit.zip'
  $url      = "https://github.com/FunkinCrew/Funkin/releases/download/$tag/$file"
  $checksum = 'e10a76587f086b804b255add5076bf0102e8ee037d656346a7bb63df9db94cef'
  $expectedExeRelative = 'Funkin.exe'
}
elseif ($IsLinux) {
  $file     = 'funkin-linux-64bit.zip'
  $url      = "https://github.com/FunkinCrew/Funkin/releases/download/$tag/$file"
  $checksum = 'e36d8276e37f2fe1fe32a07686b90ee2346e1a6c4cbd4b98a714f92bc374de89'
  $expectedExeRelative = 'Funkin'
}
else {
  throw "Unsupported OS. This package supports Windows and Linux only."
}

$zipPath = Join-Path $toolsDir $file

Get-ChocolateyWebFile `
  -PackageName $packageName `
  -FileFullPath $zipPath `
  -Url $url `
  -Checksum $checksum `
  -ChecksumType 'sha256'

if (Test-Path $installDir) { Remove-Item $installDir -Recurse -Force }
New-Item -ItemType Directory -Path $installDir | Out-Null

Get-ChocolateyUnzip -FileFullPath $zipPath -Destination $installDir

$exePath = Join-Path $installDir $expectedExeRelative
if (-not (Test-Path $exePath)) {
  throw "Expected executable not found: $exePath. The upstream zip layout may have changed."
}

if ($IsLinux) {
  & chmod +x $exePath | Out-Null
}

Install-BinFile -Name 'funkin' -Path $exePath
