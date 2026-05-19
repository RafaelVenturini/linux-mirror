install_fonts() {
    local FONT_DIR="$HOME/.local/share/fonts/MesloLGS"
    mkdir -p "$FONT_DIR"

    local BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"
    local FONTS=(
        "MesloLGS NF Regular.ttf"
        "MesloLGS NF Bold.ttf"
        "MesloLGS NF Italic.ttf"
        "MesloLGS NF Bold Italic.ttf"
    )

    for font in "${FONTS[@]}"; do
        local encoded="${font// /%20}"
        curl -fLo "$FONT_DIR/$font" "$BASE_URL/$encoded"
    done

    fc-cache -fv
    echo "Fontes instaladas!"
}