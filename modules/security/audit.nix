{
  config,
  lib,
  pkgs,
  ...
}:
{
  ##########################################################################
  # 📋 Security Auditing & Logging
  ##########################################################################
  security.auditd.enable = true;
  security.audit = {
    enable = true;
    backlogLimit = 8192;
    rules = [
      # Monitor critical file changes
      "-w /etc/passwd -p wa -k passwd_changes"
      "-w /etc/shadow -p wa -k shadow_changes"
      "-w /etc/sudoers -p wa -k sudoers_changes"
      # Monitor login attempts
      "-w /var/log/lastlog -p wa -k logins"
      "-w /var/run/faillock -p wa -k logins"
      "-w /var/log/audit/ -p wx -k audit_tampering"
      # Monitor unauthorized access attempts
      "-a always,exit -F arch=b64 -S openat -F dir=/etc -F success=0 -k unauthed_access"
      # Monitor kernel module loading/unloading
      "-a always,exit -F arch=b64 -S init_module -S delete_module -k modules"
    ];
  };

  ##########################################################################
  # 📰 Journald
  ##########################################################################
  services.journald.extraConfig = ''
    Storage=persistent
    Compress=yes
    RateLimitInterval=30s
    RateLimitBurst=1000
    SystemMaxUse=1G
    MaxRetentionSec=1month
  '';
}
