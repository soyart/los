{ pkgs }:

{
  # Wrapper to make wofi act as dmenu
  # Allows programs to call "dmenu" directly without going through a shell
  dmenu = pkgs.writeShellScriptBin "dmenu" ''
    exec ${pkgs.wofi}/bin/wofi --dmenu "$@"
  '';

  sndctl = pkgs.writeShellApplication {
    name = "sndctl";
    runtimeInputs = [
      pkgs.gawk
      pkgs.wireplumber
    ];

    text = ''
      case "$1" in
      	vol)
      		wpctl get-volume @DEFAULT_SINK@ | awk '{print $2,$3}'; ;;

      	mute)
      		wpctl set-mute @DEFAULT_SINK@ toggle; ;;

      	micmute)
      		wpctl set-mute @DEFAULT_SOURCE@ toggle; ;;

      	up)
      		wpctl set-volume @DEFAULT_SINK@ 10%+; ;;
      	
      	dn)
      		wpctl set-volume @DEFAULT_SINK@ 10%-; ;;
      esac;
    '';
  };

  wofipower = pkgs.writeShellApplication {
    name = "wofipower";
    runtimeInputs = [
      pkgs.wofi
    ];

    text = ''
      case "$(printf "%s\n" "lock" "hybrid-sleep" "suspend" "hibernate" "restart" "shutdown" | wofi -d -i -p 'System action:')" in
        "shutdown")
          systemctl poweroff; ;;

        "restart")
          systemctl reboot; ;;

        "suspend")
          systemctl suspend; ;;

        "hibernate")
          systemctl hibernate; ;;

        "lock")
          swaylock; ;;
    
      esac
    '';
  };
}

