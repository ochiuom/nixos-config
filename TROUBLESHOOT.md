# Troubleshooting

## A. Re-running Install After Config Mistakes

Common mistakes during fresh install:
- Wrong or missing NVMe device ID in `disko.nix` (check with `ls -l /dev/disk/by-id/ | grep INTEL`)
- Missing module or input declaration in `flake.nix`

If disko already ran and disks are mounted, you can fix the config and re-run the install without reformatting:

```bash
cd /mnt/home/ochinix/
git clone https://github.com/ochiuom/nixos-config
cd nixos-config

# Fix the mistake in disko.nix or flake.nix, then re-run install
sudo nixos-install --flake .#ochinix-pc
```

## B. Chrooting into the System

If something goes wrong (e.g. root account locked after a bad `nrs` or `nos` build, lost password), you can chroot in from the live ISO or PXE boot via netboot.xyz and make changes directly.

### Mount the Encrypted System

```bash
sudo cryptsetup open /dev/disk/by-partlabel/disk-main-crypt cryptroot
sudo mount -o subvol=@ /dev/mapper/cryptroot /mnt
sudo mount -o subvol=@home /dev/mapper/cryptroot /mnt/home
sudo mount -o subvol=@nix /dev/mapper/cryptroot /mnt/nix
sudo mount /dev/disk/by-partlabel/disk-main-ESP /mnt/boot
nixos-enter
```

### Make Your Changes

For example, reset a locked user password:

```bash
passwd ochinix
```

> Use a simple temporary password — letters only, no special characters. You will change it properly after reboot.

### Safe Exit Sequence

Order matters here — do not skip steps:

```bash
sync    # commit changes from RAM to disk
exit    # leave the nixos-enter environment safely
reboot
```

### After Reboot

Log in with the temporary password, then set a proper one and clean up:

```bash
passwd
rm -rf ~/.local/share/keyrings
reboot
```
