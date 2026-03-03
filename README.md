# NixOS Configuration — ThinkPad T480s

Personal NixOS flake configuration for a Lenovo ThinkPad T480s running a pure Wayland GNOME desktop.

---

## Why NixOS

Coming from Arch, Fedora, and Ubuntu — NixOS is a fundamentally different approach to managing a system.

**Reproducibility** — the entire OS is declared in one git repo. After a fresh install, a single `nixos-rebuild switch` restores everything exactly as it was — packages, services, dotfiles, extensions, themes, audio config, power management. Nothing manual, nothing forgotten.

**Rollbacks** — every rebuild creates a new generation. If something breaks, boot into the previous generation from the bootloader. No recovery mode, no reinstall, no stress.

**Stability through declaration** — you can't accidentally break the system through random package installs or config edits that pile up over time. Everything is explicit. What's not declared doesn't exist.

**Minimal footprint** — despite running full GNOME with all extensions, PipeWire, Syncthing, Tor, fail2ban and more, idle RAM sits at ~1.2GB after boot. NixOS only runs what you declare.

**Package isolation** — Flatpak for browsers and KDE apps keeps them containerized and self-contained. Firefox is installed via NixOS packages for better system integration but sandboxed via firejail to limit system-wide access. Best of both worlds.

**Learning curve** — NixOS is completely different from any other Linux distro. Once it clicks, going back feels like a step backwards. With this repo, a new machine is fully up and running in under 40 minutes from a fresh install.

**Shell out of the box** — ble.sh (bash line editor) is declared as a Nix package in `home.nix`. No manual installation needed — autocomplete, syntax highlighting, and menu-style completion work automatically after first rebuild.

---

## Hardware

| Component | Detail |
|-----------|--------|
| Machine | Lenovo ThinkPad T480s |
| CPU | Intel Core i5-8250U (KabyLake-R) |
| GPU | Intel UHD 620 (iGPU) |
| RAM | 24GB (~1.2GB used at idle after full boot) |
| Swap | 11.6GB zram (zstd compressed, in-RAM) |
| Storage | 476.9GB NVMe SSD (LUKS2 encrypted, btrfs) |

---

## Disk Layout

Dual boot with Windows 11 on the same NVMe drive.

```
nvme0n1 (476.9GB NVMe)
├─ nvme0n1p1   200MB    /boot (EFI — shared with Windows)
├─ nvme0n1p2   16MB     Microsoft Reserved Partition
├─ nvme0n1p3   243.4GB  Windows 11 (NTFS)
└─ nvme0n1p4   233.3GB  LUKS2 encrypted
   └─ cryptroot (btrfs subvolumes)
      ├─ @              /
      ├─ @home          /home
      ├─ @nix           /nix
      ├─ @snapshots     /.snapshots
      ├─ @var-log       /var/log
      └─ @tmp           /tmp

zram0          11.6GB   Compressed swap (zstd, 50% RAM)
```

---

## Features

