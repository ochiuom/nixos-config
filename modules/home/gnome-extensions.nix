# modules/home/gnome-extensions.nix
{ config, pkgs, lib, ... }:

{
  dconf.settings = {

    # ── Blur My Shell ─────────────────────────────────────────────────
    "org/gnome/shell/extensions/blur-my-shell" = {
      settings-version = 2;
      brightness       = 0.75;
      sigma            = 30;
    };

    "org/gnome/shell/extensions/blur-my-shell/applications" = {
      blur             = true;
      blur-on-overview = true;
      dynamic-opacity  = true;
      enable-all       = true;
      opacity          = 200;
      sigma            = 10;
    };

    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      blur        = false; 
      brightness  = 0.6;
      sigma       = 20;
      static-blur = true;
    };

    "org/gnome/shell/extensions/blur-my-shell/overview" = {
      blur             = true;
      style-components = 3;
    };

    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      blur = true;
    };

    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      blur               = true;
      pipeline           = "pipeline_default_rounded";
      static-blur        = true;
      style-dash-to-dock = 0;
    };

    # ── Caffeine ──────────────────────────────────────────────────────
    "org/gnome/shell/extensions/caffeine" = {
      cli-toggle             = false;
      indicator-position-max = 2;
    };

    # ── Compiz Windows Effect ─────────────────────────────────────────
    "com/github/hermes83/compiz-windows-effect" = {
      last-version  = 29;
      preset        = "R";
      resize-effect = true;
    };

    # ── Compiz Magic Lamp ─────────────────────────────────────────────
    "ncom/github/hermes83/compiz-alike-magic-lamp-effect" = {
      effect = "sine";
    };

    # ── Compact Top Bar ───────────────────────────────────────────────
    "org/gnome/shell/extensions/compact-top-bar" = {
      fade-text-on-fullscreen = false;
    };

    # ── Dash to Panel ─────────────────────────────────────────────────
    "org/gnome/shell/extensions/dash-to-panel" = {
      animate-appicon-hover-animation-extent = "{'RIPPLE': 4, 'PLANK': 4, 'SIMPLE': 1}";
      appicon-margin          = 1;
      appicon-padding         = 4;
      dot-position            = "BOTTOM";
      group-apps              = true;
      hotkeys-overlay-combo   = "TEMPORARILY";
      panel-anchors           = ''{"BOE-0x00000000":"MIDDLE"}'';
      panel-element-positions = ''{"BOE-0x00000000":[{"element":"showAppsButton","visible":true,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}]}'';
      panel-lengths           = ''{"BOE-0x00000000":100}'';
      panel-positions         = ''{"BOE-0x00000000":"TOP"}'';
      panel-sizes             = ''{"BOE-0x00000000":29}'';
      show-favorites-all-monitors   = false;
      trans-panel-opacity           = 0.0;
      trans-use-border              = true;
      trans-use-custom-bg           = false;
      trans-use-custom-gradient     = false;
      trans-use-custom-opacity      = true;
      window-preview-title-position = "TOP";
    };

    # ── IP Finder ─────────────────────────────────────────────────────
    "org/gnome/shell/extensions/ip-finder" = {
      position-in-panel = "center";
    };

    # ── Rounded Window Corners ────────────────────────────────────────
    "org/gnome/shell/extensions/rounded-window-corners-reborn" = {
      border-radius        = 12;
      smoothing            = 1;
      keep-rounded-corners = true;
      skip-libadwaita-app  = true;
    };

    # ── Search Light ──────────────────────────────────────────────────
    "org/gnome/shell/extensions/search-light" = {
      animation-speed   = 100.0;
      blur-brightness   = 0.6;
      blur-sigma        = 30.0;
      border-thickness  = 0;
      entry-font-size   = 1;
      preferred-monitor = 0;
      scale-height      = 0.1;
      scale-width       = 0.1;
      shortcut-search   = [ "<Control>space" ];
      show-panel-icon   = false;
    };

    # ── Space Bar ─────────────────────────────────────────────────────
    "org/gnome/shell/extensions/space-bar/behavior" = {
      always-show-numbers   = true;
      position              = "center";
      scroll-wheel          = "panel";
      show-empty-workspaces = true;
      smart-workspace-names = true;
      toggle-overview       = false;
    };

    "org/gnome/shell/extensions/space-bar/appearance" = {
      active-workspace-font-weight   = "800";
      active-workspace-padding-h     = 10;
      active-workspace-padding-v     = 0;
      empty-workspace-font-weight    = "800";
      empty-workspace-padding-h      = 10;
      inactive-workspace-font-weight = "800";
      inactive-workspace-padding-h   = 10;
      workspace-margin               = 2;
      workspaces-bar-padding         = 12;
      application-styles = ''
        .space-bar {
          -natural-hpadding: 12px;
        }
        .space-bar-workspace-label.active {
          margin: 0 4px;
          background-color: rgba(255,255,255,0.3);
          color: rgba(255,255,255,1);
          border-color: rgba(0,0,0,0);
          font-weight: 700;
          border-radius: 4px;
          border-width: 0px;
          padding: 3px 8px;
        }
        .space-bar-workspace-label.inactive {
          margin: 0 4px;
          background-color: rgba(0,0,0,0);
          color: rgba(255,255,255,1);
          border-color: rgba(0,0,0,0);
          font-weight: 700;
          border-radius: 4px;
          border-width: 0px;
          padding: 3px 8px;
        }
        .space-bar-workspace-label.inactive.empty {
          margin: 0 4px;
          background-color: rgba(0,0,0,0);
          color: rgba(255,255,255,0.5);
          border-color: rgba(0,0,0,0);
          font-weight: 700;
          border-radius: 4px;
          border-width: 0px;
          padding: 3px 8px;
        }
      '';
    };

    # ── Tiling Assistant ──────────────────────────────────────────────
    "org/gnome/shell/extensions/tiling-assistant" = {
      default-move-mode           = 0;
      default-wrap-mode           = 0;
      dynamic-keybinding-behavior = 0;
      enable-tiling-popup         = true;
      maximize-with-gap           = true;
      restore-window              = [ "<Super>Down" ];
      tile-left-half              = [ "<Super>Left" "<Super>KP_4" ];
      tile-right-half             = [ "<Super>Right" "<Super>KP_6" ];
      tile-maximize               = [ "<Super>Up" "<Super>KP_5" ];
      tile-bottom-half            = [ "<Super>KP_2" ];
      tile-top-half               = [ "<Super>KP_8" ];
      tile-bottomleft-quarter     = [ "<Super>KP_1" ];
      tile-bottomright-quarter    = [ "<Super>KP_3" ];
      tile-topleft-quarter        = [ "<Super>KP_7" ];
      tile-topright-quarter       = [ "<Super>KP_9" ];
      window-gap                  = 4;
    };

    # ── TopHat ────────────────────────────────────────────────────────
    "org/gnome/shell/extensions/tophat" = {
      mount-to-monitor = "/";
    };

    # ── Astra Monitor ─────────────────────────────────────────────────
    "org/gnome/shell/extensions/astra-monitor" = {
      headers-height          = 0;
      headers-height-override = 0;
      memory-header-bars      = false;
      memory-header-icon      = false;
      memory-header-value     = true;
      memory-indicators-order = ''["icon","bar","graph","percentage","value","free"]'';
      monitors-order          = "['processor','gpu','memory','storage','network','sensors']";
      network-header-graph    = false;
      network-header-icon     = false;
      network-header-io       = true;
      network-indicators-order = ''["icon","IO bar","IO graph","IO speed"]'';
      processor-header-graph      = false;
      processor-header-icon       = false;
      processor-header-percentage = true;
      processor-indicators-order  = ''["icon","bar","graph","percentage","frequency"]'';
      sensors-header-show         = false;
      sensors-indicators-order    = ''["icon","value"]'';
      storage-header-show         = false;
      storage-indicators-order    = ''["icon","bar","percentage","value","free","IO bar","IO graph","IO speed"]'';
      storage-main                = "name-cryptroot";
      gpu-indicators-order        = ''["icon","activity bar","activity graph","activity percentage","memory bar","memory graph","memory percentage","memory value"]'';
    };

    # ── Burn My Windows ───────────────────────────────────────────────
    "org/gnome/shell/extensions/burn-my-windows" = {
      active-profile = "/home/ochinix/.config/burn-my-windows/profiles/1772478478967790.conf";
    };

    # ── Advanced Weather ──────────────────────────────────────────────
    "org/gnome/shell/extensions/advanced-weather" = {
      weather-provider = "openmeteo";
    };

    # ── Penguin AI Chatbot ────────────────────────────────────────────
    "org/gnome/shell/extensions/penguin-ai-chatbot" = {
      anthropic-model    = "claude-3-sonnet-20240229";
      gemini-model       = "gemini-2.0-flash";
      llm-provider       = "openrouter";
      openai-model       = "gpt-4o";
      openrouter-model   = "arcee-ai/trinity-large-preview:free";
      open-chat-shortcut = [ "<Control><Super>l" ];
      weather-latitude   = 52.52;
      weather-longitude  = 13.41;
    };

    # ── Wallpaper Slideshow ───────────────────────────────────────────
    "org/gnome/shell/extensions/azwallpaper" = {
      bing-download-directory      = "/home/ochinix/Pictures/WP-2026/Bing2025";
      slideshow-change-slide-event = 0;
      slideshow-directory          = "/home/ochinix/Pictures/WP-2026/BING Wallpapers (from November 2021) 1920x1080";
      slideshow-pause              = false;
      slideshow-queue-reshuffle-on-complete        = false;
      slideshow-queue-sort-type                    = "Newest";
      slideshow-show-quick-settings-entry          = true;
      slideshow-use-absolute-time-for-duration     = false;
    };

    # ── GSConnect ─────────────────────────────────────────────────────
    "org/gnome/shell/extensions/gsconnect" = {
      name = "ochinix-pc";
    };

  };
}
