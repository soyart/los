{
  # Show dotfiles
  file-picker.hidden = false;

  line-number = "relative";
  bufferline = "always";
  true-color = true;

  cursor-shape = {
    insert = "bar";
  };

  whitespace = {
    render = {
      tab = "none";
    };
    characters = {
      tab = "→";
      tabpad = "·";
    };
  };
  indent-guides = {
    render = true;
    character = "╎";
  };

  lsp = {
    display-messages = true;
  };
}

