{ pkgs, ... }:

{
  # 1. 安装字体和 Nord 主题包
  home.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    source-han-sans
    fcitx5-nord  # <--- 新的救星：Nord 深色主题
  ];

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons
      fcitx5-gtk
      fcitx5-rime
      # fcitx5-material-color # <--- 删掉这个可能坏掉的包
    ];
  };

  # 2. 强制指定 Nord-Dark 主题
  xdg.configFile."fcitx5/conf/classicui.conf".text = ''
    Vertical Candidate List=False
    PerScreenDPI=True
    Font="Sans 16"
    Theme=Nord-Dark
  '';
  
  # 3. 环境变量保险
  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };
}