{
  pkgs,
  username,
  hostname,
  ...
}: {
  environment = {
    systemPackages = with pkgs; [
      git
      nixd
      mas
      kitty
      alejandra
      _1password-cli
    ];
    variables = {
      EDITOR = "nvim";
      CLICOLOR = "1";
    };
    shells = [
      pkgs.zsh
    ];
  };

  fonts.packages = with pkgs; (map (n: nerd-fonts.${n}) [
    "fira-code"
    "jetbrains-mono"
    "meslo-lg"
    "symbols-only"
    "droid-sans-mono"
  ]);

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true; # Fetch the newest stable branch of Homebrew's git repo
      upgrade = true; # Upgrade outdated casks, formulae, and App Store apps
      # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
      cleanup = "zap";
    };

    masApps = {
      # Xcode = 497799835;
      #"AdGuard" = 1440147259;
      #"1Password for Safari" = 1569813296;
    };

    taps = [
      #"homebrew/services"
      #"1password/tap"
      #"homebrew/1password-cli"
    ];

    # `brew install`
    # TODO Feel free to add your favorite apps here.
    brews = [
      #"wget" # download tool
      #"curl" # no not install curl via nixpkgs, it's not working well on macOS!
    ];

    # `brew install --cask`
    # TODO Feel free to add your favorite apps here.
    casks = [
      #"1password"
      "adguard"
      #"visual-studio-code"
      "protonvpn"
      "proton-drive"
      "obsidian"
      "alt-tab"
      "discord"

      # Development
      "wireshark" # network analyzer
      #"1password-cli"
    ];
  };

  networking = {
    hostName = hostname;
    computerName = hostname;
  };

  nix = {
    enable = false;
    package = pkgs.nix;
    settings = {
      auto-optimise-store = false;
      experimental-features = ["nix-command" "flakes"];
      trusted-users = [username];
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs = {
    zsh.enable = true;
    _1password = {
      enable = true;
    };
    _1password-gui = {
      enable = true;
    };
    ssh = {
      extraConfig = ''
        Host *
        	IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
      '';
    };
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    primaryUser = "${username}";

    stateVersion = 5;

    defaults = {
      menuExtraClock.Show24Hour = true; # show 24 hour clock
      smb.NetBIOSName = hostname;
      # customize dock
      dock = {
        autohide = false;
        show-recents = true; # disable recent apps

        # customize Hot Corners
        wvous-tl-corner = 2; # mission control
        wvous-bl-corner = 1; # disabled
        wvous-tr-corner = 4; # desktop
        wvous-br-corner = 1; # disabled
      };
      controlcenter = {
        Bluetooth = true;
      };
      # customize finder
      finder = {
        _FXShowPosixPathInTitle = true; # show full path in finder title
        AppleShowAllExtensions = true; # show all file extensions
        FXEnableExtensionChangeWarning = false; # disable warning when changing file extension
        QuitMenuItem = true; # enable quit menu item
        ShowPathbar = true; # show path bar
        ShowStatusBar = true; # show status bar
      };

      # customize trackpad
      trackpad = {
        # tap, click
        Clicking = true; # enable tap to click
        TrackpadRightClick = true; # enable two finger right click
        TrackpadThreeFingerDrag = false; # enable three finger drag
      };

      # customize settings that not supported by nix-darwin directly
      # Incomplete list of macOS `defaults` commands :
      #   https://github.com/yannbertrand/macos-defaults
      NSGlobalDomain = {
        # Whether to always show hidden files
        AppleShowAllFiles = true;
        # Whether to automatically switch between light and dark mode
        AppleInterfaceStyleSwitchesAutomatically = true;
        # Whether to show all file extensions in Finder
        AppleShowAllExtensions = true;

        AppleShowScrollBars = "WhenScrolling";
        # `defaults read NSGlobalDomain "xxx"`
        "com.apple.swipescrolldirection" = true; # enable natural scrolling(default to true)
        "com.apple.sound.beep.feedback" = 0; # disable beep sound when pressing volume up/down key
        # AppleInterfaceStyle = "Dark";  # dark mode
        # Sets the beep/alert volume level from 0.000 (muted) to 1.000 (100% volume).
        "com.apple.sound.beep.volume" = 0.4723665; # 25%
        # If you press and hold certain keyboard keys when in a text area, the key’s character begins to repeat.
        # This is very useful for vim users, they use `hjkl` to move cursor.
        # sets how long it takes before it starts repeating.
        InitialKeyRepeat = 15; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)
        # sets how fast it repeats once it starts.
        KeyRepeat = 3; # normal minimum is 2 (30 ms), maximum is 120 (1800 ms)

        NSAutomaticCapitalizationEnabled = false; # disable auto capitalization
        NSAutomaticDashSubstitutionEnabled = false; # disable auto dash substitution
        NSAutomaticPeriodSubstitutionEnabled = false; # disable auto period substitution
        NSAutomaticQuoteSubstitutionEnabled = false; # disable auto quote substitution
        NSAutomaticSpellingCorrectionEnabled = false; # disable auto spelling correction
        NSNavPanelExpandedStateForSaveMode = true; # expand save panel by default
        NSNavPanelExpandedStateForSaveMode2 = true;
        _HIHideMenuBar = true;
      };

      # Customize settings that not supported by nix-darwin directly
      # see the source code of this project to get more undocumented options:
      #    https://github.com/rgcr/m-cli
      #
      # All custom entries can be found by running `defaults read` command.
      # or `defaults read xxx` to read a specific domain.
      CustomUserPreferences = {
        #"com.apple.Safari" = {
        #  AutoOpenSafeDownloads = false;
        #};
        ".GlobalPreferences" = {
          # automatically switch to a new space when switching to the application
          AppleSpacesSwitchOnActivate = true;
        };
        NSGlobalDomain = {
          # Add a context menu item for showing the Web Inspector in web views
          WebKitDeveloperExtras = true;
        };
        "com.apple.finder" = {
          ShowExternalHardDrivesOnDesktop = true;
          ShowHardDrivesOnDesktop = true;
          ShowMountedServersOnDesktop = true;
          ShowRemovableMediaOnDesktop = true;
          _FXSortFoldersFirst = true;
          # When performing a search, search the current folder by default
          FXDefaultSearchScope = "SCcf";
          # Set home directory as startup window
          NewWindowTargetPath = "file:///Users/${username}/";
          NewWindowTarget = "PfHm";
          # Multi-file tab view
          FinderSpawnTab = true;
        };
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.spaces" = {
          "spans-displays" = 0; # Display have seperate spaces
        };
        "com.apple.WindowManager" = {
          EnableStandardClickToShowDesktop = 1; # Click wallpaper to reveal desktop
          StandardHideDesktopIcons = 1; # Show items on desktop
          HideDesktop = 0; # Do not hide items on desktop & stage manager
          StageManagerHideWidgets = 0;
          StandardHideWidgets = 0;
        };
        "com.apple.screensaver" = {
          # Require password immediately after sleep or screen saver begins
          askForPassword = 1;
          askForPasswordDelay = 0;
        };
        "com.apple.screencapture" = {
          location = "~/Desktop";
          type = "png";
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        # Prevent Photos from opening automatically when devices are plugged in
        "com.apple.ImageCapture".disableHotPlug = true;
        # Safari show url on hover
        #"com.apple.Safari" = {
        #  ShowStatusBar = true;
        #};
        "com.apple.SoftwareUpdate" = {
          AutomaticCheckEnabled = true;
          # Check for software updates daily, not just once per week
          ScheduleFrequency = 1;
          # Download newly available updates in background
          AutomaticDownload = 0;
          # Install System data files & security updates
          CriticalUpdateInstall = 1;
        };
      };

      loginwindow = {
        GuestEnabled = false; # disable guest user
        SHOWFULLNAME = true; # show full name in login window
      };
    };

    # keyboard settings is not very useful on macOS
    # the most important thing is to remap option key to alt key globally,
    # but it's not supported by macOS yet.
    keyboard = {
      enableKeyMapping = true; # enable key mapping so that we can use `option` as `control`

      # NOTE: do NOT support remap capslock to both control and escape at the same time
      remapCapsLockToControl = false; # remap caps lock to control, useful for emac users
      remapCapsLockToEscape = true; # remap caps lock to escape, useful for vim users

      # swap left command and left alt
      # so it matches common keyboard layout: `ctrl | command | alt`
      #
      # disabled, caused only problems!
      swapLeftCommandAndLeftAlt = false;
      swapLeftCtrlAndFn = true;
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;
  };
}
