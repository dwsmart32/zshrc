#!/bin/bash

# 에러 발생 시 즉시 스크립트 실행을 중단합니다.
set -e

# --- 1. Zsh 소스 다운로드 및 설치 ---
echo "⬇️  Zsh 소스를 다운로드하고 설치합니다..."
cd ~
# 최신 버전의 zsh 소스 코드를 다운로드합니다.
curl -Lo zsh.tar.xz https://sourceforge.net/projects/zsh/files/latest/download
tar -xf zsh.tar.xz
# 압축 해제된 폴더로 이동합니다. (버전명에 상관없이 동작)
cd zsh-*

# 사용자 홈 디렉토리 아래 .local에 설치하도록 설정합니다. (sudo 불필요)
./configure --prefix=$HOME/.local
make
make install
echo "✅ Zsh 설치 완료."
echo "-----------------------------------------------------"


# --- 2. Oh My Zsh 및 플러그인 설치 ---
# Oh My Zsh을 설치합니다. (이 과정에서 ~/.zshrc가 생성됩니다)
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "ℹ️  Oh My Zsh는 이미 설치되어 있습니다."
else
  echo "⬇️  Oh My Zsh를 설치합니다..."
  git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
  echo "✅ Oh My Zsh 설치 완료."
fi

# zsh-autosuggestions 플러그인을 설치합니다.
echo "⬇️  zsh-autosuggestions 플러그인을 설치합니다..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting 플러그인을 설치합니다.
echo "⬇️  zsh-syntax-highlighting 플러그인을 설치합니다..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
echo "✅ Zsh 플러그인 2개 설치 완료."
echo "-----------------------------------------------------"


# --- 3. 사용자 맞춤 .zshrc 설정 ---
echo "⚙️  사용자 맞춤 .zshrc 설정을 시작합니다..."
cd ~
# 사용자 zshrc git repo를 임시 폴더에 복제합니다.
echo "⬇️  Git에서 zshrc 설정을 가져옵니다..."
git clone https://github.com/dwsmart32/zshrc.git temp_zshrc_repo

# 복제한 zshrc 파일에서 기존 conda 초기화 블록을 제거하고, 그 결과를 ~/.zshrc에 덮어씁니다.
echo "🔧 기존 Conda 초기화 블록을 제거하고 .zshrc를 덮어씁니다..."
sed '/# >>> conda initialize >>>/,/# <<< conda initialize <<</d' ~/temp_zshrc_repo/zshrc > ~/.zshrc

# 임시 폴더를 삭제합니다.
rm -rf temp_zshrc_repo
echo "✅ 사용자 맞춤 .zshrc 설정 완료."
echo "-----------------------------------------------------"


# --- 4. Miniconda 설치 및 초기화 ---
echo "⬇️  Miniconda를 다운로드하고 설치합니다..."
# Miniconda 최신 버전 설치 스크립트를 다운로드합니다.
curl -Lo Miniconda3.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

# -b (batch mode) 옵션으로 사용자 입력 없이, -p 옵션으로 지정된 경로에 자동으로 설치합니다.
bash Miniconda3.sh -b -p $HOME/miniconda3

# 설치 스크립트 파일을 삭제합니다.
rm Miniconda3.sh

# 새로 설치된 Conda를 사용하여 zsh 셸에 대한 초기화 스크립트를 ~/.zshrc 파일 맨 끝에 추가합니다.
echo "🚀 Conda가 zsh 설정을 자동으로 초기화합니다..."
$HOME/miniconda3/bin/conda init zsh
echo "✅ Miniconda 설치 및 초기화 완료."
echo "-----------------------------------------------------"


# --- 최종 안내 ---
echo "🎉 모든 설치 및 설정이 완료되었습니다!"
echo "새 터미널을 열거나 'exec zsh'를 실행하여 새로운 Zsh 환경을 시작하세요."