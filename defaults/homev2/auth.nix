{ doas ? false, sudo ? false }:

{
  doas.enable = doas;
  sudo.enable = sudo;
}
