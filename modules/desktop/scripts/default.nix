{ pkgs, ... }:
{
  # 截图脚本
  home.file.".local/bin/myshot".source = pkgs.writeShellScript "myshot" ''
    GEOMETRY=$(slurp) || exit 1
    grim -g "$GEOMETRY" - | swappy -f -
  '';

  # Swappy 配置文件
  xdg.configFile."swappy/config".text = ''
    [Default]
    save_dir=$HOME/Pictures/Screenshots
    save_filename_format=Screenshot_%Y-%m-%d_%H-%M-%S.png
    show_panel=true
    line_size=5
    text_size=20
    text_font=sans-serif
    paint_mode=brush
    early_exit=false
    fill_shape=false
  '';
}