{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [

    # ── Browsers & Internet ───────────────────────────────────────────────
    nextcloud-client
    localsend
    gemini-cli

    # ── Communication ─────────────────────────────────────────────────────
    telegram-desktop

    # ── Terminals & Editors ───────────────────────────────────────────────
    ghostty
    vscode
    sublime4

    # ── Documents & Office ────────────────────────────────────────────────
    libreoffice-fresh
    hunspell
    hunspellDicts.en_US
    texstudio
    texlab                       # LSP for LaTeX
    vscode-langservers-extracted # LSP: HTML/CSS/JSON/Markdown
    stylua                       # Lua formatter (nvim)
    zathura                      # Lightweight PDF viewer
    pdfsam-basic                 # PDF split/merge
    evince                       # GNOME document viewer

    # ── Media — Audio ─────────────────────────────────────────────────────
    audacious
    audacious-plugins
    audacity
    strawberry
    plattenalbum                 # GNOME MusicBrainz album art
    cava                         # Terminal audio visualizer
    cavalier                     # GUI audio visualizer
    mpd
    mpc                          # MPD CLI client
    qpwgraph                     # PipeWire patchbay

    # ── Media — Video ─────────────────────────────────────────────────────
    vlc
    mpv
    mplayer
    smplayer                     # Qt frontend for mplayer/mpv

    # ── Graphics & Image ──────────────────────────────────────────────────
    gimp
    inkscape
    imagemagick
    shotwell                     # Photo manager
    gpick                        # Color picker (X11)
    wl-color-picker              # Color picker (Wayland)

    # ── File Management ───────────────────────────────────────────────────
    yazi                         # Terminal file manager
    baobab                       # Disk usage analyzer
    gparted                      # Partition editor

    # ── GNOME Utilities ───────────────────────────────────────────────────
    gnome-tweaks
    gnome-extension-manager

    # ── Network ───────────────────────────────────────────────────────────
    networkmanagerapplet
    xdg-desktop-portal-gnome

    # ── AI / Dev Tools ────────────────────────────────────────────────────
    opencode
    fragments                    # Torrent client (GNOME)

    # ── Pi5 Server ────────────────────────────────────────────────────
    joplin-desktop

  ];
}
