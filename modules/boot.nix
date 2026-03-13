{ config, pkgs, lib, ... }:
{
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  boot.loader.systemd-boot.extraEntries = {
    "windows.conf" = ''
      title Windows 11
      efi /EFI/Microsoft/Boot/bootmgfw.efi
    '';
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.kernelModules = [ "i915" ];

  boot.plymouth = {
    enable = true;
    theme = "bgrt";
  };

  boot.initrd.systemd.enable = true;

  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "i915.enable_guc=3"
    "i915.enable_fbc=1"
    "i915.enable_psr=1"
    "quiet"
    "splash"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "mem_sleep_default=deep"
  ];
}
