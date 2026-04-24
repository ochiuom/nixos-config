{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    # LaTeX
    (pkgs.texlive.combine {
      inherit (pkgs.texlive)
      scheme-small
      latex-bin
      latexmk
      collection-luatex

      # ADD THESE
      collection-fontsrecommended
      collection-latexextra
      collection-bibtexextra

      revtex4-1
      moderncv arydshln lm mathdesign
      mdframed zref needspace tikzfill pdfcol abstract

      libertinus libertinus-type1  newtx dblfloatfix

      # Fonts & Symbols
      charter noto fontspec amsmath amsfonts amscls
      cm-super
      physics mathtools cancel braket siunitx

      # Graphics
      pgf tikz-cd circuitikz quantikz
      adjustbox subfig dvipng

      # Layout
      booktabs float multirow colortbl
      geometry microtype parskip setspace ragged2e enumitem etoolbox csquotes
      titlesec changepage caption xcolor tcolorbox

      # Bibliography
      hyperref biblatex biber fancyhdr lastpage orcidlink
      babel babel-english

      #beamer-package
      dingbat bbm bbm-macros;
    })    
  ];
}
