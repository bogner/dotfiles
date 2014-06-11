# unique paths.
typeset -U path fpath

# Add local paths
path=("$HOME/local/bin" "$HOME/scripts" $path)

# Add local fpaths
prepend_fpaths=(~/.zshfunctions ~/scripts/completion/zsh)
fpath=($prepend_fpaths $fpath)

# Autoload everything in prepend_fpaths
autoload_names=(${^${prepend_fpaths}}/*(N:t))
[ ${#autoload_names} -eq 0 ] || autoload -U "${autoload_names[@]}"

unset autoload_names prepend_fpaths
