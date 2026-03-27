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
    CLUTTER_BACKEND = "wayland";
    NIXOS_OZONE_WL = "1";
  };

  services.xserver.videoDrivers = [ "modesetting" ];
  services.fstrim.enable = true;

  services.btrfs.autoScrub = {
    enable   = true;
    interval = "monthly";
  };

  zramSwap = {
    enable        = true;
    algorithm     = "zstd";
    memoryPercent = 50;
    priority      = 100;
  };

  hardware.bluetooth.enable      = true;
  hardware.bluetooth.powerOnBoot = false;
  services.blueman.enable        = true;

  # ── OOM handling ──────────────────────────────────────────────────────
  # systemd-oomd — kernel-level OOM killer
  systemd.oomd.enable            = true;
  systemd.oomd.enableUserSlices  = true;

  # earlyoom — userspace OOM killer, acts before system freezes
  # kills the process with highest oom_score when memory is critically low
  services.earlyoom = {
    enable             = true;
    freeMemThreshold   = 5;   # kill when free RAM drops below 5%
    freeSwapThreshold  = 10;  # kill when free swap drops below 10%
    extraArgs = [
      "-g"
      "--prefer"
      "(^|/)(chromium|firefox|brave|electron|code|java)$"
      "--avoid"
      "(^|/)(sshd|systemd|login|init)$"
    ];
  };
  # ── Process scheduler ─────────────────────────────────────────────────
  # ananicy-cpp — auto nice/ionice for processes
  # smoother desktop under load, prevents background tasks hogging CPU
  services.ananicy = {
    enable  = true;
    package = pkgs.ananicy-cpp;
  };

  services.thermald.enable = true;
  services.devmon.enable   = true;
  services.gvfs.enable     = true;
  services.udisks2.enable  = true;

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme*", ATTR{queue/scheduler}="none"
  '';

  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };

  systemd.services.bluetooth-unblock = {
    description = "Unblock Bluetooth via rfkill";
    wantedBy    = [ "bluetooth.target" ];
    before      = [ "bluetooth.service" ];
    serviceConfig = {
      Type      = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/rfkill unblock bluetooth";
    };
  };
}
