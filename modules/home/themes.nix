# modules/home/themes.nix
{ config, pkgs, lib, ... }:

let
  # ── Change this one line to switch themes ─────────────────────────────
   activeTheme = "Orchis-Red-Dark-Compact";
  # activeTheme = "Tokyonight-B-MB-Dark";

in
{
  # ── Symlink themes and icons ──────────────────────────────────────────
  home.activation.linkThemes = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ~/.local/share/icons
    mkdir -p ~/.local/share/themes
    mkdir -p ~/.config/gtk-3.0
    mkdir -p ~/.config/gtk-4.0

    rm -rf ~/.local/share/icons/Neuwaita
    rm -rf ~/.local/share/icons/Hatter-Yaru
    rm -rf ~/.local/share/icons/Yaru
    rm -rf ~/.local/share/themes/Orchis-Red-Dark-Compact
    rm -rf ~/.local/share/themes/Tokyonight-B-MB-Dark

    ln -sfn /etc/nixos/themes/Neuwaita \
      ~/.local/share/icons/Neuwaita
    ln -sfn /etc/nixos/themes/Hatter-Yaru \
      ~/.local/share/icons/Hatter-Yaru
    ln -sfn ${pkgs.yaru-theme}/share/icons/Yaru \
      ~/.local/share/icons/Yaru
    ln -sfn /etc/nixos/themes/Orchis-Red-Dark-Compact \
      ~/.local/share/themes/Orchis-Red-Dark-Compact
    ln -sfn /etc/nixos/themes/Tokyonight-B-MB-Dark \
      ~/.local/share/themes/Tokyonight-B-MB-Dark
  '';

  # ── GTK 3 ─────────────────────────────────────────────────────────────
  home.file.".config/gtk-3.0/gtk.css".source =
    ../../themes/${activeTheme}/gtk-3.0/gtk.css;

  home.file.".config/gtk-3.0/assets" = {
    source    = ../../themes/${activeTheme}/gtk-3.0/assets;
    recursive = true;
  };

  # ── GTK 4 libadwaita fix ─────────────────────────────────────────────
  home.file.".config/gtk-4.0/gtk.css".source =
    ../../themes/${activeTheme}/gtk-4.0/gtk.css;

  home.file.".config/gtk-4.0/gtk-dark.css".source =
    ../../themes/${activeTheme}/gtk-4.0/gtk-dark.css;

  home.file.".config/gtk-4.0/assets" = {
    source    = ../../themes/${activeTheme}/gtk-4.0/assets;
    recursive = true;
  };

  # ── Cursor ────────────────────────────────────────────────────────────
  home.pointerCursor = {
    name       = "Bibata-Modern-Ice";
    package    = pkgs.bibata-cursors;
    size       = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # ── Flatpak theming ───────────────────────────────────────────────────
  home.activation.flatpakTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if command -v flatpak >/dev/null 2>&1; then
      flatpak override --user \
        --filesystem=${config.home.homeDirectory}/.local/share/themes
      flatpak override --user \
        --filesystem=${config.home.homeDirectory}/.local/share/icons
      flatpak override --user \
        --env=GTK_THEME=${activeTheme}
      flatpak override --user \
        --env=ICON_THEME=Neuwaita
    fi
  '';

  # ── Icon cache refresh — runs after login, not blocking boot ──────────
  systemd.user.services.refresh-icon-caches = {
    Unit = {
      Description = "Refresh GTK icon caches";
      After       = [ "graphical-session.target" ];
    };
    Service = {
      Type      = "oneshot";
      ExecStart = pkgs.writeShellScript "refresh-icon-caches" ''
        ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t \
          ${config.home.homeDirectory}/.local/share/icons/Yaru || true
        ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t \
          ${config.home.homeDirectory}/.local/share/icons/Hatter-Yaru || true
        ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t \
          ${config.home.homeDirectory}/.local/share/icons/Neuwaita || true
      '';
      RemainAfterExit = true;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # ── Packages ──────────────────────────────────────────────────────────
  home.packages = [
    pkgs.yaru-theme
    pkgs.bibata-cursors
    pkgs.gnomeExtensions.rounded-window-corners-reborn
  ];

  # ── GTK declaration ───────────────────────────────────────────────────
  gtk = {
    enable    = true;
    theme     = { name = activeTheme; };
    iconTheme = { name = "Neuwaita"; };
    font      = { name = "Inter"; size = 11; };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-enable-primary-paste          = false;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # ── dconf ─────────────────────────────────────────────────────────────
  dconf.settings."org/gnome/desktop/interface" = {
    gtk-theme         = lib.mkForce activeTheme;
    icon-theme        = lib.mkForce "Neuwaita";
    cursor-theme      = "Bibata-Modern-Ice";
    cursor-size       = 24;
    font-antialiasing = "rgba";
    font-hinting      = "slight";
    color-scheme      = "prefer-dark";
  };

  dconf.settings."org/gnome/shell/extensions/user-theme" = {
    name = lib.mkForce "Orchis-Red-Dark-Compact";
  };

  #dconf.settings."org/gnome/shell/extensions/rounded-window-corners-reborn" = {
    #border-radius        = 8;
   # smoothing            = 0;
  #  keep-rounded-corners = false;
 #   skip-libadwaita-app  = true;
#  };

  dconf.settings."org/gtk/settings/file-chooser" = {
    sort-directories-first = true;
  };

  dconf.settings."org/gtk/gtk4/settings/file-chooser" = {
    sort-directories-first = true;
  };
}
