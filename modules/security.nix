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
    DNSSEC = "true";
    Domains = [ "~." ];
    FallbackDNS = [ "1.1.1.1#cloudflare-dns.com" "9.9.9.9#dns.quad9.net" ];
    DNSOverTLS = "yes";
   };
 };
}
