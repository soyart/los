username:

{ ... }:

{
  home-manager.users."${username}" = {
    programs.bash = {
      enable = true;
      enableCompletion = true;

      historyControl = [ "ignoreboth" ];
      historyFile = null;
      historySize = 256;

      shellAliases = {
        "c" = "clear";
        "g" = "git";
        "ga" = "git add";
        "gc" = "git commit";
        "gs" = "git status";
        "h" = "hx";
      };

      initExtra = ''
        prompt_git() {
          s="";
          branchName="";

          # local s=;
          # local branchName=;

          # Check if the current directory is in a Git repository.
          if [[ $(git rev-parse --is-inside-work-tree &>/dev/null; echo "$?") == '0' ]]; then
              # check if the current directory is in .git before running git checks
              if [[ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == 'false' ]]; then
                # Ensure the index is up to date.
                git update-index --really-refresh -q &>/dev/null;

                # Check for uncommitted changes in the index.
                if ! $(git diff --quiet --ignore-submodules --cached); then
                  s+='+';
                fi;

                # Check for unstaged changes.
                if ! $(git diff-files --quiet --ignore-submodules --); then
                  s+='!';
                fi;

                # Check for untracked files.
                if [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
                  s+='?';
                fi;

                # Check for stashed files.
                if $(git rev-parse --verify refs/stash &>/dev/null); then
                  s+='$';
                fi;
              fi;

              # Get the short symbolic ref.
              # If HEAD isn’t a symbolic ref, get the short SHA for the latest commit
              # Otherwise, just give up.
              branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
              git rev-parse --short HEAD 2> /dev/null || \
              echo '(unknown)')";
              [ -n "$s" ] && s=" [$s]";
              echo -e "$1$branchName$2$s";

            else
              # Nothing to do here if not inside work tree
            return;
          fi;
        }

        if tput setaf 1 &> /dev/null; then
          tput sgr0; # reset colors
          bold=$(tput bold);
          reset=$(tput sgr0);

          # Solarized colors, taken from http://git.io/solarized-colors.
          black=$(tput setaf 0);
          blue=$(tput setaf 33);
          cyan=$(tput setaf 37);
          green=$(tput setaf 64);
          orange=$(tput setaf 166);
          purple=$(tput setaf 125);
          red=$(tput setaf 124);
          violet=$(tput setaf 61);
          white=$(tput setaf 15);
          yellow=$(tput setaf 136);

        else

          bold="";
          reset="\e[0m";
          black="\e[1;30m";
          blue="\e[1;34m";
          cyan="\e[1;36m";
          green="\e[1;32m";
          orange="\e[1;33m";
          purple="\e[1;35m";
          red="\e[1;31m";
          violet="\e[1;35m";
          white="\e[1;37m";
          yellow="\e[1;33m";
        fi;

        # Default user/host colors
        userStyle="$white";
        hostStyle="$cyan";

        # Highlight the user name when logged in as root.
        [[ "$USER" == "root" ]] && userStyle="$red";

        # Highlight the hostname when connected via SSH.
        [[ -n "$SSH_CLIENT" ]] && hostStyle="$yellow";

        # Set the terminal title and prompt.
        PS1="\[\033]0;\W\007\]"; # working directory base name
        PS1+="\[$bold\]\n"; # newline
        PS1+="\[$userStyle\u"; # username
        PS1+="\[$hostStyle\]@";
        PS1+="\[$hostStyle\]\h"; # host
        PS1+="\[$hostStyle\]:";
        PS1+="\[$hostStyle\]\w"; # working directory
        PS1+="\$(prompt_git \"\[$white\] on \[$violet\]\" \"\[$blue\]\")"; # Git repository details
        PS1+="\[$reset\]\n"; # newline
        PS1+="\[$white\]$ \[$reset\]"; # `$` (and reset color)
        export PS1;

        PS2="\[$yellow\]→ \[$reset\]";
        export PS2;
      '';
    };
  };
}
