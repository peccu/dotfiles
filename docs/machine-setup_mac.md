# Setup mac

## OS Settings
### Display resolution

### Dock
- Magnification : On
- Size : Small (40) to Large (Max: 128)
```zsh
defaults read com.apple.dock magnification
defaults read com.apple.dock tilesize
defaults read com.apple.dock largesize
```
```zsh
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock tilesize -int 40
defaults write com.apple.dock largesize -int 128
kllall Dock
```

### Trackpad
- Tap to click
- Two finger tap to right click
- More gestures are assigned to four fingers
- Three fingers for dragging
    - (Accesibility > Pointer Control > Trackpad Options > Use trackpad for dragging = on, Dragging style = Three Finger Drag)
- Three finger tap to Look up

```zsh
defaults read com.apple.AppleMultitouchTrackpad
```

```zsh
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -int 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 0
```

### Pointer size

middle

### Keyboard
- Caps to Control
- Control to Caps
- Key repeat : Max speed


## Apps
### Safari
- Command Click : new tab and focus
- Command Shift Click : new tab in backgroud

### Homebrew

for Emacs and git-credential-manager etc.

[Homebrew — The Missing Package Manager for macOS (or Linux)](https://brew.sh/)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

```zsh
echo >> /Users/peccu/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/peccu/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Emacs
needs homebrew to reduce flickering.

[railwaycat/homebrew-emacsmacport: Emacs mac port formulae for the Homebrew package manager](https://github.com/railwaycat/homebrew-emacsmacport)

```
brew tap railwaycat/emacsmacport
brew install --cask emacs-mac
```

installed into /Applications/Emacs.app

### git credential-manager

[git-credential-manager/docs/install.md at release · git-ecosystem/git-credential-manager](https://github.com/git-ecosystem/git-credential-manager/blob/release/docs/install.md)

```
brew install --cask git-credential-manager
```

- some configs are added

```
credential.helper=osxkeychain
init.defaultbranch=main
credential.helper=
credential.helper=/usr/local/share/gcm-core/git-credential-manager
credential.https://dev.azure.com.usehttppath=true
```

```
% cat ~/.gitconfig
[credential]
        helper =
        helper = /usr/local/share/gcm-core/git-credential-manager
[credential "https://dev.azure.com"]
        useHttpPath = true
```

### Wave Term
[Wave Terminal — Upgrade Your Command Line](https://www.waveterm.dev/)

### WezTerm
[WezTerm - Wez's Terminal Emulator](https://wezterm.org/index.html)

### nix

### Tailscale
[Tailscale · Best VPN Service for Secure Networks](https://tailscale.com/)

install app from [Mac App Store](https://apps.apple.com/jp/app/tailscale/id1475387142?l=en-US&mt=12)

### dot files (with chezmoi)

[peccu/dotfiles: my dot files](https://github.com/peccu/dotfiles)

```
curl -fsLS bit.ly/dot-ini | bash
# move binary to PATH
sudo mv chezmoi /usr/local/bin/
# check difference before apply
chezmoi apply -vn | less
# apply
chezmoi apply -v
```
