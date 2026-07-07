{
  programs.zed-editor = {
    enable = true;
    package = null;

    extensions = [
      "nix"
      "markdown-oxide"
      "dockerfile"
      "github-actions"
    ];

    userSettings = {
      base_keymap = "VSCode";
      vim_mode = false;

      buffer_font_family = "Cica";
      buffer_font_size = 14;
      ui_font_family = "Cica";
      ui_font_size = 16;

      theme = {
        mode = "system";
        dark = "One Dark";
        light = "One Light";
      };

      icon_theme = {
        mode = "system";
        dark = "Zed (Default)";
        light = "Zed (Default)";
      };

      autosave = "off";
      format_on_save = "off";
      ensure_final_newline_on_save = true;
      remove_trailing_whitespace_on_save = true;

      show_wrap_guides = true;
      wrap_guides = [
        80
        100
      ];

      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      disable_ai = true;
      show_edit_predictions = false;
      features.edit_predictions.provider = "none";

      terminal = {
        font_family = "Cica";
        font_size = 14;
        shell = "system";
        dock = "bottom";
        working_directory = "current_project_directory";
      };

      project_panel.git_status = true;
      git_panel.status_style = "icon";
    };
  };
}
