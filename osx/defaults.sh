#!/bin/bash

# ~/.osx — http://mths.be/osx

###############################################################################
# Ryan's Random Additions                                                     #
###############################################################################

# keep textedit and ilk from opening that super annoying "open files on iCloud"
# window rather than starting with a blank document.
defaults write -g NSShowAppCentricOpenPanelInsteadOfUntitledFile -bool false

# https://mmazzarolo.com/blog/2022-04-16-drag-window-by-clicking-anywhere-on-macos/
# cmd+ctrl to click-to-drag any part of a window.
defaults write -g NSWindowShouldDragOnGesture -bool true


# https://news.ycombinator.com/item?id=24391899
sudo spctl developer-mode enable-terminal

# TODO: update from https://github.com/mathiasbynens/dotfiles/blob/master/.macos

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Menu bar: disable transparency
defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool false

# Menu bar: show remaining battery time; hide percentage
defaults write com.apple.menuextra.battery ShowPercent -string "NO"
defaults write com.apple.menuextra.battery ShowTime -string "YES"

# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Disable opening and closing window animations
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Increase window resize speed for Cocoa applications
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Display ASCII control characters using caret notation in standard text views
# Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

# Disable Resume system-wide
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

# Disable automatic termination of inactive apps
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# Fix for the ancient UTF-8 bug in QuickLook (http://mths.be/bbo)
# Commented out, as this is known to cause problems when saving files in Adobe Illustrator CS5 :(
#echo "0x08000100:0" > ~/.CFUserTextEncoding

###############################################################################
# Trackpad, mouse, keyboard, and input                                        #
###############################################################################

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Trackpad: map bottom right corner to right-click
# NNNNOOOOOO
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
# defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
# defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

# Trackpad: swipe between pages with three fingers
# NNOOOOO
# defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true
# defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerHorizSwipeGesture -int 1
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 1

# Disable “natural” (Lion-style) scrolling
# effyou, I like it
# defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

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

# Disable auto-correct
# thank you, jesus
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

###############################################################################
# Screen                                                                      #
###############################################################################

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "$HOME/Desktop"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Enables "x-ray" views into quick-look-ed folders (so you can see stuff inside them)
defaults write com.apple.finder QLEnableXRayFolders 1

# Disable shadow in screenshots
# I like 'em
#defaults write com.apple.screencapture disable-shadow -bool true

# Enable subpixel font rendering on non-Apple LCDs
defaults write NSGlobalDomain AppleFontSmoothing -int 2

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

# Finder: allow text selection in Quick Look
defaults write com.apple.finder QLEnableTextSelection -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Disable disk image verification
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Show item info below desktop icons
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist

# Enable snap-to-grid for desktop icons
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Empty Trash securely by default
# no, I value convenience over security
# defaults write com.apple.finder EmptyTrashSecurely -bool true

# Enable AirDrop over Ethernet and on unsupported Macs running Lion
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# Show the ~/Library folder
# ya!  
chflags nohidden ~/Library

# Remove Dropbox’s green checkmark icons in Finder
# No, it makes me happy
# file=/Applications/Dropbox.app/Contents/Resources/check.icns
# [ -e "$file" ] && mv -f "$file" "$file.bak"
# unset file


# http://osxdaily.com/2010/03/29/disable-the-are-you-sure-you-want-to-open-this-file-warning-dialogue-in-mac-os-x/
# Disable the "are you sure you want to open what you said you just
# wanted to open?" dialogue
defaults write com.apple.LaunchServices LSQuarantine -bool NO


###############################################################################
# Dock & hot corners                                                          #
###############################################################################

# Enable highlight hover effect for the grid view of a stack (Dock)
defaults write com.apple.dock mouse-over-hilte-stack -bool true

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

# Remove the auto-hiding Dock delay
defaults write com.apple.Dock autohide-delay -float 0
# Change dock hiding speed (I think this is seconds)
defaults write com.apple.dock autohide-time-modifier -float 0.5

# Enable the 2D Dock
# no, I like the cheeze
# defaults write com.apple.dock no-glass -bool true

# Automatically hide and show the Dock
# fuck you, no
# defaults write com.apple.dock autohide -bool true

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

# Enable iTunes track notifications in the Dock
# 	RT: this seems to crash Dock.app on Lion
# 	https://discussions.apple.com/thread/3981604?start=0&tstart=0
# defaults write com.apple.dock itunes-notifications -bool true
defaults delete com.apple.dock itunes-notifications

# Reset Launchpad
find ~/Library/Application\ Support/Dock -name "*.db" -maxdepth 1 -delete

