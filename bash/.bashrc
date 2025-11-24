# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
[ -r /home/geracha/.byobu/prompt ] && . /home/geracha/.byobu/prompt   #byobu-prompt#



# might also be my edits not sure
# i could see writing this to add nvim 
# export PATH="$PATH:/opt/nvim"


# no idea what this are
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

# More readable version with your Catppuccin colors
PS1='\[\033[38;5;67m\]\u@\h:\w\$ \[\033[0m\]'
# =================
# my edits begin here (after bash )
# =================

# alias
alias python='python3'
alias vim='nvim'
alias t='tmux'

alias reload='source ~/.bashrc' 
alias tux='tmux kill-session'
alias xit='tmux kill-session'


# set my beloved vim mode on the shell
set -o vi

# ________________ python activate (activator) ________________
## Custom bash functions i defined that have function
akv() {
    local dir=$(pwd)
    while 
        [[ "$dir" != "$HOME" && "$dir" != "/" ]] 
    do
        if 
            [[ -f "$dir/venv/bin/activate" ]] 
        then
            echo "Activating virtual environment at: $dir/venv"
            source "$dir/venv/bin/activate"  
            return
        fi

        dir=$(dirname "$dir")
    done

    if [[ "$dir" = "$HOME" ]]
    then
        echo "Activating virtual environment at: $HOME"
        source "$HOME/venv/bin/activate"  
        return
    fi
}

# ________________ uv activate (activator) ________________
# python venv, .venv
## Custom bash functions i defined that have function
ukv() {
    local dir=$(pwd)
    while 
        [[ "$dir" != "$HOME" && "$dir" != "/" ]] 
    do
        if 
            [[ -f "$dir/.venv/bin/activate" ]] 
        then
            echo "Activating virtual environment at: $dir/venv"
            source "$dir/.venv/bin/activate"  
            return
        fi

        dir=$(dirname "$dir")
    done

    if [[ "$dir" = "$HOME" ]]
    then
        echo "Activating virtual environment at: $HOME"
        source "$HOME/.venv/bin/activate"  
        return
    fi
}


# ________________ cherry project ______________________________
# Activate or create a project
# Will break if code/projects doesnt exist
project() {
    if [[ "$1" == "-new" && -n "$2" ]]; then
        echo "yes"
        # Create new project
        bash "$HOME/code/projects/wizard.sh" "$2"
        echo "yes"
        source "$HOME/code/projects/projects.sh" "$2"
    else
        # Activate existing project
        source "$HOME/code/projects/projects.sh" "$1"
    fi
}

# Autocomplete function
_project_completion() {
    local cur
    cur="${COMP_WORDS[COMP_CWORD]}"

    # List directories under ~/code/
    local dirs
    dirs=$(compgen -d "$HOME/code/$cur")

    # Strip prefix so only directory names show
    COMPREPLY=()
    for d in $dirs; do
        d="${d#"$HOME/code/"}"
        COMPREPLY+=("$d")
    done

}

# Register completion
complete -F _project_completion project

eval "$(uv generate-shell-completion bash)"
# ________________ end of cherry project ______________________________



# ____ git worktree creation shortcut_____
#
gwq (){

    arg1=$1

    # Check if branch name is provided
    if [ -z "$arg1" ]; then
        echo "Error: Branch name required"
        echo "Usage: $0 <branchname>"
        return 1
    fi

    branchname=$arg1
    code_base="/home/geracha/code"


    child=$PWD
    parent=$code_base

    if [[ "$child" == "$parent" ]]; then
        echo "Error: Current directory must be a child of $code_base (not $code_base itself)"
        echo "Aborting..."
        return 1

    elif [[ "$child" == "$parent"* ]]; then
        echo 
    else
        echo "Error: Current directory must be a child of $code_base"
        echo "Aborting..."
        return 1

    fi

    
    # Get project name (the first directory under code_base)
    project_path="${PWD#$code_base/}"
    project_name="${project_path%%/*}"

    project_full_path="$code_base/.worktree/${project_name}_${branchname}"


# Execute git worktree add command
    echo "Adding worktree for project: $project_name"
    echo "Branch: $branchname"
    echo "Worktree location: $project_full_path"

    git worktree add -b "$branchname" "$project_full_path"

}



# ─────────────────────────────────────────────────────────────
# gw: Jump to any git worktree using fzf
# ─────────────────────────────────────────────────────────────
gw() {
    local selected
    selected=$(git worktree list --porcelain | grep '^worktree ' | awk '{print $2}' | fzf --height 40% --border --prompt="Worktree > ")
    [[ -n "$selected" ]] && cd "$selected" && echo "→ $selected"
}

