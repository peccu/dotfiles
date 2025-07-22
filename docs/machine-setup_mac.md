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
- Point & Click
    - Fastest Tracking speed
    - Lookup & data detectors : Tap with Three Fingers
    - Secondary click : Click or Tap with Two Fingers
    - Tap to click
- More gestures
    - App Exposé : Swipe Down with Four Fingers
- Three fingers for dragging
    - (Accesibility > Pointer Control > Trackpad Options > Use trackpad for dragging = on, Dragging style = Three Finger Drag)

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

#### Shortcut keys
- Mission Control
    - disable `C-<up>`, `C-<down>`
- Keyboard
    - Move focus to next window `Command-@` to `Command-f2`
- Input Sources
    - Select the previous input source `Command-Space`
- Screenshots
    - Disable "Screenshot and recording options" `S-Command-5`
        - for Emacs query-replace
- Spotlight
    - Show Spotlight search to `option-Space`
- Function Keys
    - check Use F1, F2, etc. keys as standard function keys
- Modifier Keys
    - Swap Caps Lock to Control key

## Apps
### Safari
- Command Click : new tab and focus
- Command Shift Click : new tab in backgroud

- [Keys](https://apps.apple.com/jp/app/keys-for-safari/id1494642810?l=en-US) for Safari

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
open -a /usr/local/opt/emacs-mac/Emacs.app
```

installed into /Applications/Emacs.app

### .emacs.d

```
cd
git clone https://github.com/peccu/dot.emacs.d.git .emacs.d
git submodule update -i
```

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

configs are in `~/.wezterm.lua` which is managed in chezmoi.

### nix

- install nix
    - using https://github.com/DeterminateSystems/nix-installer
    - `curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install macos --nix-build-user-id-base 350`

```
% curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install macos --nix-build-user-id-base 350
info: downloading installer https://install.determinate.systems/nix/tag/v0.22.0/nix-installer-x86_64-darwin
`nix-installer` needs to run as `root`, attempting to escalate now via `sudo`...
Confirm Execution: This Sudo Command requires admin rights. Are you sure you wish to proceed?
Yes/No: yes
Nix install plan (v0.22.0)
Planner: macos

Configured settings:
* nix_build_user_id_base: 350
* root_disk: null
* volume_encrypt: false

Planned actions:
* Create an APFS volume `Nix Store` for Nix on `disk1` and add it to `/etc/fstab` mounting on `/nix`
* Extract the bundled Nix (originally from /nix/store/7s882nn1dznglc1c3raji50kzgj0mqhh-nix-binary-tarball-2.24.4/nix-2.24.4-x86_64-darwin.tar.xz)
* Create a directory tree in `/nix`
* Move the downloaded Nix into `/nix`
* Create build users (UID 351-382) and group (GID 30000)
* Configure Time Machine exclusions
* Setup the default Nix profile
* Place the Nix configuration in `/etc/nix/nix.conf`
* Configure the shell profiles
* Configuring zsh to support using Nix in non-interactive shells
* Create a `launchctl` plist to put Nix into your PATH
* Configure upstream Nix daemon service
* Remove directory `/nix/temp-install-dir`


Proceed? ([Y]es/[n]o/[e]xplain): y
 INFO Step: Create an APFS volume `Nix Store` for Nix on `disk1` and add it to `/etc/fstab` mounting on `/nix`
 INFO Step: Provision Nix
 INFO Step: Create build users (UID 351-382) and group (GID 30000)
 INFO Step: Configure Time Machine exclusions
 INFO Step: Configure Nix
 INFO Step: Configuring zsh to support using Nix in non-interactive shells
 INFO Step: Create a `launchctl` plist to put Nix into your PATH
 INFO Step: Configure upstream Nix daemon service
 INFO Step: Remove directory `/nix/temp-install-dir`
zsh compinit: insecure directories, run compaudit for list.
Ignore insecure directories and continue [y] or abort compinit [n]? yNix was installed successfully!
To get started using Nix, open a new shell or run `. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`
```

- list packages

```
% nix profile list
Name:               colima
Flake attribute:    legacyPackages.x86_64-darwin.colima
Original flake URL: flake:nixpkgs
Locked flake URL:   github:NixOS/nixpkgs/add0443ee587a0c44f22793b8c8649a0dbc3bb00?narHash=sha256-0Kq2MkQ/sQX1rhWJ/ySBBQlBJBUK8mPMDcuDhhdBkSU%3D
Store paths:        /nix/store/mf3kyp1d5h9lcqnmdnv5di8nggywh4pp-colima-0.7.5

Name:               delta
Flake attribute:    legacyPackages.x86_64-darwin.delta
Original flake URL: flake:nixpkgs
Locked flake URL:   github:NixOS/nixpkgs/dad564433178067be1fbdfcce23b546254b6d641?narHash=sha256-vn285HxnnlHLWnv59Og7muqECNMS33mWLM14soFIv2g%3D
Store paths:        /nix/store/wwnjzwdiwhm725gfzn6w8kby33h6gszn-delta-0.18.2

Name:               docker
Flake attribute:    legacyPackages.x86_64-darwin.docker
Original flake URL: flake:nixpkgs
Locked flake URL:   github:NixOS/nixpkgs/add0443ee587a0c44f22793b8c8649a0dbc3bb00?narHash=sha256-0Kq2MkQ/sQX1rhWJ/ySBBQlBJBUK8mPMDcuDhhdBkSU%3D
Store paths:        /nix/store/pjvibzzskcry4rapsgwfka77zdi87i1v-docker-27.1.1

Name:               jq
Flake attribute:    legacyPackages.x86_64-darwin.jq
Original flake URL: flake:nixpkgs
Locked flake URL:   github:NixOS/nixpkgs/ccc0c2126893dd20963580b6478d1a10a4512185?narHash=sha256-4HQI%2B6LsO3kpWTYuVGIzhJs1cetFcwT7quWCk/6rqeo%3D
Store paths:        /nix/store/4x2l3ik7jcxp50fjydhwc79rk2gywpvy-jq-1.7.1-bin /nix/store/apn118f0m6sj8lacqia105n16zsd1kwc-jq-1.7.1-man

Name:               nodejs_22
Flake attribute:    legacyPackages.x86_64-darwin.nodejs_22
Original flake URL: flake:nixpkgs
Locked flake URL:   github:NixOS/nixpkgs/5083ec887760adfe12af64830a66807423a859a7?narHash=sha256-D1FNZ70NmQEwNxpSSdTXCSklBH1z2isPR84J6DQrJGs%3D
Store paths:        /nix/store/vh70nd2rjh0nzfqsn4iwibz1s07f4fhv-nodejs-22.10.0

Name:               skim
Flake attribute:    legacyPackages.x86_64-darwin.skim
Original flake URL: flake:nixpkgs
Locked flake URL:   github:NixOS/nixpkgs/2d55b4c1531187926c2a423f6940b3b1301399b5?narHash=sha256-NCWZQg4DbYVFWg%2BMOFrxWRaVsLA7yvRWAf6o0xPR1hI%3D
Store paths:        /nix/store/4r1dkrs7z608n00c83pr9bk7hs6dqgw7-skim-0.16.0-man /nix/store/g6cmhb3rfld31hlic9mj422sx6i0v3sr-skim-0.16.0

Name:               tmux
Flake attribute:    legacyPackages.x86_64-darwin.tmux
Original flake URL: flake:nixpkgs
Locked flake URL:   github:NixOS/nixpkgs/568bfef547c14ca438c56a0bece08b8bb2b71a9c?narHash=sha256-ZMHMThPsthhUREwDebXw7GX45bJnBCVbfnH1g5iuSPc%3D
Store paths:        /nix/store/2mpqw8j8vixpnr3k0l0kw8mif8lrry8p-tmux-3.4-man /nix/store/xi4q2ksa7c56dd7w3m9b2lgf1kh9z8rm-tmux-3.4
```

- install package

```
nix profile install nixpkgs#delta
nix profile install nixpkgs#yazi
nix profile install nixpkgs#lazygit
```

### Docker (colima)

```
colima start --vm-type=vz
```

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

#### some error?

```
Cloning into '/Users/peccu/.local/share/snip'...
remote: Repository not found.
fatal: repository 'https://gist.github.com/.git/' not found
chezmoi: .local/share/snip: /Users/peccu/.local/share/snip: exit status 128
```

You need to add gist id for the-way in `~/.config/chezmoi/chezmoi.toml`.

The ID is in [peccu’s gists](https://gist.github.com/peccu).

### hammerspoon

https://www.hammerspoon.org

configs are in `~/.hammerspoon/` which is managed in chezmoi.

### keeweb

https://github.com/keeweb/keeweb/releases

### tmux

```bash
t ()
{
    tmux attach-session $* || tmux $*
}
```

- setup tpm by `C-t I`

### Fonts

- FiraCode Nerd Font

https://www.nerdfonts.com/font-downloads

https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode

https://github.com/ryanoasis/nerd-fonts/releases

```
cd ~/Downloads/
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.tar.xz
mkdir FiraCode
cd FiraCode
tar xf ../FiraCode.tar.xz
open FiraCodeNerdFont-Retina.ttf
```
