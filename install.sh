#!/bin/bash

# 에러 발생 시 즉시 중단
set -e

# --- 변수 정의 ---
DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)
LOCAL_INSTALL_DIR="$HOME/.local"
ZSH_CUSTOM_PLUGINS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
ZSH_VERSION="5.9" # 설치할 Zsh 버전

# --- 색상 코드 ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Starting dotfiles setup...${NC}"

# --- 1. Zsh 설치 확인 및 자동 컴파일 설치 ---
if ! command -v zsh &> /dev/null; then
    echo -e "${YELLOW}Zsh not found. Attempting to install from source...${NC}"

    # 컴파일에 필요한 gcc와 make가 있는지 확인
    if ! command -v gcc &> /dev/null || ! command -v make &> /dev/null; then
        echo -e "${RED}Error: 'gcc' and 'make' are required for compilation, but not found.${NC}"
        echo -e "${RED}Please ask your system administrator to install build tools.${NC}"
        exit 1
    fi

    echo -e "${GREEN}Downloading Zsh v${ZSH_VERSION} source code...${NC}"
    mkdir -p "$HOME/src"
    cd "$HOME/src"
    wget -O "zsh-${ZSH_VERSION}.tar.xz" "https://www.zsh.org/pub/zsh-${ZSH_VERSION}.tar.xz"
    tar -xf "zsh-${ZSH_VERSION}.tar.xz"
    cd "zsh-${ZSH_VERSION}"

    echo -e "${GREEN}Configuring and compiling Zsh... (This may take a while)${NC}"
    ./configure --prefix="$LOCAL_INSTALL_DIR"
    make
    make install

    # 새로 설치된 zsh를 PATH에 즉시 반영 (스크립트 실행 중 사용하기 위해)
    export PATH="$LOCAL_INSTALL_DIR/bin:$PATH"
    echo -e "${GREEN}Zsh installed successfully to $LOCAL_INSTALL_DIR/bin/zsh${NC}"
    cd ~ # 홈 디렉토리로 복귀
else
    echo -e "${GREEN}Zsh is already installed.${NC}"
fi

# --- 2. Miniconda 설치 및 설정 ---
# (이하 내용은 이전과 동일)
if [ -d "$HOME/miniconda3" ]; then
    echo -e "${YELLOW}Miniconda already installed. Skipping.${NC}"
else
    echo -e "${GREEN}Installing Miniconda...${NC}"
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
    bash ~/miniconda.sh -b -p $HOME/miniconda3
    rm ~/miniconda.sh

    echo -e "${GREEN}Initializing Miniconda for Zsh...${NC}"
    $HOME/miniconda3/bin/conda init zsh


    $HOME/miniconda3/bin/conda config --set changeps1 true
    $HOME/miniconda3/bin/conda config --set auto_activate_base true
fi

# --- 3. Oh My Zsh 및 플러그인 설치 ---
# (이하 내용은 이전과 동일)
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${YELLOW}Oh My Zsh already installed. Skipping.${NC}"
else
    echo -e "${GREEN}Installing Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ... (이하 플러그인 설치 부분은 동일) ...

# --- 4. 설정 파일 심볼릭 링크 생성 ---
echo -e "${GREEN}Creating symbolic links for config files...${NC}"
rm -f ~/.zshrc ~/.tmux.conf
ln -s "$DOTFILES_DIR/zshrc/.zshrc" ~/.zshrc
ln -s "$DOTFILES_DIR/tmux/.tmux.conf" ~/.tmux.conf
echo -e "${GREEN}Symbolic links created.${NC}"

# --- 5. 기본 셸을 Zsh로 변경 or fallback ---
ZSH_PATH=$(command -v zsh || true)

if [[ -n "$ZSH_PATH" ]]; then
    echo -e "${GREEN}Zsh found at ${ZSH_PATH}.${NC}"
    if command -v chsh &> /dev/null; then
        echo -e "${GREEN}Attempting to change default shell to zsh...${NC}"
        chsh -s "$ZSH_PATH" || echo -e "${YELLOW}'chsh' failed. Falling back to sourcing .zshrc in bash.${NC}"
    else
        echo -e "${YELLOW}'chsh' not available. Falling back to sourcing .zshrc in bash.${NC}"
    fi
else
    echo -e "${YELLOW}Zsh not installed, skipping shell change.${NC}"
fi

# --- Fallback: bash에서 항상 zsh 시도 ---
if ! grep -q '### AUTO-ZSH-FALLBACK ###' ~/.bashrc; then
    echo -e "${YELLOW}Adding zsh fallback exec to ~/.bashrc${NC}"
    cat << 'EOF' >> ~/.bashrc

### AUTO-ZSH-FALLBACK ###
# zsh가 설치되어 있으면 자동 실행
if [ -x "$HOME/.local/bin/zsh" ]; then
    exec "$HOME/.local/bin/zsh"
elif command -v zsh >/dev/null 2>&1; then
    exec "$(command -v zsh)"
fi
### END AUTO-ZSH-FALLBACK ###
EOF
fi