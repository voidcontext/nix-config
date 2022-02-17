{pkgs, hdpi, ...}:

{
  home.file.".emacs.d/init.el".text = ''
    (scroll-bar-mode -1)
    
    (set-face-attribute 'default nil
      :font "Fira Mono" :height ${ if hdpi then "120" else "100" } :weight 'regular :width 'regular)
  '';

  programs.emacs.packags = pkgs.emacsUnstable;
}
