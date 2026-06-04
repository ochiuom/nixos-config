{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ./modules/home/desktop-quote
    ./modules/home/dconf.nix
    ./modules/home/themes.nix
    ./modules/home/shell.nix
    ./modules/home/media.nix
    ./modules/home/terminal.nix
    ./modules/home/git.nix
    ./modules/home/files.nix
  ];

  home.username      = "ochinix";
  home.homeDirectory = "/home/ochinix";
  home.stateVersion  = "26.05";

  home.packages = with pkgs; [
    # Shell utilities
    fd ripgrep eza dust duf bandwhich gping aria2 rsync p7zip
    fastfetch blesh  btop navi broot lazygit delta
    
    # Media / Desktop
    easyeffects weylus xournalpp yt-dlp warp-terminal 
    tigervnc remmina zed-editor carapace
  ];

  programs.home-manager.enable = true;
  programs.neovim = {
    enable        = true;
    defaultEditor = true;
    viAlias       = true;
    vimAlias      = true;
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
  ];
  
 

}
