{ config, pkgs, lib, ... }:
{
  # ── Sudo ─────────────────────────────────────────────────────────────────────
  security.sudo.enable = false;
  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = true;
  };

  # ── AppArmor ─────────────────────────────────────────────────────────────────
  security.apparmor = {
    enable = true;
    enableCache = true;
    killUnconfinedConfinables = true;
    packages = [ pkgs.apparmor-profiles ];
  };

  # ── Firejail ─────────────────────────────────────────────────────────────────
  # Firefox excluded — Flatpak sandbox handles it better on NixOS
  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      mpv = {
        executable = "${lib.getBin pkgs.mpv}/bin/mpv";
        profile = "${pkgs.firejail}/etc/firejail/mpv.profile";
      };
      audacious = {
        executable = "${lib.getBin pkgs.audacious}/bin/audacious";
        profile = "${pkgs.firejail}/etc/firejail/audacious.profile";
      };
      vlc = {
        executable = "${lib.getBin pkgs.vlc}/bin/vlc";
        profile = "${pkgs.firejail}/etc/firejail/vlc.profile";
      };
    };
  };

  # ── Kernel hardening ─────────────────────────────────────────────────────────
  boot.kernel.sysctl = {
    "kernel.kptr_restrict"  = 2;
    "kernel.dmesg_restrict" = 1;
    "kernel.yama.ptrace_scope" = 1;
    # "kernel.unprivileged_userns_clone" = 0; # breaks Flatpak sandbox

    "net.ipv4.icmp_echo_ignore_broadcasts"       = 1;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    "net.ipv4.conf.all.accept_redirects"         = 0;
    "net.ipv6.conf.all.accept_redirects"         = 0;
    "net.ipv4.conf.all.send_redirects"           = 0;
    "net.ipv4.conf.all.log_martians"             = 1;
    "net.ipv4.tcp_syncookies"                    = 1;
    "net.ipv4.conf.all.rp_filter"                = 1;
    "net.ipv4.conf.default.rp_filter"            = 1;
    "net.ipv4.tcp_rfc1337"                       = 1;
    "net.ipv4.conf.all.accept_source_route"      = 0;
    "net.ipv6.conf.all.accept_source_route"      = 0;
    "net.ipv6.conf.all.accept_ra"                = 0;
    "net.ipv6.conf.default.accept_ra"            = 0;

    "fs.suid_dumpable"       = 0;
    "fs.protected_symlinks"  = 1;
    "fs.protected_hardlinks" = 1;
    "fs.protected_fifos"     = 2;
    "fs.protected_regular"   = 2;
  };

  # ── Kernel module blacklist ───────────────────────────────────────────────────
  boot.blacklistedKernelModules = [
    "ax25" "netrom" "rose"                              # amateur radio
    "adfs" "freevxfs" "hfs" "hfsplus" "hpfs" "jfs"
    "minix" "nilfs2"                                    # obsolete filesystems
    "rds" "af_802154"                                   # obscure protocols
  ];

  # ── Core dumps ───────────────────────────────────────────────────────────────
  security.pam.loginLimits = [
    { domain = "*"; type = "hard"; item = "core"; value = "0"; }
  ];

  # ── DNS over TLS ─────────────────────────────────────────────────────────────
  # Note: disable services.tor.client.dns.enable in services.nix if using this
   services.resolved = {
   enable = true;
   settings.Resolve = {
    DNS = "1.1.1.2 1.0.0.2";        # Cloudflare malware blocking
    FallbackDNS = "9.9.9.9";        # Quad9 also blocks malware/phishing
   # DNSSEC = "allow-downgrade";
     DNSSEC = "false";  #DNSSEC false lets ProtonVPN's DNS work when connected, keeping DoT for normal browsing. 
     DNSOverTLS = "opportunistic";
   };
 };


#  services.usbguard = {
#  enable = true;
#  rules = ''
#    allow id 1d6b:0002 serial "0000:00:14.0" name "xHCI Host Controller" hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" parent-hash "rV9bfLq7c2eA4tYjVjwO4bxhm+y6GgZpl9J60L0fBkY=" with-interface 09:00:00 with-connect-type ""
#    allow id 1d6b:0003 serial "0000:00:14.0" name "xHCI Host Controller" hash "prM+Jby/bFHCn2lNjQdAMbgc6tse3xVx+hZwjOPHSdQ=" parent-hash "rV9bfLq7c2eA4tYjVjwO4bxhm+y6GgZpl9J60L0fBkY=" with-interface 09:00:00 with-connect-type ""
#    allow id 058f:9540 serial "" name "EMV Smartcard Reader" hash "j6z/wqFtA1bZWwBIPmIr/g8KfsEQJ63vpgf4cBcNLbU=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" via-port "1-1" with-interface 0b:00:00 with-connect-type "not used"
#    allow id 13d3:56ff serial "" name "Integrated Camera" hash "a0FdFfjaZ15WXb4kCZLrU4YG4JsqWbVGG2hqB3/scwI=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" via-port "1-7" with-interface { 0e:01:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 } with-connect-type "not used"
#    allow id 8087:0029 serial "" name "" hash "ATK8pCmQtUYaUnwqUVuYssrOMkW8pdCSdZO4OC6zEtg=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" via-port "1-10" with-interface { e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 } with-connect-type "not used"
#    reject id *:*
#   '';
#  };

}
