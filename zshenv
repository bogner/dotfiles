# unique paths.
typeset -U path fpath

# Add local paths
path=("$HOME/scripts" "$HOME/local/bin" $path)

# If there is a local zsh-completions repo, add it to fpath
[ -d /usr/local/share/zsh-completions ] && \
    fpath=(/usr/local/share/zsh-completions $fpath)

# Add local fpaths
prepend_fpaths=(~/.zshfunctions ~/scripts/completion/zsh)
fpath=($prepend_fpaths $fpath)

# Autoload everything in prepend_fpaths
autoload_names=(${^${prepend_fpaths}}/*(N:t))
[ ${#autoload_names} -eq 0 ] || autoload -U "${autoload_names[@]}"

unset autoload_names prepend_fpaths
