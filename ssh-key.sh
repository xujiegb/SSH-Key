#!/usr/bin/env bash
# ssh-key-wizard.sh
# A local-only SSH key helper with i18n, generation & pubkey-derivation.
set -u

# --- deps check ---
require() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1"; exit 1; }; }
require ssh-keygen
umask 077

# --- i18n messages ---
# lang codes: en zh_CN zh_TW fr ru fa ja
declare -A MSG
msg() { printf "%s" "${MSG[$1]}"; }

choose_lang() {
  cat <<'EOF'
Select language / 选择语言 / 選擇語言 / Choisir la langue / Выберите язык / انتخاب زبان / 言語を選択:
  1) English
  2) 简体中文
  3) 繁體中文
  4) Français
  5) Русский
  6) فارسی (ایرانی)
  7) 日本語
EOF
  read -rp "> " ans
  case "$ans" in
    1) L=en ;;
    2) L=zh_CN ;;
    3) L=zh_TW ;;
    4) L=fr ;;
    5) L=ru ;;
    6) L=fa ;;
    7) L=ja ;;
    *) L=en ;;
  esac

  case "$L" in
en)
  MSG=(
    [main_title]=$'SSH Key Wizard\n'
    [menu]=$'Choose an action:\n  1) Generate key (RSA2048/3072/4096, Ed25519)\n  2) Derive public key from private key\n  3) Exit\n> '
    [gen_title]=$'Choose key type:\n  1) RSA-2048\n  2) RSA-3072\n  3) RSA-4096\n  4) Ed25519\n> '
    [gen_done]=$'\nGenerated! Below are your keys (keep PRIVATE key secret):\n'
    [priv_key]=$'\n--- PRIVATE KEY ---\n'
    [pub_key]=$'\n--- PUBLIC KEY ---\n'
    [export_q]=$'\nExport to files? (y/N): '
    [export_where]=$'Enter output base path (e.g., /home/user/id_mykey; .pub will be added): '
    [export_overwrite]=$'File exists. Overwrite? (y/N): '
    [saved]=$'Saved: '
    [der_title]=$'Public key from private key\nChoose input method:\n  1) Paste private key (end with Ctrl-D)\n  2) Enter file path (or drag file here)\n> '
    [enter_path]=$'Enter private key path: '
    [paste_hint]=$'Paste the private key, then press Ctrl-D:\n'
    [bad_key]=$'Could not read a valid private key.\n'
    [again]=$'\nDo you want to (1) Main menu  (2) Exit ? '
    [bye]=$'Bye.\n'
    [note]=$'\nNOTE: This script never uploads keys. Handle private keys securely.\n'
  )
  ;;
zh_CN)
  MSG=(
    [main_title]=$'SSH 密钥向导\n'
    [menu]=$'选择操作：\n  1) 生成密钥（RSA2048/3072/4096、Ed25519）\n  2) 由私钥查询公钥\n  3) 退出\n> '
    [gen_title]=$'选择密钥类型：\n  1) RSA-2048\n  2) RSA-3072\n  3) RSA-4096\n  4) Ed25519\n> '
    [gen_done]=$'\n已生成！以下为你的密钥（请妥善保管私钥）：\n'
    [priv_key]=$'\n--- 私钥 ---\n'
    [pub_key]=$'\n--- 公钥 ---\n'
    [export_q]=$'\n是否导出为文件？(y/N)：'
    [export_where]=$'请输入导出基础路径（如 /home/user/id_mykey；会自动生成 .pub）：'
    [export_overwrite]=$'文件已存在，是否覆盖？(y/N)：'
    [saved]=$'已保存：'
    [der_title]=$'由私钥生成公钥\n选择输入方式：\n  1) 粘贴私钥（结束请按 Ctrl-D）\n  2) 输入文件路径（或将文件拖入终端）\n> '
    [enter_path]=$'请输入私钥文件路径：'
    [paste_hint]=$'请粘贴私钥，然后按 Ctrl-D 结束：\n'
    [bad_key]=$'无法读取有效的私钥。\n'
    [again]=$'\n是否 (1) 返回主菜单  (2) 退出？ '
    [bye]=$'已退出。\n'
    [note]=$'\n提示：脚本不上传任何密钥。请安全保管你的私钥。\n'
  )
  ;;
