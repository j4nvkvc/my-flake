{
  pkgs,
  username,
  useremail,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    localVariables = {
      POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = true;
    };
    initContent = ''
      export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';
    initExtra = ''
      bindkey -e
      bindkey '^[[A' up-line-or-search
      bindkey '^[[B' down-line-or-search
      #${pkgs.coreutils}/bin/dircolors
      #bindkey '^A' beginning-of-line
      #bindkey '^E' end-of-line
      eval "$(/opt/homebrew/bin/brew shellenv)"
      source <(op completion zsh)
    '';
    syntaxHighlighting.enable = true;
    shellAliases = {
      ip = "ip -br -c";
      sl = "ls";
      systemInstalled = "nix-store --query --requisites /run/current-system | cut -d- -f2- | sort | uniq";
      installedall = "nix-store --query --requisites /run/current-system";
      cleanup = "sudo nix-collect-garbage --delete-older-than 1d";
      listgen = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
      nixformat = "nixformat () {  find . -type f -name '*.nix' -print -exec nixfmt \${@:-} -v {} ; ;}; nixformat";
    };
    #setOptions = [ "HIST_STAMPS='dd.mm.yyyy'" ];
    history = {
      #extended = true;
      #ignoreAllDups = true;
      ignoreSpace = true;
      ignorePatterns = [
        "cd *"
        "ls"
        "sl"
        "*ls*"
        "pkill *"
        "history"
        "ccccc*" # YubiKey fail
        # "[.]+" # Cd ....
      ];
    };
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = ./p10k-config;
        file = "p10k.zsh";
      }
      {
        name = "zsh-fzf-tab";
        file = "fzf-tab.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "0c36bdcf6a80ec009280897f07f56969f94d377e";
          sha256 = "0ymp9ky0jlkx9b63jajvpac5g3ll8snkf8q081g0yw42b9hwpiid";
        };
      }
    ];
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfig = ''
      highlight Normal guibg=NONE ctermbg=NONE
      highlight NormalFloat guibg=NONE ctermbg=NONE
      set mouse=r
      set mouse=nicr
      syntax on
      set number
      set relativenumber
      set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,eol:¶,precedes:«,extends:»

      " Activer la coloration syntaxique pour les fichiers Nix
      autocmd BufRead,BufNewFile *.nix set filetype=nix
      colorscheme vim
    '';
    plugins = with pkgs.vimPlugins; [
      vim-nix
      vim-yaml
    ];
  };
  programs.kitty = {
    enable = true;
    settings = {
      # customization stuff
      background_opacity = 0.7;
      background_blur = 50;
      window_padding_width = 20;
      ihide_window_decorations = "titlebar-only";
      font_size = 16;
    };
  };
  programs.git = {
    enable = true;
    userName = username;
    userEmail = useremail;
  };
  programs.vscode = {
    enable = true;
  };
  programs.home-manager.enable = true;
  home = {
    sessionVariables = {
      EDITOR = "nvim";
    };
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.05";
    packages = with pkgs; [
      # archives
      zip
      xz
      unzip
      p7zip

      # utils
      ripgrep # recursively searches directories for a regex pattern
      jq # A lightweight and flexible command-line JSON processor
      yq-go # yaml processer https://github.com/mikefarah/yq
      fzf # A command-line fuzzy finder

      aria2 # A lightweight multi-protocol & multi-source command-line download utility
      socat # replacement of openbsd-netcat
      nmap # A utility for network discovery and security auditing

      # misc
      cowsay
      file
      which
      tree
      gnused
      gnutar
      gawk
      zstd
      caddy
      gnupg
      tig

      # productivity
      glow # markdown previewer in terminal
    ];
  };
}
