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
      buffer_line_height = "comfortable";
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

      show_wrap_guides = false;

      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      disable_ai = true;
      show_edit_predictions = false;
      agent = {
        enabled = false;
        button = false;
        dock = "right";
      };

      collaboration_panel = {
        button = false;
        dock = "left";
      };
      diagnostics.button = false;
      debugger.button = false;

      terminal = {
        button = true;
        font_family = "Cica";
        font_size = 14;
        shell = "system";
        dock = "bottom";
        working_directory = "current_project_directory";
      };

      project_panel = {
        button = true;
        dock = "left";
        git_status = true;
      };
      outline_panel = {
        button = true;
        dock = "left";
      };
      git_panel = {
        button = true;
        dock = "left";
        status_style = "icon";
      };
    };
  };
}
