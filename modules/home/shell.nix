{ config, pkgs, lib, ... }:
{
  programs.bash = {
    enable           = true;
    enableCompletion = true;

    shellAliases = {

      # ── Navigation ────────────────────────────────────────────────────────
      ".."   = "cd ..";
      "..."  = "cd ../..";
      "~"    = "cd ~";
      c      = "clear";
      reload = "source ~/.bashrc";
      j      = "zi";

      # ── Safety ────────────────────────────────────────────────────────────
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";

      # ── Listing (eza) ─────────────────────────────────────────────────────
      ls = "eza -a --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first --time-style=long-iso";
      lt = "eza -T --level=2 --icons";
      la = "eza -A --icons";
      l  = "eza --icons";

      # ── Modern Replacements ───────────────────────────────────────────────
      cat  = "bat";
      grep = "rg";
      top  = "btop";
      find = "fd";
      du   = "dust";
      df   = "duf";
      bw   = "sudo bandwhich";
      br   = "broot";
      nav  = "navi";
      f    = "pay-respects";
      a2   = "aria2c -x 16 -s 16 -k 1M";

      # ── Git ───────────────────────────────────────────────────────────────
      gs  = "git status";
      ga  = "git add .";
      gc  = "git commit -m";
      gp  = "git push";
      gd  = "git diff";
      gds = "git diff --staged";
      lg  = "lazygit";

      # ── Tmux ──────────────────────────────────────────────────────────────
      ta = "tmux attach || tmux new-session -s main";
      tn = "tmux new-session -s";
      tl = "tmux list-sessions";
      tk = "tmux kill-session -t";

      # ── NixOS ─────────────────────────────────────────────────────────────
      nos     = "nh os switch --hostname ochinix-pc";
      nrs     = "nh os switch --hostname ochinix-pc";
      ngc     = "sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system && sudo nix-store --gc";
      update  = "cd /etc/nixos && sudo nix flake update && nh os switch --hostname ochinix-pc";
      upgrade = "cd /etc/nixos && sudo nix flake update && nh os switch --hostname ochinix-pc && ngc";

      # ── System ────────────────────────────────────────────────────────────
      cleanram      = "sudo sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null && echo 'RAM cleared'";
      clean-journal = "sudo journalctl --vacuum-time=7d";
      big           = "sudo du -ahx / | sort -rh | head -n 20";
      lsblk         = "lsblk -e7";
      bootload      = "systemd-analyze blame | head -n 10";
      zstat         = "zramctl";
      ssd           = "sudo compsize -x /";
      battery       = "upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E 'state|to empty|percentage'";
      watts         = "upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep energy-rate";

      # ── Vault ─────────────────────────────────────────────────────────────
      unlockv = "gocryptfs -allow_other ~/Documents/.vault ~/Documents/Vault";
      lockv   = "fusermount -u -z ~/Documents/Vault";
      backupv = "mkdir -p ~/Backups && rsync -av --delete ~/Documents/.vault ~/Backups/Vault_Encrypted_Backup/";

      # ── Torrents ──────────────────────────────────────────────────────────
      torrent-open  = "gocryptfs ~/Videos/.Fragments-vault ~/Videos/Fragments";
      torrent-play  = "gocryptfs ~/Videos/.Fragments-vault ~/Videos/Fragments && mpv ~/Videos/Fragments";
      torrent-close = "fusermount -u ~/Videos/Fragments";

      # ── Projects ──────────────────────────────────────────────────────────
      sage-env = "cd ~/Projects/Sage && nix develop --profile ~/.local/state/nix/profiles/sage";

      gnuplot  = "G_MESSAGES_DEBUG=none QT_QPA_PLATFORM=wayland GNUPLOT_LIB='$HOME/.config/gnuplot/lib:$HOME/.config/gnuplot/templates' gnuplot 2>/dev/null";
      sageroot = "source $(root-config --prefix)/bin/thisroot.sh";
      octave   = "flatpak run org.octave.Octave";

      # ── Disk Usage Dashboard ──────────────────────────────────────────────
      usage = ''
        echo "" &&
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" &&
        echo "  💽  DISK" &&
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" &&
        duf --only local &&
        echo "" &&
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" &&
        echo "  📦  NIX STORE  (top 15)" &&
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" &&
        dust /nix/store -d 1 -n 15 -x &&
        echo "" &&
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" &&
        echo "  🏠  HOME  (top 15)" &&
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" &&
        dust ~ -d 1 -n 15 -x &&
        echo "" &&
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" &&
        echo "  📱  FLATPAK APPS" &&
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" &&
        dust ~/.var/app -d 1 -n 10 -x &&
        echo "" &&
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" &&
        echo "  🔄  NIX GENERATIONS" &&
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" &&
        sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -5 &&
        echo ""
      '';

      # ── Full System Clean ─────────────────────────────────────────────────
      clean-all = ''
        echo '🧹 Starting full system clean...' &&
        rm -rf ~/.cache/mozilla/firefox/*.default/cache2 &&
        rm -rf ~/.var/app/com.brave.Browser/cache/BraveSoftware/Brave-Browser/Default/Cache &&
        echo '✔ Browser caches cleared' &&
        sudo journalctl --vacuum-time=7d &&
        echo '✔ Journal vacuumed' &&
        flatpak uninstall --unused -y &&
        echo '✔ Flatpak orphans removed' &&
        nh clean all --keep 0 --keep-since 1d &&
        echo '✔ Nix generations cleaned' &&
        sudo nix-store --optimise &&
        echo '✔ Nix store optimised' &&
        echo '✅ Full clean done'
      '';
    };

    sessionVariables = {
      EDITOR              = "nvim";
      VISUAL              = "nvim";
      CLICOLOR            = "1";
      LESS                = "-RFMX";
      HISTSIZE            = "50000";
      HISTFILESIZE        = "200000";
      HISTCONTROL         = "ignoredups:erasedups:ignorespace";
      HISTTIMEFORMAT      = "%F %T ";
      HISTIGNORE          = "ls:ll:la:cd:pwd:exit:clear";
      FZF_DEFAULT_OPTS    = "--height 40% --layout=reverse --border --inline-info --color=header:italic";
      FZF_COMPLETION_TRIGGER = "**";
      QT_QPA_PLATFORM     = "wayland;xcb";
      GNUPLOT_LIB         = "$HOME/.config/gnuplot/lib:$HOME/.config/gnuplot/templates";
    };

    initExtra = ''
      export TERM=xterm-256color
      shopt -s checkwinsize histappend globstar
      PROMPT_COMMAND="history -a; history -c; history -r"
      bind "set bell-style none"           2>/dev/null
      bind "set completion-ignore-case on" 2>/dev/null
      bind -x '"\ec": "zi\n"'

      # ── UP: Full System Upgrade ───────────────────────────────────────────
      UP() {
        local start_time=$(date +%s)
        local failed=()
        _up_header() {
          echo -e "\n\033[1;36m╔══════════════════════════════════════╗\033[0m"
          echo -e "\033[1;36m║       🚀 Full System Upgrade          ║\033[0m"
          echo -e "\033[1;36m║   $(date '+%Y-%m-%d %H:%M:%S')            ║\033[0m"
          echo -e "\033[1;36m╚══════════════════════════════════════╝\033[0m\n"
        }
        _up_step() { echo -e "\033[1;33m▶ $1...\033[0m"; }
        _up_ok()   { echo -e "\033[1;32m  ✔ $1\033[0m"; }
        _up_fail() { echo -e "\033[1;31m  ✘ $1 failed\033[0m"; failed+=("$1"); }
        _up_run() {
          local name="$1"; shift
          _up_step "$name"
          if "$@"; then _up_ok "$name"; else _up_fail "$name"; fi
          echo
        }
        _up_header
        _up_run "Updating Nix Flake"   bash -c "cd /etc/nixos && sudo nix flake update"
        _up_run "Rebuilding NixOS"     nh os switch --hostname ochinix-pc
        _up_run "Updating Flatpaks"    bash -c "flatpak update -y && flatpak uninstall --unused -y"
        _up_run "Cleaning Generations" bash -c "sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system && sudo nix-store --gc"
        local end_time=$(date +%s)
        local elapsed=$((end_time - start_time))
        local minutes=$((elapsed / 60))
        local seconds=$((elapsed % 60))
        if [ ''${#failed[@]} -eq 0 ]; then
          echo -e "\033[1;32m╔══════════════════════════════════════╗\033[0m"
          echo -e "\033[1;32m║   ✅ System upgrade complete!         ║\033[0m"
          echo -e "\033[1;32m║   ⏱  Time: ''${minutes}m ''${seconds}s\033[0m"
          echo -e "\033[1;32m╚══════════════════════════════════════╝\033[0m\n"
        else
          echo -e "\033[1;31m╔══════════════════════════════════════╗\033[0m"
          echo -e "\033[1;31m║   ⚠  Upgrade completed with errors   ║\033[0m"
          echo -e "\033[1;31m║   ⏱  Time: ''${minutes}m ''${seconds}s\033[0m"
          echo -e "\033[1;31m╚══════════════════════════════════════╝\033[0m"
          echo -e "\033[1;31m  Failed steps: ''${failed[*]}\033[0m\n"
          return 1
        fi
      }

      # ── fzf Helpers ───────────────────────────────────────────────────────
      fif() {
        rg --files-with-matches --no-messages "$1" \
          | fzf --preview "rg --ignore-case --pretty --context 10 '$1' {}" \
          | xargs -r nvim
      }

      _fzf_cd() {
        local dir
        dir=$(fd -t d | fzf --preview 'eza --tree --level=2 --icons {}' --preview-window=right:50%)
        [ -n "$dir" ] && cd "$dir"
      }

      _fzf_comprun() {
        local command=$1; shift
        case "$command" in
          cd)           fzf --preview 'eza --tree --level=2 --icons {}' "$@" ;;
          export|unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
          ssh)          fzf --preview 'dig {}' "$@" ;;
          *)            fzf --preview 'bat -n --color=always {}' "$@" ;;
        esac
      }

      bind -x '"\C-f": _fzf_cd'

      # ── syncto: Colourised rsync Helper ───────────────────────────────────
      syncto() {
        local src="$1" dest="$2" label="$3"
        local BOLD='\033[1m' CYAN='\033[0;36m' GREEN='\033[0;32m'
        local YELLOW='\033[0;33m' RED='\033[0;31m' RESET='\033[0m'
        echo -e "\n''${BOLD}''${CYAN}╔══════════════════════════════════════╗''${RESET}"
        echo -e "''${BOLD}''${CYAN}║  🔄  RSYNC → ''${label}''${RESET}"
        echo -e "''${BOLD}''${CYAN}╚══════════════════════════════════════╝''${RESET}"
        echo -e "''${YELLOW}  SRC :''${RESET} $src"
        echo -e "''${YELLOW}  DEST:''${RESET} $dest\n"
        rsync -avz --delete --info=progress2 --human-readable "$src" "$dest" \
          2>&1 | while IFS= read -r line; do
            if   [[ "$line" =~ ^deleting ]];                    then echo -e "''${RED}  $line''${RESET}"
            elif [[ "$line" =~ "bytes/sec"|"total size" ]];     then echo -e "''${GREEN}  $line''${RESET}"
            elif [[ "$line" =~ ^sending|^receiving ]];          then echo -e "''${CYAN}  $line''${RESET}"
            else echo "  $line"
            fi
          done
        echo -e "\n''${GREEN}''${BOLD}✓ Done: ''${label}''${RESET}\n"
      }

      alias syncvault='syncto /home/ochinix/Documents/Vault/ pi5:/home/ochiuom/Nixos/Vault/ "Vault"'
      alias syncworkdir='syncto /home/ochinix/workdir/ pi5:/home/ochiuom/Nixos/workdir/ "Workdir"'

      # ── atuin — better history search ─────────────────────────────────────
      if command -v atuin >/dev/null 2>&1; then
        eval "$(atuin init bash)"
      fi

      # ── fzf keybindings ───────────────────────────────────────────────────
      eval "$(fzf --bash)"
    '';
  };

  # ── Program Integrations ──────────────────────────────────────────────────
  programs.fzf          = { enable = true; enableBashIntegration = true; };
  programs.zoxide       = { enable = true; enableBashIntegration = true; };
  programs.starship     = { enable = true; enableBashIntegration = true; };
  programs.pay-respects = { enable = true; enableBashIntegration = true; };
  programs.direnv       = { enable = true; enableBashIntegration = true; nix-direnv.enable = true; };
  programs.carapace     = { enable = true; enableBashIntegration = true; };
  programs.bat          = { enable = true; config.theme = "TwoDark"; };
  programs.btop         = { enable = true; settings.vim_keys = true; };
  programs.vscode       = { enable = true; package = pkgs.vscode.fhs; };
  programs.atuin        = {
    enable               = true;
    enableBashIntegration = true;
    settings = {
      style         = "compact";
      inline_height = 15;
      ctrl_n_shortcuts = true;
    };
  };

  programs.broot = {
    enable                = true;
    enableBashIntegration = true;
    settings = {
      modal = true;
      skin = {
        default         = "rgb(220, 220, 220) none";
        tree            = "rgb(89, 148, 220) none";
        file            = "rgb(220, 220, 220) none";
        directory       = "rgb(89, 148, 220) none Bold";
        exe             = "rgb(147, 220, 147) none";
        link            = "rgb(220, 147, 220) none";
        pruning         = "rgb(150, 150, 150) none Italic";
        selected_line   = "none rgb(40, 40, 60)";
        char_match      = "rgb(220, 220, 100) none Bold";
        file_error      = "rgb(220, 100, 100) none";
        flag_label      = "rgb(220, 220, 220) none";
        flag_value      = "rgb(220, 147, 89) none Bold";
        input           = "rgb(220, 220, 220) none";
        status_error    = "rgb(220, 100, 100) rgb(40, 40, 40)";
        status_job      = "rgb(89, 220, 220) rgb(40, 40, 40)";
        status_normal   = "rgb(220, 220, 220) rgb(40, 40, 40)";
        status_italic   = "rgb(220, 147, 89) rgb(40, 40, 40)";
        status_bold     = "rgb(220, 220, 100) rgb(40, 40, 40) Bold";
        status_code     = "rgb(147, 220, 220) rgb(40, 40, 40)";
        status_ellipsis = "rgb(220, 220, 220) rgb(40, 40, 40)";
        scrollbar_thumb = "rgb(89, 148, 220) none";
        scrollbar_track = "rgb(40, 40, 40) none";
        help_paragraph  = "rgb(220, 220, 220) none";
        help_bold       = "rgb(220, 220, 100) none Bold";
        help_italic     = "rgb(220, 147, 89) none Italic";
        help_code       = "rgb(147, 220, 220) none";
        help_headers    = "rgb(89, 148, 220) none Bold";
      };
    };
  };
}
