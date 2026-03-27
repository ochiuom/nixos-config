# modules/nixos/gdm.nix
{ config, pkgs, lib, ... }:

{
  services.displayManager.gdm.enable = lib.mkDefault true;

  programs.dconf.profiles.gdm = {
    databases = [{
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          cursor-theme = "Bibata-Modern-Ice";
          cursor-size  = lib.gvariant.mkInt32 24;
        };
        "org/gnome/desktop/background" = {
          color-shading-type = "solid";
          primary-color      = "#1c1c1c";
          picture-options    = "none";
        };
        "org/gnome/desktop/peripherals/touchpad" = {
          tap-to-click = true;
        };
      };
    }];
  };

  environment.systemPackages = [
    pkgs.bibata-cursors
  ];
}
