{ config, pkgs, ... }:

{
  # ─── PipeWire (required for all 3 tools) ───────────────────
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

}
