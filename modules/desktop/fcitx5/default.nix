{ pkgs, ... }:

{
  # === 1. 软件安装 (Home Manager 语法) ===
  i18n.inputMethod = {
    enabled = "fcitx5";  # 注意：这里是 enabled，不是 system 级的 enable/type
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons
      fcitx5-gtk
      fcitx5-rime
      # 还可以加上漂亮的皮肤包
      fcitx5-material-color
    ];
  };

  # === 2. 配置文件 (UI 美化) ===
  # 使用 xdg.configFile 比 home.file 更优雅
  xdg.configFile."fcitx5/conf/classicui.conf".text = ''
    # 垂直列表 (选词更符合直觉)
    Vertical Candidate List=False
    
    # 按屏幕 DPI 缩放
    PerScreenDPI=True
    
    # ✨ 核心修复：强制设置大字体 (JetBrains Mono 16)
    Font="JetBrains Mono 16"
    
    # ✨ 主题设置：使用上面安装的 material-color 主题
    # 你可以选：Material-Color-Pink, Material-Color-Blue 等
    Theme=Material-Color-Pink
  '';
  
  # === 3. 环境变量设置 (Wayland 必需) ===
  # 虽然 Home Manager 会自动配一些，但为了保险起见，显式声明一下更好
  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };
}