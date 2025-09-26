#!/bin/bash

# 에러 발생 시 즉시 중단
set -e

# --- 변수 정의 ---
DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd) # 스크립트가 있는 디렉토리 (dotfiles)
ZSH_CUSTOM_PLUGINS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

# --- 색상 코드 (로그 가독성 향상) ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting dotfiles setup...${NC}"

# --- 1. Miniconda 설치 ---
if [ -d "$HOME/miniconda3" ]; then
    echo -e "${YELLOW}Miniconda already installed. Skipping.${NC}"
else
    echo -e "${GREEN}Installing Miniconda...${NC}"
    # 최신 Miniconda 설치 스크립트 다운로드 (Linux 64-bit)
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
    # -b: 배치 모드(질문 없음), -p: 설치 경로 지정
    bash ~/miniconda.sh -b -p $HOME/miniconda3
    # 설치 스크립트 삭제
    rm ~/miniconda.sh
    echo -e "${GREEN}Initializing Miniconda for Zsh...${NC}"
    # zsh 설정 파일에 conda 초기화 스크립트 추가
    $HOME/miniconda3/bin/conda init zsh
    
    echo -e "${GREEN}Setting default conda configurations (changeps1, auto_activate_base)...${NC}"
    $HOME/miniconda3/bin/conda config --set changeps1 true
    $HOME/miniconda3/bin/conda config --set auto_activate_base true
fi

# --- 2. Zsh 및 Oh My Zsh 설치 ---
# sudo가 없으므로 시스템에 zsh가 이미 설치되어 있는지 확인
if ! command -v zsh &> /dev/null; then
    echo -e "${YELLOW}Zsh is not installed. Please ask your system administrator to install it.${NC}"
    exit 1
fi

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${YELLOW}Oh My Zsh already installed. Skipping.${NC}"
else
    echo -e "${GREEN}Installing Oh My Zsh...${NC}"
    # 질문 없이 자동으로 Oh My Zsh 설치
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# --- 3. Zsh 플러그인 설치 (Syntax Highlighting, Autosuggestions) ---
# zsh-autosuggestions
if [ -d "${ZSH_CUSTOM_PLUGINS_DIR}/zsh-autosuggestions" ]; then
    echo -e "${YELLOW}zsh-autosuggestions already installed. Skipping.${NC}"
else
    echo -e "${GREEN}Installing zsh-autosuggestions...${NC}"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM_PLUGINS_DIR}/zsh-autosuggestions
fi

# zsh-syntax-highlighting
if [ -d "${ZSH_CUSTOM_PLUGINS_DIR}/zsh-syntax-highlighting" ]; then
    echo -e "${YELLOW}zsh-syntax-highlighting already installed. Skipping.${NC}"
else
    echo -e "${GREEN}Installing zsh-syntax-highlighting...${NC}"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM_PLUGINS_DIR}/zsh-syntax-highlighting
fi

# --- 4. 설정 파일 심볼릭 링크 생성 ---
echo -e "${GREEN}Creating symbolic links for config files...${NC}"
# 기존 파일이 있다면 .bak 확장자로 백업
mv -f ~/.zshrc ~/.zshrc.bak 2>/dev/null || true
mv -f ~/.tmux.conf ~/.tmux.conf.bak 2>/dev/null || true

# 심볼릭 링크 생성 (dotfiles 저장소의 파일을 홈 디렉토리에 연결)
ln -sf "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc
ln -sf "$DOTFILES_DIR/tmux/.tmux.conf" ~/.tmux.conf
echo -e "${GREEN}Symbolic links created.${NC}"

# --- 5. 기본 셸을 Zsh로 변경 (Workaround) ---
# chsh는 sudo 권한이 필요할 수 있으므로, .bashrc에 exec zsh를 추가하는 우회 방법 사용
if [[ ! "$(echo $SHELL)" == *"zsh"* ]]; then
    echo -e "${GREEN}Attempting to change default shell...${NC}"
    if command -v chsh &> /dev/null; then
        echo "Trying 'chsh -s \$(which zsh)'... You might be prompted for your password."
        chsh -s $(which zsh) || echo -e "${YELLOW}'chsh' failed. Using fallback method.${NC}"
    fi

    # chsh가 실패했거나, 셸이 아직 zsh가 아니라면 .bashrc 수정
    if [[ ! "$(echo $SHELL)" == *"zsh"* ]]; then
        echo 'if [ -t 1 ]; then exec zsh; fi' >> ~/.bashrc
        echo -e "${YELLOW}Added 'exec zsh' to ~/.bashrc as a fallback.${NC}"
        echo -e "${YELLOW}You will be in a Zsh shell automatically upon next login.${NC}"
    fi
fi

echo -e "\n${GREEN}✅ All done! Please log out and log back in to apply all changes.${NC}"
