# dotfiles

My i3, Hyprland, Neovim, tmux, Kitty, Yazi, and bash configs are organized as GNU Stow packages. From this directory, link a package into your home directory with:

```sh
stow <package>
```

For example, `stow hyprland` creates `~/.config/hypr` from `hyprland/.config/hypr` when the target path is available. Existing configuration directories need to be backed up or moved before Stow can create that link.
