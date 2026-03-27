# ochinix-pc — Post Installation Guide

> Manual steps required after a fresh NixOS deploy. Everything else is handled declaratively.

---

## Table of Contents

1. [Change Password](#1-change-password)
2. [Clone Config](#2-clone-config)
3. [Flatpak Applications](#3-flatpak-applications)
4. [Fonts](#4-fonts)
5. [Boot Splash Theme](#5-boot-splash-theme)
6. [Encrypted Vault](#6-encrypted-vault)
7. [USBGuard](#7-usbguard)
8. [ProtonVPN & DNS](#8-protonvpn--dns)
9. [Tor + Thunderbird](#9-tor--thunderbird)
10. [API Keys](#10-api-keys)
11. [Neovim / NvChad](#11-neovim--nvchad)
12. [SageMath Devshell](#12-sagemath-devshell)
13. [organize-tool](#13-organize-tool)
14. [Syncthing](#14-syncthing)
15. [GSConnect](#15-gsconnect)
16. [EasyEffects](#16-easyeffects)
17. [MPD](#17-mpd)
18. [SSH — Adding a New Client](#18-ssh--adding-a-new-client)
19. [Boot Partition Maintenance](#19-boot-partition-maintenance)

---

## 1. Change Password

`initialPassword` in `configuration.nix` is set to `changeme`. Change it immediately after first boot:

```bash
passwd ochinix
```

---

## 2. Clone Config

```bash
sudo git clone https://github.com/ochiuom/nixos-config-1os /etc/nixos
sudo chown -R ochinix:users /etc/nixos
cd /etc/nixos
```

Edit any module as needed, then rebuild:

```bash
nos       # rebuild with visual output
```

If visual glitches appear after rebuild, a logout or full reboot will apply everything cleanly.

---

## 3. Flatpak Applications

Install all Flatpak apps in one command:

```bash
flatpak install flathub \
  com.brave.Browser \
  com.microsoft.Edge \
  com.opera.Opera \
  com.github.PintaProject.Pinta \
  com.github.ahrm.sioyek \
  com.github.iwalton3.jellyfin-media-player \
  com.orama_interactive.Pixelorama \
  io.github.alainm23.planify \
  io.github.electronstudio.WeylusCommunityEdition \
  org.kde.elisa \
  org.kde.krita \
  org.kde.okular \
  org.localsend.localsend_app \
  org.octave.Octave \
  org.onlyoffice.desktopeditors \
  org.signal.Signal \
  org.telegram.desktop \
  org.mozilla.Thunderbird \
  net.code_industry.MasterPDFEditor
```

| Application | ID |
|---|---|
| Brave | `com.brave.Browser` |
| Microsoft Edge | `com.microsoft.Edge` |
| Opera | `com.opera.Opera` |
| Pinta | `com.github.PintaProject.Pinta` |
| Sioyek | `com.github.ahrm.sioyek` |
| Jellyfin Media Player | `com.github.iwalton3.jellyfin-media-player` |
| Pixelorama | `com.orama_interactive.Pixelorama` |
| Planify | `io.github.alainm23.planify` |
| Weylus Community Edition | `io.github.electronstudio.WeylusCommunityEdition` |
| Elisa | `org.kde.elisa` |
| Krita | `org.kde.krita` |
| Okular | `org.kde.okular` |
| LocalSend | `org.localsend.localsend_app` |
| GNU Octave | `org.octave.Octave` |
| ONLYOFFICE | `org.onlyoffice.desktopeditors` |
| Signal | `org.signal.Signal` |
| Telegram | `org.telegram.desktop` |
| Thunderbird | `org.mozilla.Thunderbird` |
| Master PDF Editor | `net.code_industry.MasterPDFEditor` |

---

## 4. Fonts

Fonts are managed via `home.nix` and deployed automatically on every rebuild. No manual installation needed.

**Inter** (UI font) must be present in `fonts/` in the repo:
- Download: https://fonts.google.com/specimen/Inter

On rebuild, fonts are copied to `~/.local/share/fonts/` and the font cache is refreshed automatically.

| Role | Font |
|---|---|
| Interface | Inter Regular 11 |
| Document | Noto Sans Regular 11 |
| Monospace | JetBrains Mono 10 |

---

## 5. Boot Splash Theme

Plymouth splash is configured in `modules/boot.nix`:

```nix
boot.plymouth.theme = "bgrt";
```

`bgrt` displays the vendor logo (Lenovo). No GRUB config needed — system uses `systemd-boot` with `lanzaboote`.

---

## 6. Encrypted Vault

Vault directories are created automatically on every rebuild via `home.nix`. One-time initialisation required after fresh install:

```bash
gocryptfs -init ~/Documents/.vault
# Set a strong password when prompted
```

**Directory structure:**
```
~/
├── Documents/
│   ├── .vault/     ← encrypted storage (tracked by gocryptfs)
│   └── Vault/      ← mount point (empty when locked)
└── Backups/
    └── Vault_Encrypted_Backup/
```

**Daily usage:**

```bash
unlockv    # mount vault — enter password, files appear in ~/Documents/Vault
lockv      # unmount vault — files hidden
backupv    # rsync encrypted .vault to ~/Backups
```

> Lock the vault before suspending or leaving the machine unattended.

---

## 7. USBGuard

USBGuard is enabled in `security.nix` with a hardcoded policy for the L14. On a fresh install or new machine, regenerate the policy from currently connected devices.

**Plug in all devices to whitelist first, then:**

```bash
sudo usbguard generate-policy
```

Copy the output into `security.nix` under `services.usbguard.rules`.

**Currently whitelisted on L14:**

| Device | ID |
|---|---|
| xHCI Host Controller (USB 2.0) | `1d6b:0002` |
| xHCI Host Controller (USB 3.0) | `1d6b:0003` |
| EMV Smartcard / SD Card Reader | `058f:9540` |
| Integrated Camera | `13d3:56ff` |

**Allowing a new USB device:**

```bash
# List all devices including blocked ones
sudo usbguard list-devices

# Allow temporarily (until reboot)
sudo usbguard allow-device <ID>

# Allow permanently (running policy only — not persisted to nix config)
sudo usbguard allow-device <ID> -p
```

To persist permanently, run `sudo usbguard generate-policy` again and update `security.nix`.

---

## 8. ProtonVPN & DNS

ProtonVPN is used via WireGuard through NetworkManager. No app required.

```bash
# Download WireGuard config from account.proton.me
# Rename to a valid interface name
mv ProtonVPN-config.conf protonvpn-xx.conf

nmcli connection import type wireguard file protonvpn-xx.conf
nmcli connection modify protonvpn-xx ipv6.method ignore

# Connect / disconnect
nmcli connection up protonvpn-xx
nmcli connection down protonvpn-xx
```

Toggle from GNOME top panel → network icon → VPN section.

**DNS note:** ProtonVPN pushes its own DNS which conflicts with `systemd-resolved`. DNSSEC validation is intentionally disabled in `security.nix`:

```nix
DNSSEC = "false";
DNSOverTLS = "opportunistic";
```

Do not change these values. If DNS breaks after connecting:

```bash
resolvectl status
sudo journalctl -u systemd-resolved -n 30
```

---

## 9. Tor + Thunderbird

Tor client runs on `localhost:9050`. To route Thunderbird over Tor:

**Thunderbird → Settings → General → Network Settings → Manual proxy:**

| Field | Value |
|---|---|
| SOCKS Host | `localhost` |
| Port | `9050` |
| Version | SOCKS v5 |
| DNS | Proxy DNS when using SOCKS v5 ✓ |

---

## 10. API Keys

API keys are stored in `~/.api_keys` and sourced automatically from `.bashrc`. This file is not tracked in the repo. Recreate on fresh install:

```bash
cat > ~/.api_keys << 'EOF'
export GEMINI_API_KEY="..."
export OPENROUTER_API_KEY="..."
EOF
chmod 600 ~/.api_keys
```

---

## 11. Neovim / NvChad

Neovim is installed via Nix as a bare binary. NvChad must be bootstrapped manually.

**Step 1 — Install NvChad:**

```bash
git clone https://github.com/NvChad/starter ~/.config/nvim && nvim
```

Let lazy.nvim install all plugins on first launch, then restart nvim.

**Step 2 — Apply custom config layer:**

```bash
nos
```

This copies the custom config files from the repo onto NvChad. Safe to run after every NvChad update.

**LSP verification:**

```bash
which vscode-html-language-server
which vscode-css-language-server
which latexmk
```

> Mason may report install failures for `css-lsp`, `html-lsp`, and `stylua` — these are already provided by Nix. Ignore Mason's errors.

**LaTeX keymaps (inside a `.tex` file):**

| Keymap | Action |
|---|---|
| `\ll` | Start auto-compile (lualatex, watches on save) |
| `\lk` | Stop auto-compile |
| `\lv` | Open PDF in Zathura |
| `\le` | Show compile errors |
| `\lw` | Word count |
| `\lz` | Toggle ZenMode |
| `zc` / `zo` | Fold / unfold section |
| `zM` / `zR` | Fold all / unfold all |
| `<leader>s` | Spelling suggestions |

---

## 12. SageMath Devshell

Pure Nix devshell — no conda, no pip, no ISO.

**Structure:**
```
~/Projects/Sage/
├── flake.nix    ← pinned to nixpkgs 25.11
└── flake.lock
```

**First time setup:**

```bash
cd ~/Projects/Sage
nix develop --profile ~/.local/state/nix/profiles/sage
```

> Downloads ~4.5GB on first run. The `--profile` flag pins the environment so garbage collection never removes it.

**Daily usage:**

```bash
sage-env    # alias: cd ~/Projects/Sage && nix develop
sage        # REPL
```

**Jupyter notebook:**

```bash
sage-env
sage -n jupyter
```

**Updating:**

```bash
cd ~/Projects/Sage
nix flake update
nix develop --profile ~/.local/state/nix/profiles/sage
```

---

## 13. organize-tool

Automatically sorts `~/Downloads` by file type into subfolders, running hourly via a systemd user timer declared in `home.nix`.

Install after first rebuild:

```bash
pipx install organize-tool
pipx ensurepath
organize --version
```

The config at `organize/config.yaml` is deployed automatically on every rebuild.

---

## 14. Syncthing

Syncthing starts automatically but device pairing must be done manually via the web UI on first deploy:

```
http://localhost:8384
```

Add pi5 as a remote device and configure shared folders. The pi5 device ID must be obtained from its Syncthing instance.

---

## 15. GSConnect

GSConnect is paired with Galaxy S21 Ultra. On fresh install the pairing is lost. Re-pair from the phone:

1. Open KDE Connect on Android
2. Tap the PC when it appears in the list
3. Accept the pairing request on desktop via the GSConnect notification

---

## 16. EasyEffects

EasyEffects starts automatically with preset `C+Cry+BE+Max`. If audio processing sounds incorrect after a fresh deploy:

```bash
systemctl --user restart easyeffects
```

---

## 17. MPD

MPD starts automatically pointing to `~/Music`. Populate the database on first install:

```bash
mpc update
```

---

## 18. SSH — Adding a New Client

```bash
# Step 1 — temporarily enable password auth
# Set PasswordAuthentication = true in modules/networking.nix and rebuild

# Step 2 — copy key from new client
ssh-copy-id ochinix@<machine-ip>

# Step 3 — disable password auth again
# Set PasswordAuthentication = false in modules/networking.nix and rebuild
```

**If a known client is suddenly refused**, fail2ban may have banned the IP:

```bash
sudo fail2ban-client unban <IP>
```

---

## 19. Boot Partition Maintenance

If the `/boot` partition is small (such as 196M on a dual boot with Windows), space can fill up quickly. With lanzaboote UKIs at ~60MB each and `configurationLimit = 3`, a rebuild may fail with "no space left on device":
```bash
# Check what is consuming space
du -ah /boot | sort -rh | head -20
```

Lanzaboote immediately recreates files during activation, so cleanup and rebuild must run as a single command:
```bash
# Remove everything and rebuild immediately — do not run separately
sudo rm -rf /boot/EFI/nixos/* && nos
```
