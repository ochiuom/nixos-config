{ config, pkgs, lib, ... }:
{
  # ── tmux ──────────────────────────────────────────────────────────────────
  programs.tmux = {
    enable        = true;
    clock24       = true;
    escapeTime    = 0;
    historyLimit  = 50000;
    mouse         = true;
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
      bind \\ split-window -h -c "#{pane_current_path}"
      bind -  split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5
      bind c new-window -c "#{pane_current_path}"
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"
      set -g @resurrect-capture-pane-contents 'on'
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '10'
    '';
  };

  # ── Ghostty ───────────────────────────────────────────────────────────────
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
