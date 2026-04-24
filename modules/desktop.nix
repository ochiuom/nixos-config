{ config, pkgs, lib, ... }:
{
  services.displayManager.gdm = { enable = true; wayland = true; };
  services.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour gnome-connections geary epiphany totem
    gnome-maps gnome-music  gnome-contacts
    gnome-clocks gnome-calendar gnome-logs gnome-software 
  ];
  
  services.tumbler.enable = true;  # GNOME thumbnail service

  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "gnome";
  };

  fonts = {
  packages = with pkgs; [
    ubuntu-classic
    inter
    liberation_ttf
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
    font-awesome
    atkinson-hyperlegible-next
   # atkinson-hyperlegible-mono
  ];
  fontconfig = {
    enable = true;
    antialias = true;
    hinting = { enable = true; style = "slight"; };
    subpixel = { rgba = "rgb"; lcdfilter = "default"; };
    defaultFonts = {
      sansSerif = [ "Segoe UI" "Noto Sans" "Liberation Sans" "Noto Color Emoji" ];
      serif     = [ "Georgia" "Noto Serif" "Liberation Serif" "Noto Color Emoji" ];
      monospace = [ "Cascadia Code" "JetBrainsMono Nerd Font" "Liberation Mono" "Noto Color Emoji" ];
    };
  };
};

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    extraConfig.pipewire."10-clock" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [ 44100 48000 96000 192000 ];
        "default.clock.quantum" =  256;  #1024;
        "default.clock.min-quantum" = 32;
        "default.clock.max-quantum" = 8192;
      };
    };
  };

  environment.sessionVariables = {
  XDG_DATA_DIRS = [
    "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
   ];
 };

  xdg.mime.defaultApplications = {
  "text/html"                = "brave-browser.desktop";
  "x-scheme-handler/http"    = "brave-browser.desktop";
  "x-scheme-handler/https"   = "brave-browser.desktop";
  "x-scheme-handler/about"   = "brave-browser.desktop";
  "x-scheme-handler/unknown" = "brave-browser.desktop";
  };
}