zh_TW)
  MSG=(
    [main_title]=$'SSH 金鑰精靈\n'
    [menu]=$'選擇操作：\n  1) 產生金鑰（RSA2048/3072/4096、Ed25519）\n  2) 由私鑰查詢公鑰\n  3) 離開\n> '
    [gen_title]=$'選擇金鑰類型：\n  1) RSA-2048\n  2) RSA-3072\n  3) RSA-4096\n  4) Ed25519\n> '
    [gen_done]=$'\n已產生！以下為你的金鑰（請妥善保管私鑰）：\n'
    [priv_key]=$'\n--- 私鑰 ---\n'
    [pub_key]=$'\n--- 公鑰 ---\n'
    [export_q]=$'\n是否匯出為檔案？(y/N)：'
    [export_where]=$'請輸入匯出基礎路徑（如 /home/user/id_mykey；會自動產生 .pub）：'
    [export_overwrite]=$'檔案已存在，是否覆寫？(y/N)：'
    [saved]=$'已儲存：'
    [der_title]=$'由私鑰產生公鑰\n選擇輸入方式：\n  1) 貼上私鑰（結束請按 Ctrl-D）\n  2) 輸入檔案路徑（或將檔案拖入終端機）\n> '
    [enter_path]=$'請輸入私鑰檔案路徑：'
    [paste_hint]=$'請貼上私鑰，然後按 Ctrl-D 結束：\n'
    [bad_key]=$'無法讀取有效的私鑰。\n'
    [again]=$'\n要 (1) 回主選單  (2) 離開？ '
    [bye]=$'已離開。\n'
    [note]=$'\n提示：腳本不會上傳任何金鑰。請安全保管你的私鑰。\n'
  )
  ;;
fr)
  MSG=(
    [main_title]=$'Assistant de clés SSH\n'
    [menu]=$'Choisissez :\n  1) Générer une clé (RSA2048/3072/4096, Ed25519)\n  2) Dériver la clé publique depuis une clé privée\n  3) Quitter\n> '
    [gen_title]=$'Type de clé :\n  1) RSA-2048\n  2) RSA-3072\n  3) RSA-4096\n  4) Ed25519\n> '
    [gen_done]=$'\nGénéré ! Voici vos clés (gardez la PRIVÉE secrète) :\n'
    [priv_key]=$'\n--- CLÉ PRIVÉE ---\n'
    [pub_key]=$'\n--- CLÉ PUBLIQUE ---\n'
    [export_q]=$'\nExporter vers des fichiers ? (y/N) : '
    [export_where]=$'Chemin de base de sortie (ex. /home/user/id_ma_cle ; .pub sera ajouté) : '
    [export_overwrite]=$'Fichier existant. Écraser ? (y/N) : '
    [saved]=$'Enregistré : '
    [der_title]=$'Clé publique depuis clé privée\nMéthode :\n  1) Coller la clé privée (finir avec Ctrl-D)\n  2) Saisir le chemin du fichier (ou glisser-déposer)\n> '
    [enter_path]=$'Chemin de la clé privée : '
    [paste_hint]=$'Collez la clé privée puis Ctrl-D :\n'
    [bad_key]=$'Clé privée invalide.\n'
    [again]=$'\nVoulez-vous (1) Menu principal  (2) Quitter ? '
    [bye]=$'Au revoir.\n'
    [note]=$'\nNote : Ce script n’upload rien. Protégez votre clé privée.\n'
  )
  ;;
