#Requires -Version 5
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Test-Has { param([Parameter(Mandatory)][string]$Name) [bool](Get-Command $Name -ErrorAction SilentlyContinue) }
if (-not (Test-Has -Name "ssh-keygen")) {
  throw "ssh-keygen not found. Please enable Windows OpenSSH Client (optional feature)."
}

function Get-Timestamp { Get-Date -Format "yyyyMMdd-HHmmss" }

function Invoke-SSHKeygen {
  param(
    [Parameter(Mandatory)][ValidateSet('rsa','ed25519')]$Type,
    [int]$Bits = 0,
    [int]$KdfRounds = 0,
    [Parameter(Mandatory)][string]$Comment,
    [Parameter(Mandatory)][string]$OutFile
  )
  $parts = @("ssh-keygen","-q","-t",$Type)
  if ($Type -eq 'rsa' -and $Bits -gt 0) { $parts += @("-b",$Bits) }
  if ($Type -eq 'ed25519' -and $KdfRounds -gt 0) { $parts += @("-a",$KdfRounds) }
  $parts += @("-N",'""',"-C","`"$Comment`"","-f","`"$OutFile`"")
  $cmd = ($parts -join ' ')
  $p = Start-Process -FilePath "cmd.exe" -ArgumentList "/c",$cmd -Wait -PassThru -NoNewWindow
  if ($p.ExitCode -ne 0) { throw "ssh-keygen failed (exit $($p.ExitCode))" }
}

# 语言选择
$LangId = "zh-CN"
Write-Host @"
Choose language / 选择语言 / 選擇語言 / Choisir la langue / Выбрать язык / انتخاب زبان / 言語を選択:
  1) English
  2) 简体中文
  3) 繁體中文
  4) Français
  5) Русский
  6) فارسی (ایرانی)
  7) 日本語
"@
$choice = Read-Host ">"
switch ($choice) {
  "1" { $LangId = "en" }
  "2" { $LangId = "zh-CN" }
  "3" { $LangId = "zh-TW" }
  "4" { $LangId = "fr" }
  "5" { $LangId = "ru" }
  "6" { $LangId = "fa" }
  "7" { $LangId = "ja" }
  default { $LangId = "zh-CN" }
}

switch ($LangId) {
 "en" {
  $T_MENU="1) Generate key`n2) Derive public key from private key`n3) Exit"
  $T_CHOICE="Choose an option: "
  $T_ALGO="Select algorithm:`n  1) RSA 2048`n  2) RSA 3072`n  3) RSA 4096`n  4) Ed25519"
  $T_INPUT="Input private key by:`n  1) Paste text`n  2) File path"
  $T_PASTE="Paste PRIVATE KEY (finish with an empty line), then press Enter twice:"
  $T_PATH="Enter file path: "
  $T_PRIV="--- PRIVATE KEY ---"
  $T_PUB="--- PUBLIC KEY ---"
  $T_ENTER="Press Enter to continue..."
  $T_DONE="Done."
  $T_INVALID="Invalid choice."
 }
 "zh-CN" {
  $T_MENU="1) 生成密钥`n2) 由私钥查询公钥`n3) 退出"
  $T_CHOICE="请选择："
  $T_ALGO="选择算法：`n  1) RSA 2048`n  2) RSA 3072`n  3) RSA 4096`n  4) Ed25519"
  $T_INPUT="选择私钥输入方式：`n  1) 粘贴文本`n  2) 文件路径"
  $T_PASTE="请粘贴【私钥】，以空行结束，然后连续按两次回车："
  $T_PATH="请输入文件路径："
  $T_PRIV="--- 私钥 ---"
  $T_PUB="--- 公钥 ---"
  $T_ENTER="回车继续……"
  $T_DONE="完成。"
  $T_INVALID="无效选择。"
 }
 "zh-TW" {
  $T_MENU="1) 產生金鑰`n2) 由私鑰查詢公鑰`n3) 離開"
  $T_CHOICE="請選擇："
  $T_ALGO="選擇演算法：`n  1) RSA 2048`n  2) RSA 3072`n  3) RSA 4096`n  4) Ed25519"
  $T_INPUT="選擇私鑰輸入方式：`n  1) 貼上文本`n  2) 檔案路徑"
  $T_PASTE="請貼上【私鑰】，以空行結束，然後連按兩次 Enter："
  $T_PATH="請輸入檔案路徑："
  $T_PRIV="--- 私鑰 ---"
  $T_PUB="--- 公鑰 ---"
  $T_ENTER="按 Enter 繼續……"
  $T_DONE="完成。"
  $T_INVALID="無效選擇。"
 }
 "fr" {
  $T_MENU="1) Générer une clé`n2) Obtenir la clé publique depuis la clé privée`n3) Quitter"
  $T_CHOICE="Votre choix : "
  $T_ALGO="Choisir l’algorithme :`n  1) RSA 2048`n  2) RSA 3072`n  3) RSA 4096`n  4) Ed25519"
  $T_INPUT="Saisir la clé privée par :`n  1) Coller le texte`n  2) Chemin de fichier"
  $T_PASTE="Collez la CLÉ PRIVÉE (terminez par une ligne vide), puis appuyez deux fois sur Entrée :"
  $T_PATH="Saisir le chemin du fichier : "
  $T_PRIV="--- CLÉ PRIVÉE ---"
  $T_PUB="--- CLÉ PUBLIQUE ---"
  $T_ENTER="Appuyez sur Entrée pour continuer…"
  $T_DONE="Terminé."
  $T_INVALID="Choix invalide."
 }
 "ru" {
  $T_MENU="1) Сгенерировать ключ`n2) Получить публичный ключ из приватного`n3) Выход"
  $T_CHOICE="Выберите действие: "
  $T_ALGO="Выберите алгоритм:`n  1) RSA 2048`n  2) RSA 3072`n  3) RSA 4096`n  4) Ed25519"
  $T_INPUT="Как ввести приватный ключ:`n  1) Вставить текст`n  2) Путь к файлу"
  $T_PASTE="Вставьте ПРИВАТНЫЙ КЛЮЧ (завершите пустой строкой), затем дважды Enter:"
  $T_PATH="Введите путь к файлу: "
  $T_PRIV="--- ПРИВАТНЫЙ КЛЮЧ ---"
  $T_PUB="--- ПУБЛИЧНЫЙ КЛЮЧ ---"
  $T_ENTER="Нажмите Enter для продолжения…"
  $T_DONE="Готово."
  $T_INVALID="Неверный выбор."
 }
 "fa" {
  $T_MENU="1) تولید کلید`n2) استخراج کلید عمومی از کلید خصوصی`n3) خروج"
  $T_CHOICE="گزینه را انتخاب کنید: "
  $T_ALGO="الگوریتم را انتخاب کنید:`n  1) RSA 2048`n  2) RSA 3072`n  3) RSA 4096`n  4) Ed25519"
  $T_INPUT="ورود کلید خصوصی به یکی از روش‌ها:`n  1) چسباندن متن`n  2) مسیر فایل"
  $T_PASTE="کلید خصوصی را بچسبانید (با یک خط خالی پایان دهید)، سپس دو بار Enter:"
  $T_PATH="مسیر فایل را وارد کنید: "
  $T_PRIV="--- کلید خصوصی ---"
  $T_PUB="--- کلید عمومی ---"
  $T_ENTER="برای ادامه Enter را بزنید…"
  $T_DONE="انجام شد."
  $T_INVALID="گزینه نامعتبر."
 }
 "ja" {
  $T_MENU="1) 鍵を生成`n2) 秘密鍵から公開鍵を取得`n3) 終了"
  $T_CHOICE="番号を選択してください: "
  $T_ALGO="アルゴリズム:`n  1) RSA 2048`n  2) RSA 3072`n  3) RSA 4096`n  4) Ed25519"
  $T_INPUT="秘密鍵の入力方法:`n  1) テキスト貼り付け`n  2) ファイルパス"
  $T_PASTE="【秘密鍵】を貼り付け、空行で終了後、Enter を 2 回押してください:"
  $T_PATH="ファイルパスを入力: "
  $T_PRIV="--- 秘密鍵 ---"
  $T_PUB="--- 公開鍵 ---"
  $T_ENTER="続行するには Enter を押してください…"
  $T_DONE="完了しました。"
  $T_INVALID="無効な選択です。"
 }
}

