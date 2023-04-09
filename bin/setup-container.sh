#!/usr/bin/env bash
set -o errexit -o errtrace -o nounset -o pipefail

# If SOPS config exists and is non-empty...
if [[ -s .sops.yaml ]]; then
    # Create secrets files if needed.
    if [[ ! -f etc/local/secrets.yml ]]; then
        echo "---" >etc/local/secrets.yml
        sops -e -i etc/local/secrets.yml 2>/dev/null
    fi
    if [[ ! -f etc/test/secrets.yml ]]; then
        echo "---" >etc/test/secrets.yml
        sops -e -i etc/test/secrets.yml 2>/dev/null
    fi
fi

if [[ ! -d ~/.dotfiles ]]; then
    if gum confirm "Setup dotfiles?"; then
        repo=$(gum input \
            --header="Dotfiles repo" \
            --value="twelvelabs/dotfiles")
        cmd=$(gum input \
            --header="Dotfiles install command" \
            --value="./install.sh")
        git clone "https://github.com/${repo}.git" ~/.dotfiles
        pushd ~/.dotfiles
        "${cmd}"
        popd
    else
        mkdir -p ~/.dotfiles
    fi
fi

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    if gum confirm "Create local git repo?"; then
        set -o xtrace
        git init
        git add .
        git commit -m "feat: initial commit"
        set +o xtrace
    fi
fi

if ! gh repo view --json url &>/dev/null; then
    if gum confirm "Create remote git repo?"; then
        echo "Repo visibility:"
        visibility=$(gum choose public private internal)
        echo "Repo description:"
        description=$(gum input)

        set -o xtrace
        gh repo create "twelvelabs/dv-api" \
            "--${visibility}" \
            --description="${description}" \
            --push \
            --source=.
        set +o xtrace
    fi
fi
