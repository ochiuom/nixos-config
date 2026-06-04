{config, lib, pkgs, ... }:

with lib;
{
  options = {
    kernelcore.security.clamav.enable = mkEnableOption "Enable ClamAV antivirus scanning";
  };


  config = mkIf config.kernelcore.security.clamav.enable {
    ##########################################################################
    # 🦠 ClamAV Antivirus
    ##########################################################################
    services.clamav = {
      daemon.enable = true;
      updater.enable = true;
      updater.interval = "daily";
      updater.frequency = 12;
    };


    systemd.tmpfiles.rules = [
      "d /var/log/clamav 0755 clamav clamav -"
     ];

    # Allow users in wheel group to run clamscan without password
    security.sudo.extraRules = [
      {
        groups = [ "wheel" ];
        commands = [
          {
            command = "${pkgs.clamav}/bin/clamscan";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    environment.systemPackages = [ pkgs.clamav ];

    # ClamAV daemon hardening
    systemd.services."clamav-daemon".serviceConfig = {
      PrivateTmp = mkForce true;
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ReadWritePaths = [
        "/var/lib/clamav"
        "/var/log/clamav"
      ];
    };

    # ClamAV scan service
    systemd.services.clamav-scan = {
      description = "ClamAV /home scan";
      after = [ "clamav-daemon.service" ];
      serviceConfig = {
        Type = "oneshot";
        Nice = 19;
        IOSchedulingClass = "idle";
        PrivateTmp = true;
        ReadOnlyPaths = [ "/home" ];
        ReadWritePaths = [ "/var/log/clamav" ];
        ExecStart = ''
          ${pkgs.clamav}/bin/clamscan \
            --recursive \
            --infected \
            --log=/var/log/clamav/scan.log \
            --exclude-dir="^/sys" \
            --exclude-dir="^/proc" \
            --exclude-dir="^/dev" \
            --exclude-dir="^/run" \
            --exclude-dir="^/nix/store" \
            --max-filesize=100M \
            --max-scansize=300M \
            /home
        '';
      };
    };

    # Weekly scan timer
    systemd.timers.clamav-scan = {
      description = "Weekly ClamAV scan";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        RandomizedDelaySec = "2h";
        Persistent = true;
      };
    };
  };
}
