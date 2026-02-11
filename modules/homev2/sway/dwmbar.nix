{ dwmbar, colors }:

{
  bar = {
    position = "top";
    workspaceButtons = true;
    workspaceNumbers = true;
    fonts = { names = [ "Hack" ]; size = 14.0; };
    statusCommand = "${dwmbar}/bin/dwmbar";
    colors = {
      background = colors.black;
      statusline = colors.blue;
      focusedWorkspace = {
        border = colors.dark0;
        background = colors.blue;
        text = colors.dark0;
      };
      inactiveWorkspace = {
        border = colors.dark0;
        background = colors.dark0;
        text = colors.blue;
      };
    };
  };

  dwmbarConfig = {
    clock = {
      interval = "1s";
      settings = { layout = "Monday, Jan 02 > 15:04"; };
    };
    volume = {
      interval = "200ms";
      settings = { backend = "pipewire"; };
    };
    fans = {
      interval = "1s";
      settings = { cache = true; limit = 2; };
    };
    temperatures = {
      interval = "5s";
      settings = { cache = true; merge = true; };
    };
    battery = {
      interval = "5s";
      settings = { cache = true; };
    };
    brightness = {
      interval = "500ms";
      settings = { cache = true; };
    };
    wifi = {
      interval = "30s"; # Heartbeat fallback interval (event-driven)
      settings = { backend = "iwd"; };
    };
  };
}
