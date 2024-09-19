{ pkgs }:

rec {
  sndctl = pkgs.writeShellScriptBin "sndctl" ''
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

  shutdown = pkgs.writeShellScript "shutdown" ''
    systemctl poweroff
  '';

  reboot = pkgs.writeShellScript "reboot" ''
    systemctl reboot
  '';

  suspend = pkgs.writeShellScript "suspend" ''
    systemctl suspend
  '';

  hibernate = pkgs.writeShellScript "hibernate" ''
    systemctl hibernate
  '';

  wofipower = pkgs.writeShellApplication {
    name = "wofipower";
    runtimeInputs = [
      pkgs.wofi
    ];

    text = ''
      case "$(printf "%s\n" "lock" "hybrid-sleep" "suspend" "hibernate" "restart" "shutdown" | wofi -d -i -p 'System action:')" in
        "shutdown")
          doas -n "${shutdown}"; ;;

        "restart")
          doas -n "${reboot}"; ;;

        "suspend")
          doas -n "${suspend}"; ;;

        "hibernate")
          doas -n "${hibernate}"; ;;

        "lock")
          swaylock; ;;
    
      esac
    '';
  };
}
