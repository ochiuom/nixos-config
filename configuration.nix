{ config, pkgs, lib, ... }:
{

    imports = [
    ./modules/boot.nix
    ./modules/hardware.nix
    ./modules/networking.nix
    ./modules/desktop.nix
    ./modules/power.nix
    ./modules/security.nix
    ./modules/packages.nix
    ./modules/services.nix
    ./modules/nixos/gdm.nix
  ];

  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";
 
  # ── User ─────────────────────────────────────────────────────────────────────
  users.users.ochinix = {
    isNormalUser = true;
    description  = "ochinix";
    extraGroups  = [ "wheel" "networkmanager" "video" "render" "audio" ];
    initialPassword = "changeme"; # replace with hashedPasswordFile + sops post first deploy
  };

  # ── Nix ──────────────────────────────────────────────────────────────────────
  nix.settings.trusted-users = [ "root" "ochinix" ];

  # ── Unfree packages whitelist ─────────────────────────────────────────────
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "sublime4"
  ];

  nixpkgs.config.permittedInsecurePackages = [
  "openssl-1.1.1w"
  ];

  # ── Environment ──────────────────────────────────────────────────────────────
  # environment.defaultPackages = []; # remove implicit nano, perl, strace etc.
  environment.defaultPackages = lib.mkForce [ pkgs.nano ];
  system.stateVersion = "26.05";
}
