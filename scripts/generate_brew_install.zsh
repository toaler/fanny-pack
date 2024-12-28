#!/bin/zsh

# Get lists of installed formulae and casks
installed_formulae=$(brew list --formula)
installed_casks=$(brew list --cask)

# Generate `brew install` commands for formulae
if [[ -n $installed_formulae ]]; then
    echo "brew install \\"
    echo "$installed_formulae" | sed 's/^/    /' | sed '$ s/$//; s/$/ \\/'
fi

# Generate `brew install --cask` commands for casks
if [[ -n $installed_casks ]]; then
    echo ""
    echo "brew install --cask \\"
    echo "$installed_casks" | sed 's/^/    /' | sed '$ s/ \\$//; s/$/ \\/'
fi

