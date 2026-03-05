{ config, pkgs, lib, ... }:
{
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  services.fwupd.enable = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
      intel-compute-runtime
      libvdpau-va-gl
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    NIXOS_OZONE_WL = "1";
  };
  services.xserver.videoDrivers = [ "modesetting" ];

  services.fstrim.enable = true;
  services.btrfs.autoScrub = { enable = true; interval = "monthly"; };

  zramSwap = { enable = true; algorithm = "zstd"; memoryPercent = 50; priority = 100; };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;
  services.blueman.enable = true;

  systemd.oomd.enable = true;
  systemd.oomd.enableUserSlices = true;
 
  services.thermald.enable = true;

  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  services.udev.extraRules = ''
  ACTION=="add|change", KERNEL=="nvme*", ATTR{queue/scheduler}="none"
  '';

  systemd.settings.Manager = {
  DefaultTimeoutStopSec = "10s";
  };

}
