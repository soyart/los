{ doas ? true, sudo ? false }:

{
  doas.enable = doas;
  sudo.enable = sudo;
}