gwt() {
    local repo_root worktree_path worktree_name session_name config_file project_type python_env
    echo "eh"

    # Get git repo root and current worktree
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -z "$repo_root" ]]; then
        echo "Not in a git repository."
        return 1
    fi
    


    main_git_folder=$(git --git-dir="$(git rev-parse --git-common-dir)" rev-parse --show-toplevel)
    echo $main_git_folder

    # If no worktree selected yet, use fzf
    if [[ -z "$1" ]]; then
        worktree_path=$(git worktree list --porcelain | grep '^worktree ' | awk '{print $2}' | fzf --height 40% --border --prompt="Worktree > " --preview "ls -la {}")
        [[ -z "$worktree_path" ]] && return 1
    else
        worktree_path="$1"
    fi

    # Extract worktree name (basename)
    worktree_name=$(basename "$worktree_path")
    session_name="${worktree_name}"


    # Reset environment variables
    unset PROJECT_TYPE
    unset PYTHON_ENV


    # Read cherry.yaml if exists
    config_file="$worktree_path/cherry.yaml"
    echo $config_file

    dir=$worktree_path
    read_project_config $(echo $main_git_folder)



    # Check if session already exists
    # if it exists swithc to it, or attach to it
    # else make a new session
    if tmux has-session -t "$session_name" 2>/dev/null; then

        echo "Attaching to existing session: $session_name"
        kitty -e tmux attach -t "$session_name"

        # if [[ -n "$TMUX" ]]; then
            # Switch client to existing session
          #  tmux switch-client -t "$session_name"
        #else
            # Attach to existing session
         #   kitty -e tmux attach -t "$session_name"
        # fi
itty -e tmux attach -t "$session_name"

        # if [[ -n "$TMUX" ]]; then
            # Switch client to existing session
          #  tmux switch-client -t "$session_name"
        #else
            # Attach to existing session
         #   kitty -e tmux attach -t "$session_name"
        # fi
    else
     
        # will later be extracted to the abstraction
        # initialize new_tmux_session
        
        echo "Creating new session: $session_name"
        # Create new tmux session with two windows
        tmux new-session -d -s "$session_name" -c "$dir"
        tmux new-window -t "$session_name" -c "$dir"

       
        # Activate environment in both windows if it's a Python project
        if [[ "$PROJECT_TYPE" == "python" && -n "$PYTHON_ENV" ]]; then
            # First window (window 0)
            tmux send-keys -t "$session_name:1" "source $(echo $PYTHON_ENV)bin/activate" C-m
            tmux send-keys -t "$session_name:1" "clear" C-m
            
            # Second window (window 1)  
            tmux send-keys -t "$session_name:2" "source $(echo $PYTHON_ENV)bin/activate" C-m
            tmux send-keys -t "$session_name:2" "clear" C-m
        fi

        # Activate environment in both windows if it's a Python project
        if [[ "$PROJECT_TYPE" == "uv" ]]; then
            # First window (window 0)
            tmux send-keys -t "$session_name:1" "source $main_git_folder/.venv/bin/activate" C-m
            tmux send-keys -t "$session_name:1" "clear" C-m
            
            # Second window (window 1)  
            tmux send-keys -t "$session_name:2" "source $main_git_folder/.venv/bin/activate" C-m
            tmux send-keys -t "$session_name:2" "clear" C-m
        fi
     
       
        # activate nvim in window 2
        tmux send-keys -t "$session_name" "nvim ." C-m
        
        # endo of initialize_new_session

        # this is just open tmux, either from tmux, or outside
        #
        kitty -e tmux attach -t "$session_name"
        #if [[ -n "$TMUX" ]]; then
            # Switch client to new session
         #   tmux switch-client -t "$session_name"
        #else
            # Attach to new session
         #   tmux attach-session -t "$session_name"
        #fi
        
    fi
}


# Function to read YAML configuration
read_project_config() {
    # to edit here, so as to make type, a list
    echo "somethign we did is right"
    local dir="$1"
    echo $dir
    local config_file="$dir/cherry.yaml"
    
    if [[ ! -f "$config_file" ]]; then
        return 1
    fi
    

    echo "somethign we did is right"
    # Simple YAML parsing (for basic key: value pairs)
    while IFS=: read -r key value; do
        key=$(echo "$key" | tr -d ' ' | tr '[:upper:]' '[:lower:]')
        value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        case "$key" in
            "type")
                PROJECT_TYPE="$value"
                ;;
            "python_env")
                PYTHON_ENV="$value"
                ;;
        esac
    done < "$config_file"
}




alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

alias tree='tree -a -L 3'



