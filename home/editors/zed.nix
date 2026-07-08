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

      buffer_font_family = "Cica";
      buffer_font_size = 14;
      buffer_line_height = "comfortable";
      ui_font_family = "Cica";
      ui_font_size = 16;

      autosave = "off";
      format_on_save = "off";
      ensure_final_newline_on_save = true;
      remove_trailing_whitespace_on_save = true;

      show_wrap_guides = false;
      sticky_scroll.enabled = true;

      tab_bar = {
        show_nav_history_buttons = false;
        show_tab_bar_buttons = false;
      };
      tabs = {
        file_icons = true;
        git_status = true;
      };
      title_bar = {
        show_branch_status_icon = true;
        show_sign_in = false;
        show_user_picture = false;
      };
      toolbar.agent_review = false;

      collaboration_panel = {
        button = false;
        dock = "left";
      };
      debugger.button = false;
      diagnostics.button = false;
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

      git.inline_blame.enabled = false;

      terminal = {
        button = true;
        font_family = "Cica";
        font_size = 14;
        shell = "system";
        dock = "right";
        working_directory = "current_project_directory";
      };

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
    };
  };
}
