{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [

    # ── Core Utilities ────────────────────────────────────────────────────
    wget
    curl
    git
    vim
    killall
    tree
    xdg-utils
    fwupd
    gnupg
    android-tools   
    atuin
    # ── Modern CLI Replacements ───────────────────────────────────────────
    fd                           # find
    ripgrep                      # grep
    bat                          # cat
    eza                          # ls
    btop                         # top
    htop                         # fallback top
    ncdu                         # disk usage (ncurses)

    # ── System Info & Hardware ────────────────────────────────────────────
    pciutils                     # lspci
    usbutils                     # lsusb
    lshw                         # hardware info
    libva-utils                  # vainfo — check VAAPI/hwdec
    nvd                          # nix diff between generations

    # ── Filesystem & Storage ──────────────────────────────────────────────
    btrfs-progs
    exfatprogs
    cryptsetup
    gocryptfs                    # encrypted vault
    fuse                         # gocryptfs dependency

    # ── Security & Boot ───────────────────────────────────────────────────
    sbctl                        # secure boot key management
    openssl
    usbguard                     # USB device whitelisting

    # ── Network & Sync ────────────────────────────────────────────────────
    tailscale
    syncthing
    tor

    # ── Media Processing ──────────────────────────────────────────────────
    ffmpeg
    ffmpegthumbnailer            # thumbnails for file managers

    # ── PDF & Document ────────────────────────────────────────────────────
    poppler-utils                # pdftotext, pdfinfo etc.
    pdfcpu                       # PDF manipulation CLI

    # ── Python / Nautilus Integration ─────────────────────────────────────
    nautilus-python
    gobject-introspection
    (python3.withPackages (ps: with ps; [ pygobject3 ]))

    # ── GNOME / Desktop Plumbing ──────────────────────────────────────────
    glib
    glib-networking
    kitty                        # terminal (system-wide for .desktop etc.)

    # ── Finance ───────────────────────────────────────────────────────────
    ticker                       # stock ticker CLI
    
    #Install Gnuplot with high-quality terminal support
    (gnuplot.override { withQt = true; withWxGTK = true; })
    ghostscript # Required for EPS/PDF processing

] ++ (with pkgs.gst_all_1; [
  gstreamer
  gst-plugins-base
  gst-plugins-good
  gst-plugins-bad
  gst-plugins-ugly
  gst-libav
  gst-plugins-rs          # ← this has gtk4paintablesink
]) ++ [
  pkgs.gst_all_1.gst-vaapi
];


}
