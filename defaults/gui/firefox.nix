username:

{ ... }:

{
  imports = [
    (import ../../home/gui/progs/firefox username)
  ];

  los.home."${username}".gui.progs.firefox = {
    enable = true;
    withPipewire = true;
  };
}
