{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    git vim wget curl htop ffmpeg libva-utils tree ncdu ticker
    sbctl btrfs-progs cryptsetup pciutils usbutils lshw openssl
    networkmanagerapplet xdg-utils xdg-desktop-portal-gnome glib glib-networking gpick

    nautilus-python
    gobject-introspection
    (python3.withPackages (ps: with ps; [ pygobject3 ]))

    libreoffice-fresh
    hunspell
    hunspellDicts.en_US

    texstudio
    firefox
    kitty ghostty
    vscode
    # zed-editor

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

    nextcloud-client
    gemini-cli opencode
    
    vscode-langservers-extracted  # html, css
    stylua                        # lua formatter
    texlab                        # latex
    zathura 
    pdfsam-basic
    poppler-utils
    pdfcpu
    font-bitstream-type1
    # LaTeX
    (pkgs.texlive.combine {
    inherit (pkgs.texlive)
    scheme-small
    latex-bin  # Ensure pdflatex/lualatex are linked
    latexmk
    collection-luatex
    revtex4-1    # ← needed for \documentclass[aps,rmp,...]{revtex4-2}
    moderncv arydshln lm mathdesign
    # Fonts & Symbols
    charter noto fontspec amsmath amsfonts amscls
    cm-super   # High-quality default fonts
    physics mathtools cancel braket siunitx
    # Graphics & Diagrams
    pgf tikz-cd circuitikz quantikz
    adjustbox  subfig 
    # Layout & Tables
    booktabs float multirow colortbl  
    geometry microtype parskip setspace ragged2e enumitem etoolbox csquotes
    titlesec changepage caption xcolor tcolorbox 
    # Bibliography & Meta
    hyperref biblatex biber fancyhdr lastpage orcidlink
    babel babel-english;
    })
    

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
   # gnomeExtensions.appindicator
    gnomeExtensions.tiling-assistant
   # gnomeExtensions.logo-menu
   # gnomeExtensions.lock-guard
    gnomeExtensions.ip-finder
    gnomeExtensions.color-picker
   # gnomeExtensions.dash2dock-lite
    gnomeExtensions.compact-top-bar
    gnomeExtensions.advanced-weather-companion
   # gnomeExtensions.adaptive-brightness
    gnomeExtensions.astra-monitor
    gnomeExtensions.tophat
    gnomeExtensions.gnome-40-ui-improvements
    gnomeExtensions.fuzzy-app-search
    gnomeExtensions.penguin-ai-chatbot
    gnomeExtensions.status-area-horizontal-spacing
    gnomeExtensions.tailscale-status
   # gnomeExtensions.workspace-matrix
    gnomeExtensions.wallpaper-slideshow
    gnomeExtensions.dash-to-panel
  ];


   programs.nh = {
   enable = true;
   flake = "/etc/nixos";
   };

}
