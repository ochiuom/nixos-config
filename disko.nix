# =============================================================
# Disko — Declarative Disk Configuration
# =============================================================
#
# BEFORE RUNNING: confirm your NVMe device name
#   lsblk   →   make sure it is nvme0n1 and not nvme1n1 etc.
# =============================================================
# DISKO LAYOUT VISUAL GUIDE
# =============================================================
#
# ┌─────────────────────────────────────────────────────────┐
# │ SCENARIO A — DUAL BOOT (Windows already installed)     │
# └─────────────────────────────────────────────────────────┘
#
#   nvme0n1
#   ├─ nvme0n1p1   200M     EFI (REUSED, NOT FORMATTED)
#   ├─ nvme0n1p3   ???    Windows (UNTOUCHED)
#   └─ nvme0n1p4   rest   LUKS2 → BTRFS
#                         ├─ @            → /
#                         ├─ @home        → /home
#                         ├─ @nix         → /nix
#                         ├─ @snapshots   → /.snapshots
#                         ├─ @var-log     → /var/log
#                         └─ @tmp         → /tmp
#
#   ✔ Partition table NOT modified
#   ✔ EFI NOT formatted
#   ✔ Windows NOT touched
#   ✔ Only p4 formatted
#
# =============================================================
#
# ┌─────────────────────────────────────────────────────────┐
# │ SCENARIO B — FULL DISK (NO WINDOWS)                    │
# └─────────────────────────────────────────────────────────┘
#
#   nvme0n1  (ENTIRE DISK WIPED)
#   ├─ nvme0n1p1   1G     EFI (FORMATTED FAT32)
#   └─ nvme0n1p2   rest   LUKS2 → BTRFS
#                         ├─ @            → /
#                         ├─ @home        → /home
#                         ├─ @nix         → /nix
#                         ├─ @snapshots   → /.snapshots
#                         ├─ @var-log     → /var/log
#                         └─ @tmp         → /tmp
#
#   ✔ GPT recreated
#   ✔ EFI formatted
#   ✔ All data erased
#
# =============================================================
# TO SWITCH SCENARIOS:
#   - Scenario A is active below
#   - Comment it out and uncomment Scenario B if needed
# =============================================================


## =============================================================
# TO RUN:
#   # 1. Clone config and run Disko
#    git clone https://github.com/ochiuom/nixos-config
#    cd nixos-config
#    sudo nix run github:nix-community/disko -- --mode formatMount ./disko.nix

# 2. Copy cloned config into mounted system
#     sudo cp -r ../nixos-config /mnt/etc/nixos

# 3. Install
#     sudo nixos-install --root /mnt --flake /mnt/etc/nixos#ochinix-pc
#
# =============================================================
# SCENARIO A — Dual Boot (Windows already installed)
#   References existing partitions directly — does NOT touch
#   the partition table, Windows partition, or EFI layout.
#   Only formats nvme0n1p4 (LUKS2 + btrfs).
#   Active by default — comment out if using Scenario B.
# =============================================================

{ lib, ... }:

let
  mountOpts = [
    "compress=zstd:1"
    "noatime"
    "discard=async"
    "autodefrag"
  ];
in
{
  disko.devices = {

    # We are NOT redefining the disk or GPT.
    # We only define the partitions we manage.

    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-INTEL_SSDPEKNU512GZ_BTKA23010K50512A";

      content = {
        type = "gpt";

        partitions = {

          # Existing EFI (DO NOT FORMAT)
          ESP = {
            device = "/dev/disk/by-id/nvme-INTEL_SSDPEKNU512GZ_BTKA23010K50512A-part1";
            type = "EF00";

            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };

          # Existing NixOS partition (p4)
          nixos = {
            device = "/dev/disk/by-id/nvme-INTEL_SSDPEKNU512GZ_BTKA23010K50512A-part4";

            content = {
              type = "luks";
              name = "cryptroot";
              askPassword = true;
       
              settings = {
                allowDiscards = true;
                bypassWorkqueues = true;
              };

              extraFormatArgs = [
                "--type" "luks2"
                "--cipher" "aes-xts-plain64"
                "--key-size" "512"
                "--hash" "sha512"
                "--pbkdf" "argon2id"
              ];

              content = {
                type = "btrfs";
                extraArgs = [ "-f" "-L" "nixos" ];

                subvolumes = {
                  "@"          = { mountpoint = "/";           mountOptions = mountOpts; };
                  "@home"      = { mountpoint = "/home";       mountOptions = mountOpts; };
                  "@nix"       = { mountpoint = "/nix";        mountOptions = mountOpts; };
                  "@snapshots" = { mountpoint = "/.snapshots"; mountOptions = mountOpts; };
                  "@var-log"   = { mountpoint = "/var/log";    mountOptions = mountOpts; };
                  "@tmp"       = { mountpoint = "/tmp";        mountOptions = mountOpts; };
                };
              };
            };
          };

        };
      };
    };
  };
}

