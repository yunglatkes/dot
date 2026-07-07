# ----- Keybinds -----
if [ -f /usr/share/doc/fzf/example/key-bindings.zsh ]; then
    . /usr/share/doc/fzf/example/key-bindings.zsh
elif [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
    . /usr/share/doc/fzf/examples/key-bindings.zsh
fi

# ----- Custom aliases -----
source ~/.alias

# ----- Custom path -----
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
export PATH="$PATH:$HOME/code/spek-cli/target/release"
export PATH="$PATH:/opt/cmake/bin"
export PATH="$PATH:$HOME/code/solVitaire"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/code/jdk-25.0.3+9/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# ----- Prompt -----
# reference https://recursivefunction.blog/p/building-a-custom-zsh-prompt-from
#
# enable git (vcs) info
autoload -Uz vcs_info
setopt prompt_subst

# customize git prompt
zstyle ':vcs_info:git*' formats " %F{blue}%b%f%m%u%c%a "
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '%F{green}+%f'
zstyle ':vcs_info:*' unstagedstr '%F{red}*%f'

precmd() {
    vcs_info ;
    echo -ne '\e[6 q' # Use beam shape cursor for each new prompt.
}

PROMPT='%F{magenta}%B%~%b%f ${vcs_info_msg_0_}%B%(!.#.❯)%b '
# reverse ❮

# ref https://github.com/BrodieRobertson/dotfiles/blob/master/.zshrc
#
# Change cursor shape for different vi modes.
echo -ne '\e[6 q' # Use beam shape cursor on startup.

function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[2 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[6 q'
  fi
}
zle -N zle-keymap-select

# ----- History -----
# reference https://github.com/BreadOnPenguins/dots/blob/master/.config/zsh/.zshrc
#
setopt append_history inc_append_history share_history # better history
HISTCONTROL=ignoreboth # consecutive duplicates & commands starting with space are not saved

# ----- Functionality -----
# Select during cd completions
zstyle ':completion:*' menu select

# Colored man pages
# reference https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/colored-man-pages/colored-man-pages.plugin.zsh
#
# Requires colors autoload.
# See termcap(5).

# Set up once, and then reuse. This way it supports user overrides after the
# plugin is loaded.
typeset -AHg less_termcap

# bold & blinking mode
less_termcap[mb]="${fg_bold[red]}"
less_termcap[md]="${fg_bold[red]}"
less_termcap[me]="${reset_color}"
# standout mode
less_termcap[so]="${fg_bold[yellow]}${bg[blue]}"
less_termcap[se]="${reset_color}"
# underlining
less_termcap[us]="${fg_bold[green]}"
less_termcap[ue]="${reset_color}"

# Handle $0 according to the standard:
# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# Absolute path to this file's directory.
typeset -g __colored_man_pages_dir="${0:A:h}"

function colored() {
  local -a environment

  # Convert associative array to plain array of NAME=VALUE items.
  local k v
  for k v in "${(@kv)less_termcap}"; do
    environment+=( "LESS_TERMCAP_${k}=${v}" )
  done

  # Prefer `less` whenever available, since we specifically configured
  # environment for it.
  environment+=( PAGER="${commands[less]:-$PAGER}" )
  environment+=( GROFF_NO_SGR=1 )

  # See ./nroff script.
  if [[ "$OSTYPE" = solaris* ]]; then
    environment+=( PATH="${__colored_man_pages_dir}:$PATH" )
  fi

  command env "${environment[@]}" "$@"
}

# Colorize man and dman/debman (from debian-goodies)
function man \
  dman \
  debman {
  colored $0 "$@"
}
