liss(){
  local target="$1"
  local action="$2"
  case "$target" in
    be)
      dir="$HOME/Documentos/dev/codes/backend/backend-for-liss"
      ;;
    ctg)
      dir="$HOME/Documentos/dev/codes/catalogs/fitness"
      ;;
    duo)
      _liss_duo "$action"
      return
      ;;
    *)
      echo "Projeto não encontrado: $target"
      return 1
      ;;
  esac
  cd "$dir" || return
  case "$action" in
    run)
      npm run dev
      ;;
    code)
      nvim .
      ;;
    "")
      ;;
    *)
      echo "Ação desconhecida: $action"
      ;;
  esac
}

_liss_duo(){
  local action="$1"
  local be_dir="$HOME/Documentos/dev/codes/backend/backend-for-liss"
  local ctg_dir="$HOME/Documentos/dev/codes/catalogs/fitness"
  case "$action" in
    run)
      echo "🚀 Iniciando be..."
      (cd "$be_dir" && npm run dev) &
      echo "🚀 Iniciando ctg..."
      (cd "$ctg_dir" && npm run dev) &
      wait
      ;;
    code)
      nvim "$be_dir" -c "tabnew $ctg_dir"
      ;;
    "")
      cd "$be_dir"
      ;;
    *)
      echo "Ação desconhecida: $action"
      ;;
  esac
}