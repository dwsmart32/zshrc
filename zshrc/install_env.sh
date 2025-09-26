#!/bin/bash

# 에러 발생 시 즉시 스크립트 실행을 중단합니다.
set -e

# --- 1. Zsh 소스 다운로드 및 설치 ---
if [ -f "$HOME/.local/bin/zsh" ]; then
    echo "ℹ️  Zsh는 이미 ~/.local/bin에 설치되어 있습니다."
else
    echo "⬇️  Zsh 소스를 다운로드하고 설치합니다..."
    curl -Lo zsh.tar.xz https://sourceforge.net/projects/zsh/files/latest/download
    tar -xf zsh.tar.xz
    cd zsh-*/

    ./configure --prefix=$HOME/.local
    make
    make install
    rm -rf zsh-* zsh.tar.xz
    echo "✅ Zsh 설치 완료."
fi

echo "-----------------------------------------------------"

# --- 2. Oh My Zsh 및 플러그인 설치 ---
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "ℹ️  Oh My Zsh는 이미 설치되어 있습니다."
else
  echo "⬇️  Oh My Zsh를 설치합니다..."
  git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
  echo "✅ Oh My Zsh 설치 완료."
fi

ZSH_AS_PATH="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ -d "$ZSH_AS_PATH" ]; then
    echo "ℹ️  zsh-autosuggestions 플러그인은 이미 설치되어 있습니다."
else
    echo "⬇️  zsh-autosuggestions 플러그인을 설치합니다..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AS_PATH"
fi

ZSH_SH_PATH="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [ -d "$ZSH_SH_PATH" ]; then
    echo "ℹ️  zsh-syntax-highlighting 플러그인은 이미 설치되어 있습니다."
else
    echo "⬇️  zsh-syntax-highlighting 플러그인을 설치합니다..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_SH_PATH"
fi
echo "✅ Zsh 플러그인 설정 확인 완료."

echo "-----------------------------------------------------"

# --- 3. 사용자 맞춤 .zshrc 및 .tmux.conf 설정 ---
echo "⚙️  사용자 맞춤 설정을 시작합니다..."

echo "🔧 기존 임시 폴더(temp_zshrc_repo)를 정리합니다..."
rm -rf temp_zshrc_repo

echo "⬇️  Git에서 최신 zshrc와 tmux.conf 설정을 가져옵니다..."
git clone https://github.com/dwsmart32/zshrc.git temp_zshrc_repo

echo "🔧 .zshrc 설정을 덮어씁니다..."
sed '/# >>> conda initialize >>>/,/# <<< conda initialize <<</d' ~/temp_zshrc_repo/zshrc > ~/.zshrc

echo "🔧 tmux.conf 설정을 홈 디렉터리로 복사합니다..."
cp ~/temp_zshrc_repo/tmux.conf ~/.tmux.conf

rm -rf temp_zshrc_repo
echo "✅ 사용자 맞춤 설정 완료."

echo "-----------------------------------------------------"

# --- 4. Miniconda 설치 및 초기화 ---
if [ -d "$HOME/miniconda3" ]; then
    echo "ℹ️  Miniconda는 이미 설치되어 있습니다."
else
    echo "⬇️  Miniconda를 다운로드하고 설치합니다..."
    curl -Lo Miniconda3.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3.sh -b -p $HOME/miniconda3
    rm Miniconda3.sh
    echo "✅ Miniconda 설치 완료."
fi
echo "🚀 Conda가 zsh 설정을 초기화합니다..."
$HOME/miniconda3/bin/conda init zsh
echo "✅ Conda 초기화 완료."

echo "-----------------------------------------------------"

# --- 5. .bashrc를 통해 Zsh 자동 실행 설정 (sudo 불필요 버전) ---
echo "🚀 .bashrc에 Zsh 자동 실행 코드를 추가합니다..."

# .bashrc에 추가할 Zsh 실행 스크립트 정의
# Zsh 자체에서 다시 Zsh를 실행하는 무한 루프를 방지하기 위해 $ZSH_VERSION 변수가 비어있을 때만 실행
ZSH_LAUNCH_SCRIPT='
# Auto-launch Zsh from Bash
if [ -z "$ZSH_VERSION" ] && [ -x "$HOME/.local/bin/zsh" ]; then
  exec "$HOME/.local/bin/zsh"
fi'

# 스크립트가 이미 .bashrc에 추가되었는지 확인하고, 없으면 추가
if ! grep -q "Auto-launch Zsh from Bash" ~/.bashrc; then
    # 파일 끝에 스크립트 추가
    echo "$ZSH_LAUNCH_SCRIPT" >> ~/.bashrc
    echo "✅ .bashrc에 자동 실행 코드 추가 완료."
else
    echo "ℹ️  .bashrc에 자동 실행 코드가 이미 존재합니다."
fi
echo "-----------------------------------------------------"

# --- 최종 안내 ---
echo "🎉 모든 설치 및 설정이 완료되었습니다!"
echo "변경 사항을 적용하려면 새 터미널 창을 여세요."
