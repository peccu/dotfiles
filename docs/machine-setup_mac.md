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

### Keyboard
- Caps to Control
- Control to Caps
- Key repeat : Max speed


## Apps
### Safari
- Command Click : new tab and focus
- Command Shift Click : new tab in backgroud
### Emacs
### Wave Term
