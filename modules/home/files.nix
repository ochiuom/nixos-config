{ config, pkgs, lib, ... }:
{
  home.file.".config/kitty" = {
    source    = ./../../kitty; # Adjusted path
    recursive = true;
  };

  home.file.".config/starship.toml".source = ./../../starship/starship.toml;

  home.file.".config/easyeffects/output" = {
    source    = ./../../easyeffects/output;
    recursive = true;
  };

  home.file.".config/easyeffects/irs" = {
    source    = ./../../easyeffects/irs;
    recursive = true;
  };

  home.file.".config/mpd/mpd.conf".source = ./../../mpd/mpd.conf;
  home.file.".config/organize/config.yaml".source = ./../../organize/config.yaml;

  home.file.".local/share/fonts" = {
    source    = ./../../fonts;
    recursive = true;
  };

  # Activation scripts
  home.activation.createVaultDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ~/Documents/.vault
    mkdir -p ~/Documents/Vault
    mkdir -p ~/Backups
    mkdir -p ~/Videos/.Fragments-vault
    mkdir -p ~/Videos/Fragments
  '';   

  home.activation.copyNvchadCustom = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ -d ~/.local/share/nvim/lazy/NvChad ]; then
      mkdir -p ~/.config/nvim/lua/plugins
      mkdir -p ~/.config/nvim/lua/configs
      cp -rf ${./../../nvchad-lua/plugins}/. ~/.config/nvim/lua/plugins/
      cp -f ${./../../nvchad-lua/autocmds.lua}             ~/.config/nvim/lua/autocmds.lua
      cp -f ${./../../nvchad-lua/configs/lspconfig.lua}    ~/.config/nvim/lua/configs/lspconfig.lua
    fi
  '';

  home.activation.refreshFontCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${pkgs.fontconfig}/bin/fc-cache -f
  '';

     
  home.activation.createSageProject = lib.hm.dag.entryAfter ["writeBoundary"] ''
  mkdir -p ~/Projects/Sage
  cp -n ${./../../Sage/flake.nix} ~/Projects/Sage/flake.nix
  cp -n ${./../../Sage/.envrc} ~/Projects/Sage/.envrc

  mkdir -p ~/.local/share/jupyter/kernels/sagemath
  cp -f ${./../../vscode/kernel.json} ~/.local/share/jupyter/kernels/sagemath/kernel.json

  mkdir -p ~/.vscode
  cp -f ${./../../vscode/settings.json} ~/.vscode/settings.json
  '';  

  home.file.".sage/init.sage".text = ''
  import matplotlib as mpl
  import matplotlib.pyplot as plt
  import numpy as np

  mpl.rcParams.update({
      # Typography
      'font.family':       'serif',
      'font.size':         11,
      'axes.labelsize':    12,
      'axes.titlesize':    12,
      'legend.fontsize':   10,
      'xtick.labelsize':   10,
      'ytick.labelsize':   10,

      # LaTeX rendering (requires texlive in home.packages)
      'text.usetex':       True,
      'text.latex.preamble': r'\usepackage{amsmath}\usepackage{amssymb}',

      # Figure
      'figure.dpi':        300,
      'figure.figsize':    (6.5, 4.5),
      'figure.autolayout': True,

      # Lines & axes
      'lines.linewidth':   1.5,
      'axes.linewidth':    0.8,
      'axes.labelpad':     4.0,

      # Ticks
      'xtick.direction':   'in',
      'ytick.direction':   'in',
      'xtick.top':         True,
      'ytick.right':       True,
      'xtick.major.size':  4,
      'ytick.major.size':  4,
      'xtick.minor.size':  2,
      'ytick.minor.size':  2,
      'xtick.minor.visible': True,
      'ytick.minor.visible': True,

      # Grid (off by default, enable per-plot)
      'axes.grid':         False,

      # Legend
      'legend.frameon':    True,
      'legend.framealpha': 0.8,
      'legend.edgecolor':  '0.8',

      # Save
      'savefig.dpi':       300,
      'savefig.bbox':      'tight',
      'savefig.pad_inches': 0.05,
      'savefig.format':    'pdf',

      # Color cycle: Wong color-blind safe palette
      'axes.prop_cycle': mpl.cycler(color=[
          '#0072B2', '#E69F00', '#009E73',
          '#CC79A7', '#56B4E9', '#D55E00', '#F0E442',
      ]),
  })
 '';
   
  home.file.".config/matplotlib/matplotlibrc".text = ''
  font.family      : serif
  font.size        : 11
  axes.labelsize   : 12
  axes.titlesize   : 12
  legend.fontsize  : 10
  xtick.labelsize  : 10
  ytick.labelsize  : 10

  text.usetex      : True
  text.latex.preamble : \usepackage{amsmath}\usepackage{amssymb}

  figure.dpi       : 300
  figure.figsize   : 6.5, 4.5
  figure.autolayout: True

  lines.linewidth  : 1.5
  axes.linewidth   : 0.8
  axes.labelpad    : 4.0

  xtick.direction  : in
  ytick.direction  : in
  xtick.top        : True
  ytick.right      : True
  xtick.major.size : 4
  ytick.major.size : 4
  xtick.minor.size : 2
  ytick.minor.size : 2
  xtick.minor.visible : True
  ytick.minor.visible : True

  axes.grid        : False
  legend.frameon   : True
  legend.framealpha: 0.8
  legend.edgecolor : 0.8

  savefig.dpi      : 300
  savefig.bbox     : tight
  savefig.pad_inches: 0.05
  savefig.format   : pdf
  ''; 

}
