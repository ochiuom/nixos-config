
## Post Installation

### Boot Splash Theme

Using `systemd-boot` with `lanzaboote`, not GRUB. Plymouth splash is configured in `modules/boot.nix`:
```nix
boot.plymouth.theme = "bgrt";
```

`bgrt` displays your vendor logo (Lenovo on T480s). Change to any installed Plymouth theme. No GRUB config needed.

---

### Fonts

Fonts are managed via `home.nix` and deployed automatically on every rebuild — no manual installation needed.

**Inter** (UI font) is downloaded from Google Fonts and tracked in the repo under `fonts/`:
- Download: https://fonts.google.com/specimen/Inter

On rebuild, fonts are copied to `~/.local/share/fonts/` and the font cache is refreshed automatically. GNOME picks them up without any manual Tweaks configuration.

Fonts applied automatically:
- Interface text: `Inter Regular 11`
- Document text: `Noto Sans Regular 11`
- Monospace text: `JetBrains Mono 10`

---

### Tor + Thunderbird

Tor client runs locally on `localhost:9050`. To route Thunderbird email over Tor for secure sending and receiving:

In Thunderbird → Settings → General → Network Settings → Manual proxy:
- SOCKS Host: `localhost`
- Port: `9050`
- Select: `SOCKS v5`
- Check: **Proxy DNS when using SOCKS v5**

---

### organize-tool

Automatically sorts `~/Downloads` by file type into subfolders hourly via a systemd user timer declared in `home.nix`.

Install after first rebuild:
```bash
pipx install organize-tool
pipx ensurepath
organize --version
```

The config is tracked in this repo at `organize/config.yaml` and deployed automatically via `home.nix` on every rebuild — no manual file creation needed.

---

# Neovim / NvChad + LaTeX Workflow

Neovim is installed via NixOS packages but without any config files — it's a bare install. To set up NvChad as the config and plugin manager, follow the steps below.

---

## Step 1 — Install NvChad

```bash
git clone https://github.com/NvChad/starter ~/.config/nvim && nvim
```

NvChad will auto-install on first launch. Let it complete then restart nvim.

> Reference: https://nvchad.com/docs/quickstart/install/

---

## Step 2 — Apply NvChad Custom Layer from This Repo

After NvChad finishes installing on first `nvim` launch, rebuild NixOS to copy the custom config layer from this repo on top of NvChad:

```bash
sudo nixos-rebuild switch --flake /etc/nixos#ochinix-pc
```

This copies the extra config files declared in `home.nix` into `~/.config/nvim/` without replacing or breaking NvChad — safe to run after every NvChad update as well.

---

## NixOS Packages Required

Add to `environment.systemPackages` in `configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  # LSPs (via Nix, not Mason)
  vscode-langservers-extracted  # html-lsp, css-lsp, json-lsp
  stylua                        # lua formatter
  texlab                        # latex LSP

  # LaTeX
  # LaTeX
  # texlive installed separately — full scheme via official installer
  # default binary path added to PATH in bashrc via home.nix

  # PDF viewer (auto-reloads on recompile)
  zathura
];
```

> **Note:** Mason will show install failures for `css-lsp`, `html-lsp`, and `stylua` — this is expected on NixOS. These are already provided by Nix and work correctly. Ignore Mason's errors.

Verify LSPs are on PATH:

```bash
which vscode-html-language-server
which vscode-css-language-server
which latexmk
```

---

## Config File Overview

| File | Purpose |
|------|---------|
| `lua/plugins/latex.lua` | VimTeX plugin — lualatex compiler, zathura viewer, folding, conceal |
| `lua/plugins/zen.lua` | ZenMode — distraction-free writing (80 char width) |
| `lua/plugins/cmp.lua` | Adds vimtex autocomplete source on top of NvChad defaults |
| `lua/configs/lspconfig.lua` | Enables html, cssls, texlab LSP servers |
| `lua/autocmds.lua` | Tex filetype settings — wrap, spell check, keymaps |

---

## LaTeX Workflow

Open a `.tex` file in nvim, then:

| Keymap | Action |
|--------|--------|
| `\ll` | Start auto-compile with lualatex (watches file on save) |
| `\lk` | Stop auto-compile |
| `\lv` | Open PDF in Zathura |
| `\le` | Show compile errors |
| `\lw` | Word count |
| `\lz` | Toggle ZenMode |
| `zc` / `zo` | Fold / unfold section under cursor |
| `zM` / `zR` | Fold all / unfold all sections |
| `<leader>s` | Spelling suggestions on cursor |

Zathura auto-reloads the PDF on every recompile — no manual refresh needed.