# Add a spacer to the left side of the Dock (where the applications are)
#defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
# Add a spacer to the right side of the Dock (where the Trash is)
#defaults write com.apple.dock persistent-others -array-add '{tile-data={}; tile-type="spacer-tile";}'

# Hot corners
# I don't like these choices; I swap the corners.  But I'm too lazy to figure out which ones I use
# # Top left screen corner → Mission Control
# defaults write com.apple.dock wvous-tl-corner -int 2
# defaults write com.apple.dock wvous-tl-modifier -int 0
# # Top right screen corner → Desktop
# defaults write com.apple.dock wvous-tr-corner -int 4
# defaults write com.apple.dock wvous-tr-modifier -int 0
# # Bottom left screen corner → Start screen saver
# defaults write com.apple.dock wvous-bl-corner -int 5
# defaults write com.apple.dock wvous-bl-modifier -int 0

###############################################################################
# Safari & WebKit & Chrome                                                    #
###############################################################################

# Disable Safari’s thumbnail cache for History and Top Sites
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

# Enable Safari’s debug menu
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# Make Safari’s search banners default to Contains instead of Starts With
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

# Remove useless icons from Safari’s bookmarks bar
defaults write com.apple.Safari ProxiesInBookmarksBar "()"

# Add a context menu item for showing the Web Inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Allow Kerberos delegation in Chrome to *.amazon.com (internal websites!)
defaults write com.google.Chrome AuthServerWhitelist '*amazon.com'

###############################################################################
# Address Book, Dashboard, iCal, iTunes, Mail, and Disk Utility               #
###############################################################################

# Enable the debug menu in Address Book
defaults write com.apple.addressbook ABShowDebugMenu -bool true

# Enable Dashboard dev mode (allows keeping widgets on the desktop)
defaults write com.apple.dashboard devmode -bool true

# Enable the debug menu in iCal
defaults write com.apple.iCal IncludeDebugMenu -bool true

# Make the iTunes arrow links go to your library instead of the iTunes Store
defaults write com.apple.iTunes invertStoreLinks -bool true

# Disable the iTunes arrow links completely
# nah, they can stay
# defaults write com.apple.iTunes show-store-arrow-links -bool false

# Disable the Ping sidebar in iTunes
# YES!
defaults write com.apple.iTunes disablePingSidebar -bool true

# Disable all the other Ping stuff in iTunes
# YES YES YES
defaults write com.apple.iTunes disablePing -bool true

# Make ⌘ + F focus the search input in iTunes
# omgiloveyou
defaults write com.apple.iTunes NSUserKeyEquivalents -dict-add "Target Search Field" "@F"

# Disable send and reply animations in Mail.app
defaults write com.apple.Mail DisableReplyAnimations -bool true
defaults write com.apple.Mail DisableSendAnimations -bool true

# TODO: refer to some of the goodies here:
# https://github.com/mathiasbynens/dotfiles/blob/master/.osx

# Enable easier copy/pasting of email addresses in Mail.app
# Instead of copying 
#     Ryan Timmons <foo@bar.com>
# you copy
#     foo@bar.com
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool NO

# Disable the annoying data detectors that make it tough to copy/paste contact/address/phone/date info
defaults write com.apple.mail DisableDataDetectors YES 

# Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in Mail.app
# praise the lord
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# Enable the debug menu in Disk Utility
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true

###############################################################################
# Terminal                                                                    #
###############################################################################

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# Enable “focus follows mouse” for Terminal.app and all X11 apps
# This means you can hover over a window and start typing in it without clicking first
#defaults write com.apple.terminal FocusFollowsMouse -bool true
#defaults write org.x.X11 wm_ffm -bool true

###############################################################################
# Hogbay FoldingText                                                          #
###############################################################################

defaults write com.foldingtext.FoldingText ShowWelcomeText -bool false

###############################################################################
# Time Machine                                                                #
###############################################################################

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Disable local Time Machine backups
# nah, go ahead
# hash tmutil &> /dev/null && sudo tmutil disablelocal

###############################################################################
# Omni Plan                                                                   #
###############################################################################

# Use escape to end / toggle editing
defaults write com.omnigroup.OmniPlan.MacAppStore \
    OOShouldToggleEditingWithEscapeKey -bool true

###############################################################################
# Kill affected applications                                                  #
###############################################################################

for app in Finder Dock Mail Safari iTunes iCal Address\ Book SystemUIServer; do
    killall "$app" > /dev/null 2>&1
done

echo "Done. Note that some of these changes require a logout/restart to take effect."
