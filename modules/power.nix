{ config, pkgs, lib, ... }:
{
  services.throttled.enable = true;
  services.power-profiles-daemon.enable = false;

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC  = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC  = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_BOOST_ON_AC  = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_HWP_DYN_BOOST_ON_AC  = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;
      START_CHARGE_THRESH_BAT0 = 70;
      STOP_CHARGE_THRESH_BAT0  = 80;
      START_CHARGE_THRESH_BAT1 = 70;
      STOP_CHARGE_THRESH_BAT1  = 80;
      DISK_DEVICES = "nvme0n1";
      DISK_APM_LEVEL_ON_AC  = 254;
      DISK_APM_LEVEL_ON_BAT = 128;
      AHCI_RUNTIME_PM_ON_AC  = "on";
      AHCI_RUNTIME_PM_ON_BAT = "auto";
      PCIE_ASPM_ON_AC  = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";
      RUNTIME_PM_ON_AC  = "on";
      RUNTIME_PM_ON_BAT = "auto";
      USB_AUTOSUSPEND = 1;
      WIFI_PWR_ON_AC  = "off";
      WIFI_PWR_ON_BAT = "on";
      WOL_DISABLE = "Y";
      PLATFORM_PROFILE_ON_AC  = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";
    };
  };

  boot.kernel.sysctl = {
    # VM performance
    "vm.swappiness"          = 10;
    "vm.vfs_cache_pressure"  = 50;
    "vm.dirty_ratio"         = 10;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_writeback_centisecs" = 1500;

    # Network performance
    "net.core.rmem_max" = 2500000;
  };

  services.irqbalance.enable = true;
}