ru)
  MSG=(
    [main_title]=$'Мастер ключей SSH\n'
    [menu]=$'Выберите действие:\n  1) Сгенерировать ключ (RSA2048/3072/4096, Ed25519)\n  2) Получить публичный ключ из приватного\n  3) Выход\n> '
    [gen_title]=$'Тип ключа:\n  1) RSA-2048\n  2) RSA-3072\n  3) RSA-4096\n  4) Ed25519\n> '
    [gen_done]=$'\nГотово! Ваши ключи (приватный храните в секрете):\n'
    [priv_key]=$'\n--- ПРИВАТНЫЙ КЛЮЧ ---\n'
    [pub_key]=$'\n--- ПУБЛИЧНЫЙ КЛЮЧ ---\n'
    [export_q]=$'\nСохранить в файлы? (y/N): '
    [export_where]=$'Введите базовый путь (напр., /home/user/id_mykey; .pub добавится): '
    [export_overwrite]=$'Файл уже существует. Перезаписать? (y/N): '
    [saved]=$'Сохранено: '
    [der_title]=$'Публичный ключ из приватного\nСпособ ввода:\n  1) Вставить приватный ключ (завершить Ctrl-D)\n  2) Указать путь к файлу (или перетащить файл)\n> '
    [enter_path]=$'Путь к приватному ключу: '
    [paste_hint]=$'Вставьте приватный ключ и нажмите Ctrl-D:\n'
    [bad_key]=$'Не удалось прочитать приватный ключ.\n'
    [again]=$'\n(1) Главное меню  (2) Выход ? '
    [bye]=$'Пока.\n'
    [note]=$'\nПримечание: Скрипт ничего не загружает. Берегите приватные ключи.\n'
  )
  ;;
fa)
  MSG=(
    [main_title]=$'دستیار کلید SSH\n'
    [menu]=$'یک عملیات را انتخاب کنید:\n  1) تولید کلید (RSA2048/3072/4096، Ed25519)\n  2) استخراج کلید عمومی از کلید خصوصی\n  3) خروج\n> '
    [gen_title]=$'نوع کلید:\n  1) RSA-2048\n  2) RSA-3072\n  3) RSA-4096\n  4) Ed25519\n> '
    [gen_done]=$'\nتولید شد! کلیدها در زیر هستند (کلید خصوصی را محرمانه نگه دارید):\n'
    [priv_key]=$'\n--- کلید خصوصی ---\n'
    [pub_key]=$'\n--- کلید عمومی ---\n'
    [export_q]=$'\nخروجی به فایل؟ (y/N): '
    [export_where]=$'مسیر پایه خروجی را وارد کنید (مثلاً /home/user/id_mykey ؛ ‎.pub اضافه می‌شود): '
    [export_overwrite]=$'فایل وجود دارد. بازنویسی؟ (y/N): '
    [saved]=$'ذخیره شد: '
    [der_title]=$'کلید عمومی از کلید خصوصی\nروش ورودی:\n  1) چسباندن کلید خصوصی (با Ctrl-D پایان دهید)\n  2) مسیر فایل (یا کشیدن فایل به ترمینال)\n> '
    [enter_path]=$'مسیر کلید خصوصی: '
    [paste_hint]=$'کلید خصوصی را بچسبانید و Ctrl-D را بزنید:\n'
    [bad_key]=$'کلید خصوصی معتبر شناسایی نشد.\n'
    [again]=$'\nآیا می‌خواهید (1) منوی اصلی  (2) خروج ؟ '
    [bye]=$'خداحافظ.\n'
    [note]=$'\nتذکر: این اسکریپت چیزی را آپلود نمی‌کند. کلید خصوصی را ایمن نگه دارید.\n'
  )
  ;;
ja)
  MSG=(
    [main_title]=$'SSH キーウィザード\n'
    [menu]=$'操作を選択:\n  1) キー生成（RSA2048/3072/4096、Ed25519）\n  2) 秘密鍵から公開鍵を取得\n  3) 終了\n> '
    [gen_title]=$'キー種別:\n  1) RSA-2048\n  2) RSA-3072\n  3) RSA-4096\n  4) Ed25519\n> '
    [gen_done]=$'\n生成しました！ 以下があなたの鍵です（秘密鍵は厳重に保管）：\n'
    [priv_key]=$'\n--- 秘密鍵 ---\n'
    [pub_key]=$'\n--- 公開鍵 ---\n'
    [export_q]=$'\nファイルに保存しますか？ (y/N): '
    [export_where]=$'出力の基本パスを入力（例 /home/user/id_mykey；.pub が付与されます）：'
    [export_overwrite]=$'ファイルが存在します。上書きしますか？ (y/N): '
    [saved]=$'保存しました: '
    [der_title]=$'秘密鍵から公開鍵\n入力方法を選択:\n  1) 秘密鍵を貼り付け（Ctrl-D で終了）\n  2) ファイルパス入力（またはドラッグ&ドロップ）\n> '
    [enter_path]=$'秘密鍵ファイルのパス：'
    [paste_hint]=$'秘密鍵を貼り付け、Ctrl-D で終了：\n'
    [bad_key]=$'有効な秘密鍵を読み取れませんでした。\n'
    [again]=$'\n(1) メインメニュー  (2) 終了 ? '
    [bye]=$'終了します。\n'
    [note]=$'\n注意：このスクリプトは何もアップロードしません。秘密鍵は安全に保管してください。\n'
  )
  ;;
  esac
}

