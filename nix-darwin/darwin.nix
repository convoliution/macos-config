{ config, lib, ... }:
let
  username = "mika";
in
{
  system.primaryUser = username;

  system.defaults = {
    NSGlobalDomain = {
      # Point & Click
      "com.apple.trackpad.scaling" = 1.5;
      "com.apple.trackpad.enableSecondaryClick" = true;
      "com.apple.mouse.tapBehavior" = 1;  # tap to click

      # Scroll & Zoom
      "com.apple.swipescrolldirection" = true;  # Natural scrolling

      # Keyboard
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
    };
    trackpad  = {
      # Point & Click
      FirstClickThreshold = 0;            # Light Click
      ActuationStrength = 0;              # Quiet Click
      ForceSuppressed = true;             # disable Force Click
      TrackpadThreeFingerTapGesture = 0;  # disable Look up & data detectors
      TrackpadCornerSecondaryClick = 0;   # two-finger secondary click
      Clicking = true;                    # tap to click

      # Scroll & Zoom
      TrackpadPinch = true;                       # Zoom in or out
      TrackpadTwoFingerDoubleTapGesture = false;  # Smart zoom
      TrackpadRotate = false;

      # More Gestures
      TrackpadThreeFingerHorizSwipeGesture = 0;
      TrackpadFourFingerHorizSwipeGesture = 2;        # Swipe between full-screen applications
      TrackpadTwoFingerFromRightEdgeSwipeGesture = 0; # disable two-finger Notification Center swipe
      TrackpadFourFingerVertSwipeGesture = 2;         # four-finger Mission Control swipe
      TrackpadFourFingerPinchGesture = 2;             # four-finger Desktop spread
    };
    dock = {
      # four-finger swipe gestures
      showMissionControlGestureEnabled = true;
      showAppExposeGestureEnabled = false;

      # four-finger spread/pinch gestures
      showDesktopGestureEnabled = true;
      showLaunchpadGestureEnabled = false;

      # Dock
      magnification = false;
      orientation = "left";
      minimize-to-application = false;
      autohide = true;
      launchanim = true;
      show-process-indicators = true;
      show-recents = false;

      mru-spaces = false;
    };
    WindowManager = {
      EnableStandardClickToShowDesktop = false;
    };
  };

  programs = {
    bash.enable = false;
    zsh.enable = false;
  };
}
