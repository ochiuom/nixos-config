{ config, pkgs, lib, ... }:
{
  imports = [
    ./modules/boot.nix
    ./modules/hardware.nix
    ./modules/networking.nix
    ./modules/desktop.nix
    ./modules/power.nix
    ./modules/packages.nix
    ./modules/services.nix
   # ./modules/nixos/gdm.nix
    ./modules/security/security.nix
    ./modules/security/clamav.nix
   # ./modules/security/audit.nix
    ./audio-visual.nix
  ];

  # ── Locale ───────────────────────────────────────────────────────────────────
  time.timeZone      = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true;
  # ── User ─────────────────────────────────────────────────────────────────────
  users.users.ochinix = {
    isNormalUser = true;
    description  = "ochinix";
    extraGroups  = [ "wheel" "networkmanager" "video" "render" "audio" ];
    initialPassword = "changeme";
  };

  # ── Nix ──────────────────────────────────────────────────────────────────────
  nix.settings = {
  trusted-users = lib.mkForce [ "root" "ochinix" ];
  sandbox = true;
  require-sigs = true;
  auto-optimise-store = true;
  substituters = lib.mkForce [
    "https://cache.nixos.org/"
    "https://nix-community.cachix.org"
  ];
  trusted-public-keys = lib.mkForce [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # ── Unfree packages ───────────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];

  # ── Environment ──────────────────────────────────────────────────────────────
  environment.defaultPackages = lib.mkForce [ pkgs.nano ];
  environment.variables = {
    GST_PLUGIN_PATH = "/run/current-system/sw/lib/gstreamer-1.0/";
  };

  system.stateVersion = "26.05";

  # ── Custom options ────────────────────────────────────────────────────────────
 # kernelcore.security.clamav.enable = true;
  programs.nix-ld.enable = true;  
}
