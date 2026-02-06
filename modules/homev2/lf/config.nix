{ lib, config, ... }:

{
  config.home-manager.users = lib.mapAttrs
    (username: userCfg:
      lib.mkIf userCfg.lf.enable {
        programs.lf = {
          enable = true;

          settings = {
            shell = "bash";
            shellopts = "-eu";
            ifs = "\\n";

            info = "size";
            dircounts = true;
            smartcase = true;

            ratios = [ 1 2 3 ];
          };

          extraConfig = ''
            $mkdir -p ~/.trash
          '';

          commands = {
            open = ''
              ''${{
                  case $(file --mime-type $f -b) in
                      text/*) $EDITOR $fx;;
                      *) for f in $fx; do setsid $OPENER $f > /dev/null 2> /dev/null & done;;
                  esac
              }}
            '';

            trash = ''
              %set -f; mv $fx ~/.trash
            '';
          };

          keybindings = {
            "<enter>" = "shell";
            "." = "set hidden!";
            "o" = "$mimeopen $f";
            "O" = "$mimeopen --ask $f";
            "i" = "$less $f";
            "U" = "!du -sh";
            "x" = "$$f";
            "X" = "!$f";
            "p" = "paste";
            "yy" = "copy";
            "dd" = "trash";
            "DD" = "delete";
            "ad" = "push $mkdir<space>";
            "af" = "push $touch<space>";
            "sn" = ":{{ set sortby natural; set info size; }}";
          };
        };
      }
    )
    config.los.homev2;
}

