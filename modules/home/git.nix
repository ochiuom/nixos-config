{ config, pkgs, lib, ... }:
{
  programs.git = {
    enable   = true;
    settings = {
      merge.conflictstyle = "diff3";
      diff.colorMoved     = "default";
    };
  };

  programs.delta = {
    enable               = true;
    enableGitIntegration = true;
    options = {
      navigate     = true;
      dark         = true;
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "TwoDark";
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        theme = {
          activeBorderColor   = [ "cyan" "bold" ];
          inactiveBorderColor = [ "white" ];
          selectedLineBgColor = [ "default" ];
        };
        showIcons        = true;
        nerdFontsVersion = "3";
      };
      git.pagers = [{
        diff      = "delta --dark --paging=never";
        staging   = "delta --dark --paging=never";
        mergeDiff = "delta --dark --paging=never";
      }];
    };
  };
}
