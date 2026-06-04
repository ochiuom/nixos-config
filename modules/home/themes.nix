# modules/home/themes.nix
{ config, pkgs, lib, ... }:

let
 # activeTheme = "Ant";
  activeTheme = "Dracula";
 # activeTheme = "Sweet-Dark";
  #activeTheme = "Cyber-Dusk-Rounded-Glass";
  #activeTheme = "Orchis-Red-Dark-Compact";
  #activeTheme = "Tokyonight-B-MB-Dark";

  themeBase = ../../themes/${activeTheme};

  hasGtk2   = builtins.pathExists "${themeBase}/gtk-2.0";
  hasGtk3   = builtins.pathExists "${themeBase}/gtk-3.0";
  hasGtk320 = builtins.pathExists "${themeBase}/gtk-3.20";
  hasGtk4   = builtins.pathExists "${themeBase}/gtk-4.0";
  hasAssets = builtins.pathExists "${themeBase}/assets";

  optionalDir = condition: target: src:
    lib.optionalAttrs condition {
      "${target}" = { source = src; recursive = true; };
    };

in
{
  home.activation.cleanGtkBackups = lib.hm.dag.entryAfter ["writeBoundary"] ''
    for dir in gtk-2.0 gtk-3.0 gtk-3.20 gtk-4.0; do
      target="$HOME/.config/$dir"
      [ -d "$target" ] && rm -f "$target"/*.backup
    done
  '';

  home.activation.linkThemes = lib.hm.dag.entryAfter ["cleanGtkBackups"] ''
    mkdir -p ~/.local/share/icons
    mkdir -p ~/.local/share/themes

    rm -rf ~/.local/share/icons/Neuwaita
    rm -rf ~/.local/share/icons/Hatter-Yaru
    rm -rf ~/.local/share/icons/Yaru
    rm -rf ~/.local/share/icons/WhiteSur-dark
    rm -rf ~/.local/share/icons/Tela
    rm -rf ~/.local/share/icons/Tela-purple
    rm -rf ~/.local/share/themes/Orchis-Red-Dark-Compact
    rm -rf ~/.local/share/themes/Tokyonight-B-MB-Dark
    rm -rf ~/.local/share/themes/Cyber-Dusk-Rounded-Glass

    ln -sfn /etc/nixos/themes/Neuwaita \
      ~/.local/share/icons/Neuwaita
    ln -sfn /etc/nixos/themes/Hatter-Yaru \
      ~/.local/share/icons/Hatter-Yaru
    ln -sfn ${pkgs.yaru-theme}/share/icons/Yaru \
      ~/.local/share/icons/Yaru
    ln -sfn /etc/nixos/themes/WhiteSur-dark \
      ~/.local/share/icons/WhiteSur-dark
    ln -sfn /etc/nixos/themes/Tela \
      ~/.local/share/icons/Tela
    ln -sfn /etc/nixos/themes/Tela-purple \
      ~/.local/share/icons/Tela-purple
    ln -sfn /etc/nixos/themes/Orchis-Red-Dark-Compact \
      ~/.local/share/themes/Orchis-Red-Dark-Compact
    ln -sfn /etc/nixos/themes/Tokyonight-B-MB-Dark \
      ~/.local/share/themes/Tokyonight-B-MB-Dark

    mkdir -p ~/.local/share/themes/Cyber-Dusk-Rounded-Glass
    ln -sfn /etc/nixos/themes/Cyber-Dusk-Rounded-Glass/gnome-shell \
      ~/.local/share/themes/Cyber-Dusk-Rounded-Glass/gnome-shell
    ln -sfn /etc/nixos/themes/Cyber-Dusk-Rounded-Glass/index.theme \
      ~/.local/share/themes/Cyber-Dusk-Rounded-Glass/index.theme
  '';

  home.file = lib.mkMerge [
    (optionalDir hasGtk2   ".config/gtk-2.0"  "${themeBase}/gtk-2.0")
    (optionalDir hasGtk3   ".config/gtk-3.0"  "${themeBase}/gtk-3.0")
    (optionalDir hasGtk320 ".config/gtk-3.20" "${themeBase}/gtk-3.20")
    (optionalDir hasGtk4   ".config/gtk-4.0"  "${themeBase}/gtk-4.0")
    (optionalDir hasAssets ".config/assets"   "${themeBase}/assets")
  ];

  home.pointerCursor = {
    name       = "Bibata-Modern-Ice";
    package    = pkgs.bibata-cursors;
    size       = 24;
    gtk.enable = true;
    x11.enable = true;
  };

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
        ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t \
          ${config.home.homeDirectory}/.local/share/icons/WhiteSur-dark || true
        ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t \
          ${config.home.homeDirectory}/.local/share/icons/Tela || true
        ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t \
          ${config.home.homeDirectory}/.local/share/icons/Tela-purple || true
      '';
      RemainAfterExit = true;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  home.packages = [
    pkgs.yaru-theme
    pkgs.bibata-cursors
  ];

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

  dconf.settings."org/gtk/settings/file-chooser" = {
    sort-directories-first = true;
  };

  dconf.settings."org/gtk/gtk4/settings/file-chooser" = {
    sort-directories-first = true;
  };
}
