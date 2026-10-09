#!/bin/bash

# macOS preferences. Run manually; some changes require logging out and back in.
# Selected settings from https://github.com/mathiasbynens/dotfiles/blob/main/.macos

set -euo pipefail

###############################################################################
# Ryan's Random Additions                                                     #
###############################################################################

# keep textedit and ilk from opening that super annoying "open files on iCloud"
# window rather than starting with a blank document.
defaults write -g NSShowAppCentricOpenPanelInsteadOfUntitledFile -bool false

# https://mmazzarolo.com/blog/2022-04-16-drag-window-by-clicking-anywhere-on-macos/
# cmd+ctrl to click-to-drag any part of a window.
defaults write -g NSWindowShouldDragOnGesture -bool true

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Disable opening and closing window animations
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Increase window resize speed for Cocoa applications
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Display ASCII control characters using caret notation in standard text views
# Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

# Disable Resume system-wide
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

# Disable automatic termination of inactive apps
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

###############################################################################
# Trackpad, mouse, keyboard, and input                                        #
###############################################################################

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
# godyes
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 1

# Set language and text formats
# Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
# `Inches`, and `true` with `false`.
defaults write NSGlobalDomain AppleLanguages -array "en"
defaults write NSGlobalDomain AppleLocale -string "en_US@currency=USD"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Inches"
defaults write NSGlobalDomain AppleMetricUnits -bool false

# Keep typed text literal
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

###############################################################################
# Screen                                                                      #
###############################################################################

# Configure password-on-wake in System Settings > Lock Screen.
# Legacy com.apple.screensaver writes do not verify the current lock policy.

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "$HOME/Desktop"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

###############################################################################
# Finder                                                                      #
###############################################################################

# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Finder: disable window animations and Get Info animations
defaults write com.apple.finder DisableAllAnimations -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Show the path bar, sort folders first, and search the current folder.
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Update a preferences snapshot so cfprefsd sees the changes. Preserve other keys.
set_desktop_icon_preferences() {
    local plist="$1" key
    for key in :DesktopViewSettings :DesktopViewSettings:IconViewSettings; do
        if ! /usr/libexec/PlistBuddy -c "Print $key" "$plist" >/dev/null 2>&1; then
            /usr/libexec/PlistBuddy -c "Add $key dict" "$plist"
        fi
    done
    key=":DesktopViewSettings:IconViewSettings:showItemInfo"
    if /usr/libexec/PlistBuddy -c "Print $key" "$plist" >/dev/null 2>&1; then
        /usr/libexec/PlistBuddy -c "Set $key true" "$plist"
    else
        /usr/libexec/PlistBuddy -c "Add $key bool true" "$plist"
    fi
    key=":DesktopViewSettings:IconViewSettings:arrangeBy"
    if /usr/libexec/PlistBuddy -c "Print $key" "$plist" >/dev/null 2>&1; then
        /usr/libexec/PlistBuddy -c "Set $key grid" "$plist"
    else
        /usr/libexec/PlistBuddy -c "Add $key string grid" "$plist"
    fi
}

finder_plist="$(mktemp -t finder-preferences.XXXXXX)"
trap 'rm -f "$finder_plist"' EXIT
defaults export com.apple.finder "$finder_plist"
set_desktop_icon_preferences "$finder_plist"
defaults import com.apple.finder "$finder_plist"
rm -f "$finder_plist"
trap - EXIT

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Show the ~/Library folder
chflags nohidden ~/Library

###############################################################################
# Dock & hot corners                                                          #
###############################################################################

# Enable highlight hover effect for the grid view of a stack (Dock)
defaults write com.apple.dock mouse-over-hilite-stack -bool true

# Set the icon size of Dock items to 45 pixels
defaults write com.apple.dock tilesize -int 45

# Enable spring loading for all Dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Don’t animate opening applications from the Dock
defaults write com.apple.dock launchanim -bool false

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Keep Spaces in a stable order and hide recent apps in the Dock.
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock show-recents -bool false

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0
# Change dock hiding speed (I think this is seconds)
defaults write com.apple.dock autohide-time-modifier -float 0.5

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

###############################################################################
# Safari & WebKit & Chrome                                                    #
###############################################################################

# Add a context menu item for showing the Web Inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

###############################################################################
# Mail                                                                        #
###############################################################################

# Disable send and reply animations in Mail.app
defaults write com.apple.mail DisableReplyAnimations -bool true
defaults write com.apple.mail DisableSendAnimations -bool true

# Disable the annoying data detectors that make it tough to copy/paste contact/address/phone/date info
defaults write com.apple.mail DisableDataDetectors -bool true

# Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in Mail.app
# praise the lord
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

###############################################################################
# Terminal                                                                    #
###############################################################################

# Only use UTF-8 in Terminal.app
defaults write com.apple.Terminal StringEncodings -array 4

###############################################################################
# Time Machine                                                                #
###############################################################################

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

printf '%s\n' "Preferences saved. Log out and back in to apply all changes."
printf '%s\n' "Verify System Settings > Lock Screen requires a password immediately."
