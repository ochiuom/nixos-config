{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ./modules/home/desktop-quote
    ./modules/home/gnome-extensions.nix
    ./modules/home/themes.nix
  ];

  # ── Identity ──────────────────────────────────────────────────────────────
  home.username      = "ochinix";
  home.homeDirectory = "/home/ochinix";
  home.stateVersion  = "26.05";

  # ── Packages ──────────────────────────────────────────────────────────────
  # Programs that have their own programs.* block below are NOT listed here.
  # Everything here is a plain binary with no HM config needed.
  home.packages = with pkgs; [
    # Shell utilities
    fd ripgrep eza dust duf bandwhich gping aria2 rsync p7zip
    fastfetch blesh pipx

    # TUI / interactive
    btop navi broot lazygit delta

    # Media
    easyeffects weylus xournalpp audacious audacious-plugins audacity
    cmus yt-dlp

    # Desktop / GUI
    warp-terminal tigervnc remmina zed-editor carapace
   	 
 ];

  # ── Declarative config files ───────────────────────────────────────────────
  # Using home.file instead of activation cp scripts so HM tracks changes
  # and rolls them back with generations.

  home.file.".config/kitty" = {
    source    = ./kitty;
    recursive = true;
  };

  home.file.".config/starship.toml".source = ./starship/starship.toml;

  home.file.".config/easyeffects/output" = {
    source    = ./easyeffects/output;
    recursive = true;
  };

  home.file.".config/easyeffects/irs" = {
    source    = ./easyeffects/irs;
    recursive = true;
  };

  home.file.".config/mpd/mpd.conf".source = ./mpd/mpd.conf;

  home.file.".config/organize/config.yaml".source = ./organize/config.yaml;

  home.file.".local/share/fonts" = {
    source    = ./fonts;
    recursive = true;
  };

  home.file.".sage/init.sage".text = ''
    import matplotlib as mpl
    mpl.rcParams.update({
        'font.family': 'serif',
        'font.size': 11,
        'axes.labelsize': 12,
        'figure.dpi': 300,
        'figure.figsize': (6.5, 4.5),
        'lines.linewidth': 1.5,
        'axes.linewidth': 0.8,
        'xtick.direction': 'in',
        'ytick.direction': 'in',
        'xtick.top': True,
        'ytick.right': True,
    })
  '';

  # Ghostty — kept as home.file since ghostty has no HM module yet
  home.file.".config/ghostty/config".text = ''
    window-width = 105
    window-height = 40
    window-step-resize = true
    font-family = JetBrains Mono
    font-size = 10
    cursor-style = block
    cursor-style-blink = true
    shell-integration = none 
    gtk-single-instance = true
    background = #2c2c2c
    keybind = ctrl+shift+e=new_window
    keybind = ctrl+shift+n=new_tab
  '';

  # ── Vault / working dirs ───────────────────────────────────────────────────
  home.activation.createVaultDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ~/Documents/.vault
    mkdir -p ~/Documents/Vault
    mkdir -p ~/Backups
  '';

  # ── NvChad custom lua ─────────────────────────────────────────────────────
  # Only copies if NvChad is already bootstrapped (lazy-installed externally).
  home.activation.copyNvchadCustom = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ -d ~/.local/share/nvim/lazy/NvChad ]; then
      mkdir -p ~/.config/nvim/lua/plugins
      mkdir -p ~/.config/nvim/lua/configs
      cp -rf ${./nvchad-lua/plugins}/. ~/.config/nvim/lua/plugins/
      cp -f ${./nvchad-lua/autocmds.lua}             ~/.config/nvim/lua/autocmds.lua
      cp -f ${./nvchad-lua/configs/lspconfig.lua}    ~/.config/nvim/lua/configs/lspconfig.lua
    fi
  '';

  # ── Font cache ────────────────────────────────────────────────────────────
  home.activation.refreshFontCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${pkgs.fontconfig}/bin/fc-cache -f
  '';

  # ── Path ──────────────────────────────────────────────────────────────────
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
  ];

  # ── GNOME dconf ───────────────────────────────────────────────────────────
  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [
        "scale-monitor-framebuffer"
        "xwayland-native-scaling"
      ];
      edge-tiling        = true;
      dynamic-workspaces = true;
      center-new-windows = false;
    };

    "org/gnome/desktop/interface" = {
      font-name           = lib.mkForce "Inter 12";
      document-font-name  = lib.mkForce "Noto Sans 11";
      monospace-font-name = lib.mkForce "JetBrainsMono Nerd Font 10";
      color-scheme        = "prefer-dark";
      enable-animations   = true;
      text-scaling-factor = 1.0;
      scaling-factor      = lib.hm.gvariant.mkUint32 1;
    };

    "org/gnome/desktop/wm/preferences" = {
      titlebar-font    = lib.mkForce "Inter Bold 10";
      button-layout    = "appmenu:minimize,maximize,close";
      auto-raise       = false;
      focus-mode       = "click";
      num-workspaces   = 4;
      window-placement = "automatic";
    };

    "org/gnome/desktop/screensaver" = {
      lock-enabled = true;
      lock-delay   = lib.hm.gvariant.mkUint32 0;
    };

    "org/gnome/desktop/privacy" = {
      usb-protection            = true;
      usb-protection-level      = "lockscreen";
      report-technical-problems = false;
      send-software-usage-stats = false;
      remove-old-trash-files    = true;
      remove-old-temp-files     = true;
      old-files-age             = lib.hm.gvariant.mkUint32 7;
    };

    "org/gnome/system/location".enabled = false;

    "org/gnome/desktop/notifications".show-in-lock-screen = false;

    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        user-themes.extensionUuid
        caffeine.extensionUuid
        places-status-indicator.extensionUuid
        blur-my-shell.extensionUuid
        gsconnect.extensionUuid
        desktop-cube.extensionUuid
        burn-my-windows.extensionUuid
        impatience.extensionUuid
        compiz-windows-effect.extensionUuid
        compiz-alike-magic-lamp-effect.extensionUuid
        ddterm.extensionUuid
        search-light.extensionUuid
        space-bar.extensionUuid
        tiling-assistant.extensionUuid
        ip-finder.extensionUuid
        color-picker.extensionUuid
        compact-top-bar.extensionUuid
        #advanced-weather-companion.extensionUuid
        #astra-monitor.extensionUuid
        #tophat.extensionUuid
        gnome-40-ui-improvements.extensionUuid
        fuzzy-app-search.extensionUuid
        penguin-ai-chatbot.extensionUuid
        status-area-horizontal-spacing.extensionUuid
        tailscale-status.extensionUuid
        wallpaper-slideshow.extensionUuid
        #dash-to-panel.extensionUuid
        rounded-window-corners-reborn.extensionUuid
        open-bar.extensionUuid
        top-bar-organizer.extensionUuid
        vitals.extensionUuid
        weather-or-not.extensionUuid
        logo-menu.extensionUuid
       # dash2dock-lite.extensionUuid
        dash-to-dock.extensionUuid
        app-menu-is-back.extensionUuid
        media-controls.extensionUuid
        app-grid-wizard.extensionUuid
        "desktop-quote@ochinix"
      ];
    };

    "org/gnome/desktop/wm/keybindings" = {
      maximize              = [ "<Super>Up" ];
      unmaximize            = [ "<Super>Down" ];
      tile-left             = [ "<Super>Left" ];
      tile-right            = [ "<Super>Right" ];
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      move-to-workspace-1   = [ "<Super><Shift>1" ];
      move-to-workspace-2   = [ "<Super><Shift>2" ];
      move-to-workspace-3   = [ "<Super><Shift>3" ];
      move-to-workspace-4   = [ "<Super><Shift>4" ];
      close                 = [ "<Super>q" ];
    };

    "org/gnome/shell/keybindings".toggle-overview = [ "<Super>s" ];

    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click               = true;
      two-finger-scrolling-enabled = true;
      natural-scroll             = true;
      disable-while-typing       = true;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-timeout      = 0;
      sleep-inactive-battery-timeout = 900;
      power-button-action            = "suspend";
      ambient-enabled                = false;
    };

    "org/gnome/desktop/session".idle-delay = lib.hm.gvariant.mkUint32 0;
  };

  # ── Services ──────────────────────────────────────────────────────────────
  services.easyeffects = {
    enable = true;
    preset = "C+Cry+BE+Max";
  };

  services.mpd = {
    enable         = true;
    musicDirectory = "/home/ochinix/Music";
    # mpd.conf is managed via home.file above — do not also declare
    # extraConfig here or the two will conflict.
  };

  # Downloads organiser — runs hourly via systemd user timer
  systemd.user.services.organize-downloads = {
    Unit.Description = "Organize Downloads folder";
    Service = {
      Type      = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${config.home.homeDirectory}/.local/bin/organize run'";
    };
  };

  systemd.user.timers.organize-downloads = {
    Unit.Description = "Run organize-downloads hourly";
    Timer = {
      OnCalendar = "hourly";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  # ── Programs ──────────────────────────────────────────────────────────────

  programs.home-manager.enable = true;

  programs.neovim = {
    enable        = true;
    defaultEditor = true;
    viAlias       = true;
    vimAlias      = true;
  };

  programs.direnv = {
    enable                = true;
    enableBashIntegration = true;
    nix-direnv.enable     = true;
  };

  programs.git = {
    enable   = true;
    settings = {
      merge.conflictstyle = "diff3";
      diff.colorMoved     = "default";
    };
  };

  programs.delta = {
    enable               = true;
    enableGitIntegration = true;
    options = {
      navigate     = true;
      dark         = true;
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "TwoDark";
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        theme = {
          activeBorderColor   = [ "cyan" "bold" ];
          inactiveBorderColor = [ "white" ];
          selectedLineBgColor = [ "default" ];
        };
        showIcons        = true;
        nerdFontsVersion = "3";
      };
      git.pagers = [{
        diff      = "delta --dark --paging=never";
        staging   = "delta --dark --paging=never";
        mergeDiff = "delta --dark --paging=never";
      }];
    };
  };

  programs.fzf = {
    enable               = true;
    enableBashIntegration = true;
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--color=dark"
    ];
  };

  programs.zoxide = {
    enable               = true;
    enableBashIntegration = true;
  };

  programs.bat = {
    enable = true;
    config = {
      theme       = "TwoDark";
      italic-text = "always";
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "dracula";
      vim_keys    = true;
    };
  };

  programs.starship = {
    enable               = true;
    enableBashIntegration = true;
    # Config is managed via home.file above (starship/starship.toml)
    # so we don't declare settings here — starship will pick up the file.
  };

  programs.pay-respects = {
    enable               = true;
    enableBashIntegration = true;
  };

  programs.carapace = {
    enable               = true;
    enableBashIntegration = false; # manual load after ble.sh in initExtra
  };

  programs.broot = {
    enable               = true;
    enableBashIntegration = true;
    settings = {
      modal = true;
      skin = {
        default         = "rgb(220, 220, 220) none";
        tree            = "rgb(89, 148, 220) none";
        file            = "rgb(220, 220, 220) none";
        directory       = "rgb(89, 148, 220) none Bold";
        exe             = "rgb(147, 220, 147) none";
        link            = "rgb(220, 147, 220) none";
        pruning         = "rgb(150, 150, 150) none Italic";
        selected_line   = "none rgb(40, 40, 60)";
        char_match      = "rgb(220, 220, 100) none Bold";
        file_error      = "rgb(220, 100, 100) none";
        flag_label      = "rgb(220, 220, 220) none";
        flag_value      = "rgb(220, 147, 89) none Bold";
        input           = "rgb(220, 220, 220) none";
        status_error    = "rgb(220, 100, 100) rgb(40, 40, 40)";
        status_job      = "rgb(89, 220, 220) rgb(40, 40, 40)";
        status_normal   = "rgb(220, 220, 220) rgb(40, 40, 40)";
        status_italic   = "rgb(220, 147, 89) rgb(40, 40, 40)";
        status_bold     = "rgb(220, 220, 100) rgb(40, 40, 40) Bold";
        status_code     = "rgb(147, 220, 220) rgb(40, 40, 40)";
        status_ellipsis = "rgb(220, 220, 220) rgb(40, 40, 40)";
        scrollbar_thumb = "rgb(89, 148, 220) none";
        scrollbar_track = "rgb(40, 40, 40) none";
        help_paragraph  = "rgb(220, 220, 220) none";
        help_bold       = "rgb(220, 220, 100) none Bold";
        help_italic     = "rgb(220, 147, 89) none Italic";
        help_code       = "rgb(147, 220, 220) none";
        help_headers    = "rgb(89, 148, 220) none Bold";
      };
    };
  };

  # ── tmux ──────────────────────────────────────────────────────────────────
  # Set as the default shell command so every new terminal opens tmux.
  programs.tmux = {
    enable        = true;
    clock24       = true;
    escapeTime    = 0;
    historyLimit  = 50000;
    mouse         = true;
    # tmux-256color is the correct value for default-terminal inside tmux;
    # the xterm-256color:RGB override below keeps true-colour working.
    terminal      = "tmux-256color";
    baseIndex     = 1;
    keyMode       = "vi";
    prefix        = "C-a";
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      resurrect
      continuum
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha'
          set -g @catppuccin_window_default_text "#W"
          set -g @catppuccin_window_current_text "#W"
          set -g @catppuccin_status_modules_right "session date_time"
          set -g @catppuccin_date_time_text "%H:%M"
        '';
      }
    ];
    extraConfig = ''
      set -ag terminal-overrides ",xterm-256color:RGB"

      # ── Pane splits (keep cwd) ─────────────────────────────────────────
      bind \\ split-window -h -c "#{pane_current_path}"
      bind -  split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # ── Pane navigation (vim-style) ────────────────────────────────────
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # ── Pane resize ───────────────────────────────────────────────────
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # ── New window keeps cwd ──────────────────────────────────────────
      bind c new-window -c "#{pane_current_path}"

      # ── Reload config ─────────────────────────────────────────────────
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

      # ── Resurrect / continuum ─────────────────────────────────────────
      set -g @resurrect-capture-pane-contents 'on'
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '10'
    '';
  };

  programs.mpv = {
    enable  = true;
    package = pkgs.mpv;
    config = {
      profile                 = "gpu-hq";
      gpu-api                 = "vulkan";
      hwdec                   = "vaapi";
      vo                      = "gpu-next";
      audio-normalize-downmix = true;
      volume                  = 100;
      volume-max              = 150;
      sub-auto                = "fuzzy";
      sub-font                = "JetBrains Mono";
      sub-font-size           = 42;
      sub-color               = "#FFFFFF";
      sub-border-size         = 2;
      sub-border-color        = "#000000";
      osc                     = false;
      osd-font                = "JetBrains Mono";
      osd-font-size           = 28;
      keep-open               = true;
      save-position-on-quit   = true;
      screenshot-format       = "png";
      screenshot-directory    = "~/Pictures/Screenshots";
      ytdl-format             = "bestvideo[height<=1080]+bestaudio/best[height<=1080]";
    };
    bindings = {
      "l"  = "seek 5";
      "h"  = "seek -5";
      "L"  = "seek 30";
      "H"  = "seek -30";
      "j"  = "add volume -5";
      "k"  = "add volume 5";
      "="  = "add speed 0.1";
      "-"  = "add speed -0.1";
      "BS" = "set speed 1.0";
      "s"  = "cycle sub";
      "S"  = "cycle sub down";
      ">"  = "playlist-next";
      "<"  = "playlist-prev";
    };
    scripts = with pkgs.mpvScripts; [
      modernx
      sponsorblock
      thumbfast
      autoload
      inhibit-gnome
      quality-menu
      mpris
    ];
  };

  # ── Bash ──────────────────────────────────────────────────────────────────
  programs.bash = {
    enable           = true;
    enableCompletion = true;

    shellAliases = {
      # Navigation
      ".."   = "cd ..";
      "..."  = "cd ../..";
      "~"    = "cd ~";
      c      = "clear";
      reload = "source ~/.bashrc";
      j      = "zi";

      # Safety
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";

      # eza
      ls = "eza -a --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first --time-style=long-iso";
      lt = "eza -T --level=2 --icons";
      la = "eza -A --icons";
      l  = "eza --icons";

      # Modern replacements
      cat  = "bat";
      grep = "rg";
      top  = "btop";
      find = "fd";
      a2   = "aria2c -x 16 -s 16 -k 1M";

      # Git
      gs  = "git status";
      ga  = "git add .";
      gc  = "git commit -m";
      gp  = "git push";
      lg  = "lazygit";
      gd  = "git diff";
      gds = "git diff --staged";

      # System
      cleanram      = "sudo sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null && echo 'RAM cleared'";
      clean-journal = "sudo journalctl --vacuum-time=7d";
      big           = "sudo du -ahx / | sort -rh | head -n 20";
      lsblk         = "lsblk -e7";
      bootload      = "systemd-analyze blame | head -n 10";
      zstat         = "zramctl";
      ssd           = "sudo compsize -x /";
      battery       = "upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E 'state|to empty|percentage'";
      watts         = "upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep energy-rate";

      # Vault
      unlockv = "gocryptfs -allow_other ~/Documents/.vault ~/Documents/Vault";
      lockv   = "fusermount -u -z ~/Documents/Vault";
      backupv = "mkdir -p ~/Backups && rsync -av --delete ~/Documents/.vault ~/Backups/Vault_Encrypted_Backup/";

      # NixOS — use nh as the canonical rebuild command (shows diffs via nvd)
      nos     = "nh os switch --hostname ochinix-pc";
      nrs     = "nh os switch --hostname ochinix-pc";   # alias for muscle memory
      ngc     = "sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system && sudo nix-store --gc";
      update  = "cd /etc/nixos && sudo nix flake update && nh os switch --hostname ochinix-pc";
      upgrade = "cd /etc/nixos && sudo nix flake update && nh os switch --hostname ochinix-pc && ngc";

      # Tmux
      ta = "tmux attach || tmux new-session -s main";
      tn = "tmux new-session -s";
      tl = "tmux list-sessions";
      tk = "tmux kill-session -t";

      # Disk
      du = "dust";
      df = "duf";
      bw = "sudo bandwhich";

      br  = "broot";
      nav = "navi";
      f   = "pay-respects";

      sage-env    = "cd ~/Projects/Sage && nix develop --profile ~/.local/state/nix/profiles/sage";

      usage = ''
  	echo "" &&
  	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" &&
  	echo "  💽  DISK" &&
  	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" &&
  	duf --only local &&
  	echo "" &&
  	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" &&
  	echo "  📦  NIX STORE  (top 15)" &&
  	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" &&
  	dust /nix/store -d 1 -n 15 -x &&
  	echo "" &&
  	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" &&
  	echo "  🏠  HOME  (top 15)" &&
  	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" &&
  	dust ~ -d 1 -n 15 -x &&
  	echo "" &&
  	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" &&
  	echo "  📱  FLATPAK APPS" &&
  	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" &&
  	dust ~/.var/app -d 1 -n 10 -x &&
  	echo "" &&
  	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" &&
  	echo "  🔄  NIX GENERATIONS" &&
  	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" &&
  	sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -5 &&
  	echo ""
	'';
       clean-all = ''
 	echo '🧹 Starting full system clean...' &&
    	rm -rf ~/.cache/mozilla/firefox/*.default/cache2 &&
 	rm -rf ~/.var/app/com.brave.Browser/cache/BraveSoftware/Brave-Browser/Default/Cache &&
 	echo '✔ Browser caches cleared' &&
  	sudo journalctl --vacuum-time=7d &&
  	echo '✔ Journal vacuumed' &&
  	flatpak uninstall --unused -y &&
  	echo '✔ Flatpak orphans removed' &&
  	nh clean all --keep 1 --keep-since 1d &&
  	echo '✔ Nix generations cleaned' &&
  	sudo nix-store --optimise &&
  	echo '✔ Nix store optimised' &&
  	echo '✅ Full clean done'
	'';

 };

    sessionVariables = {
      EDITOR   = "nvim";
      VISUAL   = "nvim";
      CLICOLOR = "1";
      LESS     = "-RFMX";
      HISTSIZE              = "50000";
      HISTFILESIZE          = "200000";
      HISTCONTROL           = "ignoredups:erasedups:ignorespace";
      HISTTIMEFORMAT        = "%F %T ";
      HISTIGNORE            = "ls:ll:la:cd:pwd:exit:clear";
      FZF_DEFAULT_OPTS      = "--height 40% --layout=reverse --border --inline-info --color=header:italic";
      FZF_COMPLETION_TRIGGER = "**";
    };

    initExtra = ''
      export TERM=xterm-256color

      shopt -s checkwinsize histappend globstar
      PROMPT_COMMAND="history -a; history -c; history -r"
      bind "set bell-style none"        2>/dev/null
      bind "set completion-ignore-case on" 2>/dev/null
      bind -x '"\ec": "zi\n"'

      # ── tmux auto-attach ──────────────────────────────────────────────────
      # Start or reattach to tmux automatically when opening any terminal,
      # except when already inside tmux, in a tty, or in a dumb terminal.
     # if [ -z "$TMUX" ] && [ "$TERM" != "dumb" ] && [ -t 1 ]; then
      #  exec tmux new-session -A -s main
      #fi

      # ── UP: full system upgrade ───────────────────────────────────────────
      UP() {
        local start_time=$(date +%s)
        local failed=()
        _up_header() {
          echo -e "\n\033[1;36m╔══════════════════════════════════════╗\033[0m"
          echo -e "\033[1;36m║       🚀 Full System Upgrade          ║\033[0m"
          echo -e "\033[1;36m║   $(date '+%Y-%m-%d %H:%M:%S')            ║\033[0m"
          echo -e "\033[1;36m╚══════════════════════════════════════╝\033[0m\n"
        }
        _up_step() { echo -e "\033[1;33m▶ $1...\033[0m"; }
        _up_ok()   { echo -e "\033[1;32m  ✔ $1\033[0m"; }
        _up_fail() { echo -e "\033[1;31m  ✘ $1 failed\033[0m"; failed+=("$1"); }
        _up_run() {
          local name="$1"; shift
          _up_step "$name"
          if "$@"; then _up_ok "$name"; else _up_fail "$name"; fi
          echo
        }
        _up_header
        _up_run "Updating Nix Flake"   bash -c "cd /etc/nixos && sudo nix flake update"
        _up_run "Rebuilding NixOS"     nh os switch --hostname ochinix-pc
        _up_run "Updating Flatpaks"    bash -c "flatpak update -y && flatpak uninstall --unused -y"
        _up_run "Checking Firmware"    bash -c "sudo fwupdmgr get-updates -y; sudo fwupdmgr update -y; exit 0"
        _up_run "Cleaning Generations" bash -c "sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system && sudo nix-store --gc"
        local end_time=$(date +%s)
        local elapsed=$((end_time - start_time))
        local minutes=$((elapsed / 60))
        local seconds=$((elapsed % 60))
        if [ ''${#failed[@]} -eq 0 ]; then
          echo -e "\033[1;32m╔══════════════════════════════════════╗\033[0m"
          echo -e "\033[1;32m║   ✅ System upgrade complete!         ║\033[0m"
          echo -e "\033[1;32m║   ⏱  Time: ''${minutes}m ''${seconds}s\033[0m"
          echo -e "\033[1;32m╚══════════════════════════════════════╝\033[0m\n"
        else
          echo -e "\033[1;31m╔══════════════════════════════════════╗\033[0m"
          echo -e "\033[1;31m║   ⚠  Upgrade completed with errors   ║\033[0m"
          echo -e "\033[1;31m║   ⏱  Time: ''${minutes}m ''${seconds}s\033[0m"
          echo -e "\033[1;31m╚══════════════════════════════════════╝\033[0m"
          echo -e "\033[1;31m  Failed steps: ''${failed[*]}\033[0m\n"
          return 1
        fi
      }

      # ── fzf helpers ───────────────────────────────────────────────────────
      fif() {
        rg --files-with-matches --no-messages "$1" \
          | fzf --preview "rg --ignore-case --pretty --context 10 '$1' {}" \
          | xargs -r nvim
      }

      _fzf_cd() {
        local dir
        dir=$(fd -t d | fzf --preview 'eza --tree --level=2 --icons {}' --preview-window=right:50%)
        [ -n "$dir" ] && cd "$dir"
      }

      _fzf_comprun() {
        local command=$1
        shift
        case "$command" in
          cd)           fzf --preview 'eza --tree --level=2 --icons {}' "$@" ;;
          export|unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
          ssh)          fzf --preview 'dig {}' "$@" ;;
          *)            fzf --preview 'bat -n --color=always {}' "$@" ;;
        esac
      }

      bind -x '"\C-f": _fzf_cd'

      # ── syncto helper ─────────────────────────────────────────────────────
      syncto() {
        local src="$1" dest="$2" label="$3"
        local BOLD='\033[1m' CYAN='\033[0;36m' GREEN='\033[0;32m'
        local YELLOW='\033[0;33m' RED='\033[0;31m' RESET='\033[0m'
        echo -e "\n''${BOLD}''${CYAN}╔══════════════════════════════════════╗''${RESET}"
        echo -e "''${BOLD}''${CYAN}║  🔄  RSYNC → ''${label}''${RESET}"
        echo -e "''${BOLD}''${CYAN}╚══════════════════════════════════════╝''${RESET}"
        echo -e "''${YELLOW}  SRC :''${RESET} $src"
        echo -e "''${YELLOW}  DEST:''${RESET} $dest\n"
        rsync -avz --delete --info=progress2 --human-readable "$src" "$dest" \
          2>&1 | while IFS= read -r line; do
            if [[ "$line" =~ ^deleting ]]; then
              echo -e "''${RED}  $line''${RESET}"
            elif [[ "$line" =~ "bytes/sec"|"total size" ]]; then
              echo -e "''${GREEN}  $line''${RESET}"
            elif [[ "$line" =~ ^sending|^receiving ]]; then
              echo -e "''${CYAN}  $line''${RESET}"
            else
              echo "  $line"
            fi
          done
        echo -e "\n''${GREEN}''${BOLD}✓ Done: ''${label}''${RESET}\n"
      }

      alias syncvault='syncto /home/ochinix/Documents/Vault/ pi5:/home/ochiuom/Nixos/Vault/ "Vault"'
      alias syncworkdir='syncto /home/ochinix/workdir/ pi5:/home/ochiuom/Nixos/workdir/ "Workdir"'

      # ── ble.sh ────────────────────────────────────────────────────────────
      # fastfetch before ble.sh so the banner renders cleanly
      command -v fastfetch >/dev/null 2>&1 && fastfetch

      if [ -f "${pkgs.blesh}/share/blesh/ble.sh" ]; then
        source "${pkgs.blesh}/share/blesh/ble.sh" --noattach
        ble-attach
        bleopt complete_style=menu
        bleopt complete_ambiguous=menu
        bleopt complete_menu_style=desc
        bleopt complete_menu_maxlines=15
        bleopt suggest_style=faint
      fi

      # carapace — load after ble.sh attaches, inside ble hook
      if command -v carapace >/dev/null 2>&1; then
      blehook ATTACH+='source <(carapace _carapace bash)'
      fi

      # fzf keybindings — after ble.sh
      eval "$(fzf --bash)"
    '';
  };

  programs.vscode = {
  enable = true;
  package = pkgs.vscode.fhs; # wiki recommends fhs for extension compatibility
  profiles.default.extensions = with pkgs.vscode-extensions; [
    mkhl.direnv
    ms-toolsai.jupyter
    ms-python.python
    ];
  };

  home.activation.createSageProject = lib.hm.dag.entryAfter ["writeBoundary"] ''
  mkdir -p ~/Projects/Sage
  cp -n ${./Sage/flake.nix} ~/Projects/Sage/flake.nix
  cp -n ${./Sage/.envrc} ~/Projects/Sage/.envrc

  mkdir -p ~/.local/share/jupyter/kernels/sagemath
  cp -f ${./vscode/kernel.json} ~/.local/share/jupyter/kernels/sagemath/kernel.json

  mkdir -p ~/.vscode
  cp -f ${./vscode/settings.json} ~/.vscode/settings.json
  '';  

}