function Pause-Enter { Read-Host $T_ENTER | Out-Null }

function Generate-Key {
  Write-Host $T_ALGO
  $sel = Read-Host ">"
  $tmp = [System.IO.Path]::GetTempFileName()
  $key = "$tmp.key"
  switch ($sel) {
    "1" { Invoke-SSHKeygen -Type rsa -Bits 2048  -Comment ("rsa-2048-"+(Get-Timestamp)) -OutFile $key }
    "2" { Invoke-SSHKeygen -Type rsa -Bits 3072  -Comment ("rsa-3072-"+(Get-Timestamp)) -OutFile $key }
    "3" { Invoke-SSHKeygen -Type rsa -Bits 4096  -Comment ("rsa-4096-"+(Get-Timestamp)) -OutFile $key }
    "4" { Invoke-SSHKeygen -Type ed25519 -KdfRounds 100 -Comment ("ed25519-"+(Get-Timestamp)) -OutFile $key }
    default { Write-Host $T_INVALID; Pause-Enter; return }
  }
  Write-Host $T_PRIV
  Get-Content -Raw "$key"
  "`n$T_PUB"
  Get-Content -Raw "$key.pub"
  Remove-Item "$key","$key.pub" -Force
  Write-Host $T_DONE
  Pause-Enter
}

function Derive-Public {
  Write-Host $T_INPUT
  $sel = Read-Host ">"
  $tmp = [System.IO.Path]::GetTempFileName()
  if ($sel -eq "1") {
    Write-Host $T_PASTE
    $sb = New-Object System.Text.StringBuilder
    while ($true) {
      $line = Read-Host
      if ([string]::IsNullOrWhiteSpace($line)) { break }
      [void]$sb.AppendLine($line)
    }
    [IO.File]::WriteAllText($tmp,$sb.ToString())
  } elseif ($sel -eq "2") {
    $p = Read-Host $T_PATH
    if (-not (Test-Path $p)) { Write-Host "File not found."; Pause-Enter; return }
    Copy-Item $p $tmp -Force
  } else { Write-Host $T_INVALID; Pause-Enter; return }

  $pub = & ssh-keygen -y -f $tmp 2>$null
  Write-Host $T_PUB
  Write-Host $pub
  Remove-Item $tmp -Force
  Write-Host $T_DONE
  Pause-Enter
}

while ($true) {
  Clear-Host
  Write-Host $T_MENU
  $c = Read-Host $T_CHOICE
  switch ($c) {
    "1" { Generate-Key }
    "2" { Derive-Public }
    "3" { return }
    default { Write-Host $T_INVALID; Pause-Enter }
  }
}
