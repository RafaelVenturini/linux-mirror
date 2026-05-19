# linux-mirror

Instala e configura um ambiente Fedora com shell, ferramentas, aplicativos, fontes e arquivos de configuração.

## Como usar

```bash
cd install
chmod +x install.zsh
./install.zsh
```

### Opções

- `--help`, `-h` — mostra ajuda
- `--skip-dnf` — pula instalação via DNF
- `--skip-flatpak` — pula instalação via Flatpak
- `--skip-others` — pula ferramentas customizadas
- `--skip-zsh` — pula instalação/configuração do Zsh

## O que o script faz

- instala Zsh e define como shell padrão
- instala pacotes DNF essenciais e utilitários
- instala Flatpak e adiciona o repositório Flathub
- instala Obsidian via Flatpak
- instala Superfile e Visual Studio Code
- instala fontes Powerlevel10k
- copia configurações de Kitty, Neovim e Zsh para o diretório do usuário

## Estrutura do projeto

- `install/install.zsh` — script principal
- `install/dnf.zsh` — instalação de pacotes via DNF
- `install/flatpack.zsh` — instalação via Flatpak
- `install/others.zsh` — instalação de ferramentas customizadas
- `install/zsh.zsh` — instalação e configuração de Zsh
- `install/helpers/check-install.zsh` — funções de utilidade
- `configs/kitty/` — configuração do Kitty
- `configs/nvim/` — configuração do Neovim
- `configs/p10k/` — configuração do Powerlevel10k
- `configs/zsh/` — configuração do Zsh
- `fonts/powerlevel.zsh` — instalador de fontes

## Requisitos

- Fedora Linux
- Conexão com internet
- Acesso `sudo`

## Observações

- O script aplica as configurações encontradas em `configs/`
- O único arquivo de documentação do projeto deve ser este `README.md`
- Os demais arquivos de texto foram removidos para manter o repositório enxuto