**Security**
- Secure Boot via [lanzaboote](https://github.com/nix-community/lanzaboote)
- Full disk encryption with LUKS2
- btrfs with zstd compression across subvolumes
- nftables firewall
- fail2ban with incremental bans
- Firefox sandboxed via firejail
- SSH key-only authentication
- Kernel hardening sysctls

**Power Management**
- TLP with per-state CPU governor (performance on AC, powersave on battery)
- throttled — fixes Intel BD PROCHOT throttling bug on T480s
- thermald for thermal management
- S3 deep sleep (`mem_sleep_default=deep`)
- Battery charge thresholds (40–80%) for long-term health
- zram swap with zstd compression

**Desktop**
- Pure Wayland GNOME
- GDM display manager
- Flatpak + Flathub
- PipeWire audio with WirePlumber
- Intel VA-API hardware video acceleration
- Plymouth boot splash

**Networking**
- WireGuard VPN via NetworkManager (ProtonVPN)
- Syncthing for file sync
- Tor client with DNS

---

## Structure

```
/etc/nixos/
├── flake.nix                     # Inputs: nixpkgs, lanzaboote, home-manager
├── flake.lock
├── configuration.nix             # Entry point, imports all modules
├── hardware-configuration.nix    # Auto-generated, do not edit
├── disko.nix                     # Declarative disk layout (LUKS2 + btrfs + EFI)
├── home.nix                      # Home Manager configuration
└── modules/
    ├── boot.nix                  # Bootloader, kernel, Plymouth, kernel params
    ├── hardware.nix              # GPU, firmware, bluetooth, btrfs, zram
    ├── networking.nix            # Hostname, firewall, SSH, fail2ban
    ├── desktop.nix               # GNOME, GDM, Flatpak, fonts, PipeWire
    ├── power.nix                 # TLP, throttled, thermald, sysctls
    ├── security.nix              # firejail, sudo-rs, hardening
    ├── packages.nix              # System packages
    └── services.nix              # Syncthing, Tor, Nix settings, GC
```

---

## Fresh Install from Live ISO or PXE Boot (netboot.xyz)

This config is designed to be installed directly from the live ISO — no standard installer, no extra reboot, no manual post-clone setup. Boot the live ISO (or PXE via netboot.xyz), clone this repo, and run the install in one go.

> Depending on what is enabled in `modules/packages.nix` and `home.nix`, the install will download packages accordingly. Current config downloads approximately **4.5GB**.

### A. Find Your NVMe Device ID

```bash
# List drives and identify your NVMe vendor
lsblk -d -o NAME,SIZE,MODEL
```

If the vendor is **INTEL**:
```bash
ls -l /dev/disk/by-id/ | grep INTEL
```

If the vendor is **TOSHIBA**:
```bash
ls -l /dev/disk/by-id/ | grep TOSHIBA
```

You will get an ID such as:
```
nvme-INTEL_SSDPEKNU512GZ_BTKA23010K50512A
```

**Put this ID into `disko.nix` before running any disko commands.**

### B. BIOS Settings

Before booting the live ISO:

1. **Secure Boot** → Disabled
2. **Setup Mode** → Enabled (puts firmware in a ready state to receive signed keys)

### C. Install Steps

Boot to the live ISO or PXE boot via a self-hosted netboot.xyz server.

```bash
# Install required tools upfront — avoids back-and-forth later
nix-shell -p git e2fsprogs sbctl

# Clone this config
git clone https://github.com/ochiuom/nixos-config
cd nixos-config

# This is an automated process targeting /dev/nvme0n1p4
# Verify the partition exists and is the correct target before wiping

lsblk
sudo wipefs -a /dev/nvme0n1p4
lsblk

# Flakes are not enabled by default on the live ISO.
# Run everything with experimental features enabled.

# Format and mount disks declaratively using disko
sudo nix --extra-experimental-features "nix-command flakes" \
  run github:nix-community/disko -- --mode format,mount ./disko.nix

# Set up Secure Boot keys
sbctl create-keys
chattr -i /sys/firmware/efi/efivars/*
sbctl enroll-keys --microsoft
```

Before running the install command, verify:

1. `flake.nix` has `disko.nix` declared as a module
2. Keyboard layout is consistent — `configuration.nix` (`console.keyMap = "us"` or `"uk"`) must match `hardware-configuration.nix` (`xkb.layout = "us"` or `"gb"`)

```bash
# Run the NixOS install (~4.5GB download, ~16GB disk space used)
sudo nix --extra-experimental-features "nix-command flakes" \
  run nixpkgs#nixos-install -- --flake .#ochinix-pc
```

When prompted, set the **root password**.

### D. First Boot

```bash
reboot
```

- Default user password on first login: `changeme`
- **Change your password immediately** after logging in
- Remove the GNOME keyring to avoid Brave browser password popup on first launch:

```bash
rm -rf ~/.local/share/keyrings
reboot
```

- After this reboot, **go into BIOS and re-enable Secure Boot** — the signed keys were enrolled during install, so it will now boot correctly with Secure Boot on
- Once back in the OS, proceed to [POST_INSTALL.md](POST_INSTALL.md) for the rest of the setup
---

## Key Commands

These aliases are defined in `home.nix`:

```bash
# Rebuild and switch
nos

# Update flake inputs and rebuild
update

# Update + rebuild + garbage collect
upgrade

# Full system upgrade (NixOS + Flatpak + firmware + GC)
UP

# Garbage collect (keep last 3 generations)
ngc

# Unlock encrypted vault
unlockv

# Lock vault
lockv
```

---

## Adding a Package — Workflow

One-time setup (run once as normal user):

```bash
sudo git config --system --add safe.directory /etc/nixos
```

Daily workflow as normal user:

```bash
cd /etc/nixos
# edit the relevant .nix file e.g. modules/packages.nix
git add .
git commit -m "add: packagename"
nos
```

---


## Heavy Packages

Some packages are expensive to build from source and should only be added when needed.

### RustDesk

RustDesk compiles from source (Rust + Flutter) and is very resource intensive:
- ~100% CPU for the entire build
- ~9GB RAM during compilation
- ~10–15 minutes build time

Commented out by default in `modules/packages.nix`:

```nix
# Uncomment only when needed — expensive to build
# rustdesk
```

To enable, uncomment and rebuild. Subsequent rebuilds use the cached store path and are instant.

### PDFStudio Viewer

PDFStudio Viewer downloads from an external server during install which can occasionally stall or fail due to server availability issues.

It is commented out by default in `modules/packages.nix`:
```nix
# Uncomment only when needed — external server can stall on download
# pdfstudioviewer
```
To enable, uncomment and rebuild. If the build hangs, cancel and retry.


---

## Post Installation

See [POST_INSTALL.md](POST_INSTALL.md) for complete post-installation setup including fonts, Tor, Neovim, organize-tool, and Flatpak apps.

---

## References

- EasyEffects community presets: https://github.com/wwmm/easyeffects/wiki/Community-presets
- Orchis GTK theme: https://www.gnome-look.org/p/1357889
- Hatteru Yaru icon theme: https://www.gnome-look.org/p/2146096
- NvChad: https://nvchad.com/docs/quickstart/install/

---

## License

Personal configuration, use freely as reference.