print_keys() {
  local priv="$1" pub="$2"
  echo "$(msg gen_done)"
  echo "$(msg priv_key)"
  cat "$priv"
  echo "$(msg pub_key)"
  cat "$pub"
}

ask_export() {
  local priv="$1" pub="$2"
  read -rp "$(msg export_q)" ans
  [[ "${ans:-}" =~ ^[Yy]$ ]] || return 0
  read -rp "$(msg export_where)" base
  [[ -n "${base:-}" ]] || { echo "Invalid path"; return 1; }
  for f in "$base" "$base.pub"; do
    if [[ -e "$f" ]]; then
      read -rp "$(msg export_overwrite)" ow
      [[ "${ow:-}" =~ ^[Yy]$ ]] || { echo "Skip."; return 1; }
      break
    fi
  done
  cp -f "$priv" "$base" && chmod 600 "$base"
  cp -f "$pub"  "$base.pub" && chmod 644 "$base.pub"
  echo "$(msg saved)$base"
  echo "$(msg saved)$base.pub"
}

gen_key() {
  local choice bits type comment tmpdir tmpbase
  read -rp "$(msg gen_title)" choice
  case "$choice" in
    1) type=rsa bits=2048 ;;
    2) type=rsa bits=3072 ;;
    3) type=rsa bits=4096 ;;
    4) type=ed25519 bits= ;;
    *) echo "Invalid."; return 1 ;;
  esac
  comment="${type}-$(date +%Y%m%d%H%M%S)"
  tmpdir="$(mktemp -d)"
  tmpbase="$tmpdir/id_${type}"
  if [[ "$type" == "rsa" ]]; then
    ssh-keygen -t rsa -b "$bits" -N "" -C "$comment" -f "$tmpbase" -q
  else
    ssh-keygen -t ed25519 -a 100 -N "" -C "$comment" -f "$tmpbase" -q
  fi
  print_keys "$tmpbase" "$tmpbase.pub"
  ask_export "$tmpbase" "$tmpbase.pub"
}

derive_pub() {
  local mode tmpdir tmpkey path
  read -rp "$(msg der_title)" mode
  tmpdir="$(mktemp -d)"
  tmpkey="$tmpdir/privkey"
  case "$mode" in
    1)
      echo -e "$(msg paste_hint)"
      cat > "$tmpkey"
      ;;
    2)
      read -rp "$(msg enter_path)" path
      [[ -f "$path" ]] || { echo "$(msg bad_key)"; return 1; }
      cp "$path" "$tmpkey"
      ;;
    *)
      echo "Invalid."; return 1 ;;
  esac
  # Try to read pub via ssh-keygen -y
  if ! pub=$(ssh-keygen -y -f "$tmpkey" 2>/dev/null); then
    echo -e "$(msg bad_key)"; return 1;
  fi
  # Detect key type for comment
  ktype=$(ssh-keygen -lf "$tmpkey" 2>/dev/null | awk '{print $4}')
  [[ -z "${ktype:-}" ]] && ktype="ssh-key"
  publine="${pub} ${ktype}-$(date +%Y%m%d%H%M%S)"
  echo "$(msg pub_key)"
  echo "$publine"
  echo "$(msg priv_key)"
  cat "$tmpkey"

  # optional export
  ask_export "$tmpkey" <(echo "$publine") || true
}

main_menu() {
  echo -e "$(msg main_title)"
  while true; do
    read -rp "$(msg menu)" sel
    case "$sel" in
      1) gen_key ;;
      2) derive_pub ;;
      3) echo -e "$(msg bye)"; exit 0 ;;
      *) echo "Invalid." ;;
    esac
    read -rp "$(msg again)" nxt
    [[ "$nxt" == "1" ]] || { echo -e "$(msg bye)"; exit 0; }
  done
}

choose_lang
echo -e "$(msg note)"
main_menu
