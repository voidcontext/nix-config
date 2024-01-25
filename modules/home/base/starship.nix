{...}: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    # Configuration written to ~/.config/starship.toml
    settings = {
      add_newline = false;

      aws = {
        symbol = "  ";
      };

      character = {
        # success_symbol = "[λ](bold green)";
        error_symbol = "[✗](bold red)";
      };

      #     conda = {
      #       symbol = " ";
      #     };

      #     dart = {
      #       symbol = " ";
      #     };

      directory = {
        style = "bright-yellow";
        # read_only = " ";
      };

      docker_context = {
        disabled = false;
        symbol = " ";
      };

      #     elixir = {
      #       symbol = " ";
      #     };

      #     elm = {
      #       symbol = " ";
      #     };

      git_branch = {
        symbol = " ";
        style = "bold blue";
      };

      git_metrics = {
        disabled = false;
        added_style = "italic green";
        deleted_style = "italic red";
      };

      git_status = {
        style = "purple";
      };

      #     golang = {
      #       symbol = " ";
      #     };

      #     hg_branch = {
      #       symbol = " ";
      #     };

      kubernetes = {
        disabled = true;
      };

      #     java = {
      #       symbol = " ";
      #     };

      #     julia = {
      #       symbol = " ";
      #     };

      #     memory_usage = {
      #       symbol = " ";
      #     };

      #     nim = {
      #       symbol = " ";
      #     };

      nix_shell = {
        # symbol = " ";
        format = "via [$symbol(\($name\))]($style) ";
      };

      #     package = {
      #       symbol = " ";
      #     };

      #     perl = {
      #       symbol = " ";
      #     };

      #     php = {
      #       symbol = " ";
      #     };

      #     python = {
      #       symbol = " ";
      #     };

      #     ruby = {
      #       symbol = " ";
      #     };

      #     rust = {
      #       symbol = " ";
      #     };

      scala = {
        symbol = " ";
      };

      #     shlvl = {
      #       symbol = " ";
      #     };

      #     swift = {
      #       symbol = "ﯣ ";
      #     };
    };
  };
}
