if status is-interactive
    eval (zellij setup --generate-auto-start fish | string collect)
end

set -gx GOPATH $HOME/go

alias n="nvim ."
