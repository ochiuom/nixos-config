{ config, pkgs, lib, ... }:
{

  # ── tmux ──────────────────────────────────────────────────────────────────
  # Set as the default shell command so every new terminal opens tmux.
  programs.tmux = {
    enable        = true;
    clock24       = true;
    escapeTime    = 0;
    historyLimit  = 50000;
    mouse         = true;
    # tmux-256color is the correct value for default-terminal inside tmux;
    # the xterm-256color:RGB override below keeps true-colour working.
    terminal      = "tmux-256color";
    baseIndex     = 1;
    keyMode       = "vi";
    prefix        = "C-a";
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      resurrect
      continuum
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha'
          set -g @catppuccin_window_default_text "#W"
          set -g @catppuccin_window_current_text "#W"
          set -g @catppuccin_status_modules_right "session date_time"
          set -g @catppuccin_date_time_text "%H:%M"
        '';
      }
    ];
    extraConfig = ''
      set -ag terminal-overrides ",xterm-256color:RGB"

      # ── Pane splits (keep cwd) ─────────────────────────────────────────
      bind \\ split-window -h -c "#{pane_current_path}"
      bind -  split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # ── Pane navigation (vim-style) ────────────────────────────────────
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # ── Pane resize ───────────────────────────────────────────────────
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # ── New window keeps cwd ──────────────────────────────────────────
      bind c new-window -c "#{pane_current_path}"

      # ── Reload config ─────────────────────────────────────────────────
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

      # ── Resurrect / continuum ─────────────────────────────────────────
      set -g @resurrect-capture-pane-contents 'on'
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '10'
    '';
  };



  # Kitty and Ghostty are managed via home.file in files.nix or here
  home.file.".config/ghostty/config".text = ''
    window-width = 105
    window-height = 40
    window-step-resize = true
    font-family = JetBrains Mono
    font-size = 10
    cursor-style = block
    cursor-style-blink = true
    shell-integration = none 
    gtk-single-instance = true
    background = #2c2c2c
    keybind = ctrl+shift+e=new_window
    keybind = ctrl+shift+n=new_tab
  '';

}
