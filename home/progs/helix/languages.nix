pkgs:

let
  nixd = "${pkgs.nixd}/bin/nixd";
  nixfmt = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";

in
{
  language =
    let
      stdFormat = {
        auto-format = true;
        indent = {
          tab-width = 4;
          unit = "\t";
        };
      };
    in
    [
      ({ name = "c"; } // stdFormat)
      ({ name = "rust"; } // stdFormat)
      ({ name = "python"; } // stdFormat)
      ({ name = "toml"; } // stdFormat)
      ({ name = "yaml"; } // stdFormat)
      ({ name = "json"; } // stdFormat)
      ({ name = "markdown"; } // stdFormat)

      ({
        name = "nix";
        language-servers = [
          {
            name = "nixd";
          }
        ];
        formatter.command = nixfmt;
        roots = [
          "flake.nix"
        ];
      } // stdFormat)

      ({
        name = "go";
        language-servers = [
          {
            name = "efm";
            only-features = [ "diagnostics" ];
          }
          { name = "gopls"; }
        ];

      } // stdFormat)
    ];

  language-server = {
    nixd = {
      command = nixd;
    };

    efm = {
      command = "efm-langserver";
      args = [
        "-loglevel"
        "10"
        "-logfile"
        "/tmp/helix.efm.log"
      ];
    };

    gopls = {
      command = "gopls";
      buildTags = [
        "-tags=integration_test,dynamic,wireinject"
        "-v"
      ];
      gofumpt = true;
      staticcheck = true;
      verboseOutput = true;
      completeUnimported = true;

      config = {
        analyses = {
          fieldalignment = true;
          nilness = true;
          unusedparams = true;
          unusedwrite = true;
        };

        hints = {
          constantValues = true;
          parameterNames = true;
          assignVariableType = true;
          rangeVariableTypes = true;
          compositeLiteralTypes = true;
          compositeLiteralFields = true;
          functionTypeParameters = true;
        };
      };
    };
  };
}
