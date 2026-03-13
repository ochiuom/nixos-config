{ pkgs, config, ... }:

let
  pythonEnv = pkgs.python3.withPackages (ps: [ ps.requests ]);
  cacheDir  = "${config.xdg.cacheHome}/desktop-quote";

  quoteScript = pkgs.writeShellScriptBin "desktop-quote-fetch" ''
    export QUOTE_CACHE_DIR="${cacheDir}"
    ${pythonEnv}/bin/python3 ${./quote.py}
  '';

  extensionUuid = "desktop-quote@ochinix";

  desktopQuoteExtension = pkgs.stdenvNoCC.mkDerivation {
    name = "gnome-shell-extension-desktop-quote";
    src = ./extension;
    installPhase = ''
      mkdir -p $out/share/gnome-shell/extensions/${extensionUuid}
      cp -r $src/. $out/share/gnome-shell/extensions/${extensionUuid}/
    '';
  };
in
{
  home.packages = [ quoteScript ];

  # Install extension
  home.file.".local/share/gnome-shell/extensions/${extensionUuid}".source =
    "${desktopQuoteExtension}/share/gnome-shell/extensions/${extensionUuid}";

  # Enable extension via dconf
 #  dconf.settings."org/gnome/shell".enabled-extensions =
 #   [ extensionUuid ];

  # Fetch timer
  systemd.user.services.desktop-quote-fetch = {
    Unit.Description = "Fetch daily desktop quote";
    Service = {
      Type = "oneshot";
      ExecStart = "${quoteScript}/bin/desktop-quote-fetch";
    };
  };

  systemd.user.timers.desktop-quote-fetch = {
    Unit.Description = "Daily desktop quote timer";
    Timer = {
      OnBootSec = "30s";
      OnUnitActiveSec = "24h";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
