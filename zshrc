# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$PATH"
export PYTHONNOUSERSITE=True
export GEMINI_API_KEY='AIzaSyBCnRZqbC6LHuUvxaFA64Kgw0J4cfDeSq4'
export PATH=$HOME/.local/bin:$PATH

 # 이거는 base env에깔린 libarary 가 다른 env에 영향을 주지 않도록 하기 위함

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="af-magic"
export BETTER_EXCEPTIONS=1

tunneling() {
    local port_num="$1"
    local server_name="$2"

    ssh -L "${port_num}":localhost:"${port_num}" -N  "gmltmd789@${server_name}"
}



gpustat_once() {
    squeue | grep -E "\(node2[1-7]\)" | awk '
    {
        match($0, /\(node2[1-7]\)/, m)
        node = m[0]; gsub(/[()]/, "", node)

        split($3, u, "/"); used=u[1]; total=u[2]; free=total-used

        cmd   = "scontrol -o show node " node
        state = "UNKNOWN"
        state_cmd = cmd " | grep -o \"State=[^ ]*\" | cut -d= -f2"
        state_cmd | getline state
        close(state_cmd)

        color = (free>0) ? "\033[1;32m" : "\033[1;31m"
        reset = "\033[0m"

        printf "%s├─(%s) : %d / %d (%d free) [State:%s]%s\n", \
               color, node, used, total, free, state, reset
    }'
}


alias gpustat='watch -n 1 -c --color ~/.config/gpustat_logic.sh'
alias watch='watch -d'
# alias wsqueuemy='watch -n 1 '"'"'squeue -all -O "jobid:.7,partition:.6,gres:.14,numcpus:.3,name:.12,comment:.54,username:.13,state:.8,timeused:.12,submittime:.20,reasonlist:.13,qos:.15,restartcnt:.2" --sort=P,-t,-p -u $USER  | nl -v -1'"'"
# alias wsqueuemy='watch -n 1 "'"squeue -all -O "jobid:.7,partition:.12,gres:.14,numcpus:.3,name:.12,comment:.54,state:.8,timeused:.9,submittime:.21,reasonlist:.13,qos:.15,restartcnt:.2" --sort=P,-t,-p -u $USER | nl -v -1"'"'
alias wsqueuemy='watch -n 1 "squeue -o '\''%.10i %.15j %.2t %.10u %.10P %.16q %.12R %.2C %.10b %.8M'\'' -u $USER | nl -v -1"'
wfsqueue () {
	watch "squeue | grep gpu-farm"
}
sscancel () {
        scancel $(echo $1 | tr '\n' ' ')
}

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git
 zsh-syntax-highlighting
 zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# alias
alias tma='tmux attach-session -t'
alias tmk='tmux kill-session -t'
alias tmn='tmux new-session -s'
alias tml='tmux list-session'

alias vllm='conda activate vllm'
alias cosyvoice='conda activate cosyvoice'
alias orpheus2='conda activate orpheus2'
alias llama-factory='conda activate llama-factory'

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/ohpc/pub/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/ohpc/pub/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/ohpc/pub/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/ohpc/pub/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

