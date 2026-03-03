{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    git vim wget curl htop ffmpeg libva-utils tree ncdu jq
    sbctl btrfs-progs cryptsetup pciutils usbutils lshw
    networkmanagerapplet xdg-utils xdg-desktop-portal-gnome glib gpick

    nautilus-python
    gobject-introspection
    (python3.withPackages (ps: with ps; [ pygobject3 ]))

    libreoffice-fresh
    hunspell
    hunspellDicts.en_US

    texstudio
    firefox
    kitty ghostty
    vscode zed-editor

    vlc mpd mpc mpv mplayer smplayer

    syncthing tor gocryptfs fuse

    yazi evince gparted baobab
    wl-color-picker localsend exfatprogs qpwgraph

   # pdfstudioviewer
    strawberry
    gimp
    inkscape
    # rustdesk  # expensive build ~10min, uncomment when needed
    imagemagick
    shotwell
    
    ymuse          # lightweight GTK, simple clean UI
    plattenalbum   # formerly mpdevil, more GNOME-native feel
    
    vscode-langservers-extracted  # html, css
    stylua                        # lua formatter
    texlab                        # latex
    zathura 
    # LaTeX
    # texlive installed separately — full scheme via official installer
    # default binary path added to PATH in bashrc via home.nix

    gnome-tweaks gnome-extension-manager

    gnomeExtensions.user-themes
    gnomeExtensions.caffeine
    gnomeExtensions.places-status-indicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.gsconnect
    gnomeExtensions.desktop-cube
    gnomeExtensions.burn-my-windows
    gnomeExtensions.impatience
    gnomeExtensions.compiz-windows-effect
    gnomeExtensions.compiz-alike-magic-lamp-effect
    gnomeExtensions.ddterm
    gnomeExtensions.search-light
    gnomeExtensions.space-bar
    gnomeExtensions.appindicator
    gnomeExtensions.tiling-assistant
    gnomeExtensions.logo-menu
    gnomeExtensions.lock-guard
    gnomeExtensions.ip-finder
    gnomeExtensions.color-picker
    gnomeExtensions.dash2dock-lite
    gnomeExtensions.compact-top-bar
    gnomeExtensions.advanced-weather-companion
    gnomeExtensions.adaptive-brightness
    gnomeExtensions.astra-monitor
    gnomeExtensions.tophat
    gnomeExtensions.gnome-40-ui-improvements
    gnomeExtensions.fuzzy-app-search
    gnomeExtensions.penguin-ai-chatbot
    gnomeExtensions.status-area-horizontal-spacing
    gnomeExtensions.tailscale-status
    gnomeExtensions.workspace-matrix
    gnomeExtensions.wallpaper-slideshow
  ];


   programs.nh = {
   enable = true;
   flake = "/etc/nixos";
   };
}
