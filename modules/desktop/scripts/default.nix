{ pkgs, ... }:

{
  # === 1. 安装核心软件 ===
  home.packages = with pkgs; [
    # === 📸 截屏工具 (脚本依赖) ===
    grim    # 截图工具 (CLI) 核心：负责把屏幕画面抓下来
    slurp   # 选区工具 (CLI) 核心：负责让你用鼠标画一个框
    swappy  # 截图编辑工具 (GUI) 核心：负责弹出一个编辑窗口，让你画箭头、保存
    wl-clipboard # 剪贴板工具 (Swappy 复制图片需要它)

    # === 2. 封装截图脚本 ===
    # writeShellScriptBin 会自动生成一个叫 "myshot" 的可执行文件
    # 并把它放到你的 PATH 路径里
    (writeShellScriptBin "myshot" ''
      # 这里的逻辑不用变
      GEOMETRY=$(slurp) || exit 1
      grim -g "$GEOMETRY" - | swappy -f -
    '')
  ];

  # === 3. 注入 Swappy 配置 ===
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