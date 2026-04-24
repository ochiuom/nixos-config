{ config, pkgs, lib, ... }:
{
  imports = [
    ./packages/cli.nix
    ./packages/gui.nix
    ./packages/latex.nix
    ./packages/gnome-extensions.nix
  ];

  fonts.packages = with pkgs; [
    libertinus
    font-bitstream-type1
  ];

  programs.nh = {
    enable = true;
    flake = "/etc/nixos";
  };
}
