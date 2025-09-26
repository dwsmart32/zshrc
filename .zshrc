# Oh My Zsh 경로
export ZSH="$HOME/.oh-my-zsh"

# 사용자 로컬 bin 디렉토리 경로 추가
export PATH="$HOME/.local/bin:$PATH"

# Oh My Zsh 테마
ZSH_THEME="af-magic"

# Oh My Zsh 플러그인 목록
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
)

# Oh My Zsh 로드
source $ZSH/oh-my-zsh.sh

# --- 별칭 (Alias) ---
alias tma='tmux attach-session -t'
alias tmk='tmux kill-session -t'
alias tmn='tmux new-session -s'
alias tml='tmux list-sessions' # list-session이 올바른 명령어입니다.

alias vllm='conda activate vllm'
alias cosyvoice='conda activate cosyvoice'
alias orpheus2='conda activate orpheus2'
alias llama-factory='conda activate llama-factory'

alias gpustat='watch -n 1 -c --color $HOME/.config/gpustat_logic.sh' # $HOME 사용
alias wsqueuemy='watch -n 1 "squeue -o '\''%.10i %.15j %.2t %.10u %.10P %.16q %.12R %.2C %.10b %.8M'\'' -u $USER | nl -v -1"'

# --- 함수 (Functions) ---
squeue() { $HOME/.config/squeue_custom_v1.sh "$@"; } # $HOME 사용

tunneling() {
    local port_num="$1"
    local server_name="$2"
    ssh -L "${port_num}":localhost:"${port_num}" -N -f "$(whoami)@${server_name}" # -f로 백그라운드 실행, whoami 사용
}

wfsqueue () {
    watch "squeue | grep gpu-farm"
}

sscancel () {
    scancel $(echo $1 | tr '\n' ' ')
}

# --- 민감 정보 및 로컬 설정 로드 ---
# .zshrc.local 파일이 존재하면 로드합니다. API 키 등은 이 파일에 저장하세요.
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi

# >>> conda initialize >>>
# Miniconda 설치 스크립트가 이 부분을 자동으로 추가/수정할 것입니다.
# 만약을 위해 $HOME을 사용한 기본 버전을 남겨둡니다.
__conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
