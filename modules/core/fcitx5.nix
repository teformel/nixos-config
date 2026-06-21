{ config, pkgs, ... }:

{
  # 系统语言与中文输入法支持 (Fcitx5)
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      # 🚀 核心魔法：重载 fcitx5-rime，把基础数据和雾凇词库同时注入进去
      (fcitx5-rime.override { rimeDataPkgs = [ rime-data rime-ice ]; })
      # 🚨 把这个恢复开启！它不仅增强输入体验，还负责很多托盘图标的渲染
      fcitx5-gtk 
          
      # (可选) 强烈建议顺手装个官方配置工具，方便以后改快捷键
      qt6Packages.fcitx5-configtool
      # 🚀 [新增] Fcitx5 专属的 Material 风格主题，自带所有 UI 图标
      fcitx5-material-color
    ];
    fcitx5.waylandFrontend = true;
  };

  # 强制全局注入 Fcitx5 环境变量，专治 i3wm 各种不服
  environment.sessionVariables = {
    GLFW_IM_MODULE = "ibus"; # 顺手解决一些游戏/图形库的输入问题
    #GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";

    NIXOS_OZONE_WL = "1";
    # 🚀 [新增] 强制全局写入 Qt 主题变量，专治 Wayland 下的环境变量丢失
    # QT_QPA_PLATFORMTHEME = "qt5ct";
    # 强制 Wayland/图形界面继承中文环境
    LANG = "zh_CN.UTF-8";
    LC_ALL = "zh_CN.UTF-8";
  };
}