---

## Mason Note

Mason is kept as-is with no changes to `ensure_installed`. It may report failures for tools already installed via Nix — these errors are harmless. Nix-managed binaries are on `$PATH` and used directly by lspconfig.

---

## Adding a New SSH Client

When you need to allow a new machine to SSH in:

1. Set `PasswordAuthentication = true` in `modules/networking.nix` and rebuild
2. From the new client: `ssh-copy-id ochinix@<T480s-IP>`
3. Set `PasswordAuthentication = false` and rebuild

> If SSH connection is suddenly refused from a known client, fail2ban may have banned your IP after too many failed attempts. Unban it on the T480s:
> ```bash
> sudo fail2ban-client unban 192.xxx.xx.xx
> ```
> Replace with your host machine's IP. Connection will work immediately after.

---

## VPN

ProtonVPN via WireGuard — no app needed, built into NetworkManager.

```bash
# Download WireGuard config from account.proton.me
# Rename to a valid interface name
mv ProtonVPN-config.conf protonvpn-xx.conf
nmcli connection import type wireguard file protonvpn-xx.conf
nmcli connection modify protonvpn-xx ipv6.method ignore

# Connect / disconnect via terminal
nmcli connection up protonvpn-xx
nmcli connection down protonvpn-xx
```

Or toggle on/off directly from the GNOME top panel → network icon → VPN section — no terminal needed.

---

### Encrypted Vault

Vault directories are created automatically on every rebuild via `home.nix`:
```
~/
├── Documents/
│   ├── .vault/     ← encrypted storage (hidden, tracked by gocryptfs)
│   └── Vault/      ← mount point (empty when locked, files visible when unlocked)
└── Backups/
    └── Vault_Encrypted_Backup/  ← rsync backup of encrypted vault
```

**One-time setup after fresh install:**
```bash
gocryptfs -init ~/Documents/.vault
# Set a strong password when prompted — this is your vault password
# Never needed again on this machine
```

**Daily usage via aliases:**
```bash
unlockv    # mount — enter vault password, files appear in ~/Documents/Vault
lockv      # unmount — files hidden again
backupv    # rsync encrypted .vault to ~/Backups (safe to backup encrypted)
```

> The vault is encrypted at rest. Even if someone accesses your disk, `.vault` contents are unreadable without the password. `lockv` before suspending or leaving the machine unattended.

---

### Flatpak Applications

Installed via Flathub. Browsers and KDE apps kept as Flatpak for sandboxing and self-containment.

| Name | Application ID |
|------|----------------|
| Brave | com.brave.Browser |
| Microsoft Edge | com.microsoft.Edge |
| Opera | com.opera.Opera |
| Pinta | com.github.PintaProject.Pinta |
| Sioyek | com.github.ahrm.sioyek |
| Jellyfin Media Player | com.github.iwalton3.jellyfin-media-player |
| Pixelorama | com.orama_interactive.Pixelorama |
| Planify | io.github.alainm23.planify |
| Weylus Community Edition | io.github.electronstudio.WeylusCommunityEdition |
| Elisa | org.kde.elisa |
| Krita | org.kde.krita |
| Okular | org.kde.okular |
| LocalSend | org.localsend.localsend_app |
| GNU Octave | org.octave.Octave |
| ONLYOFFICE Desktop Editors | org.onlyoffice.desktopeditors |
| Signal Desktop | org.signal.Signal |
| Telegram | org.telegram.desktop |
| Thunderbird | org.mozilla.Thunderbird |

Install all at once:
```bash
flatpak install flathub com.brave.Browser com.microsoft.Edge com.opera.Opera com.github.PintaProject.Pinta com.github.ahrm.sioyek com.github.iwalton3.jellyfin-media-player com.orama_interactive.Pixelorama io.github.alainm23.planify io.github.electronstudio.WeylusCommunityEdition org.kde.elisa org.kde.krita org.kde.okular org.localsend.localsend_app org.octave.Octave org.onlyoffice.desktopeditors org.signal.Signal org.telegram.desktop org.mozilla.Thunderbird
```

---

## Managing Packages & Config

Once settled post-installation, clone the config into `/etc/nixos` to add packages or modify any module:

```bash
sudo git clone https://github.com/ochiuom/nixos-config /etc/nixos
sudo chown -R ochinix:users /etc/nixos
cd /etc/nixos

# Edit any .nix file as needed e.g. modules/packages.nix
# Then rebuild — quick
nsr
# or with visual output and generation diff tracking
nos
```

# If you notice any visual glitches or changes not reflected after rebuild,
# a logout or full reboot will apply everything cleanly
---
