{ config, pkgs, lib, inputs, ... }:

let
  # 从我们在 NUR 中托管的专属包中，拉取 Lingmo 桌面套件
  nurPkgs = inputs.my-nur.packages.${pkgs.system};
in
{
  # === Lingmo OS 桌面环境 ===
  # 极致硬核：从我们的 NUR 源动态拉取编译的桌面环境！

  # 1. 启用显示服务
  services.xserver.enable = true;
  
  # 2. 标配 SDDM 显示管理器
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "lingmo";
    extraPackages = [ nurPkgs.lingmoui ];
  };

  # 3. 注入 Lingmo 专属全局环境变量
  environment.variables = {
    QT_QPA_PLATFORMTHEME = "lingmo"; 
    XDG_CURRENT_DESKTOP = "lingmo";
  };

  # 4. 注册所有组件到系统
  environment.systemPackages = with pkgs; [
    # ---- 我们的自编译成果 (来自 my-nur) ----
    nurPkgs.lingmoui
    nurPkgs.lingmo-core
    nurPkgs.lingmo-settings
    nurPkgs.lingmo-desktop
    nurPkgs.lingmo-dock
    nurPkgs.lingmo-launcher
    nurPkgs.lingmo-filemanager
    nurPkgs.lingmo-screenlocker
    nurPkgs.lingmo-sddm-theme
    nurPkgs.lingmo-daemon
    nurPkgs.lingmo-statusbar
    
    # KWin 插件 (因为作为插件可能需要被 KDE 感知，放在这没问题)
    nurPkgs.lingmo-kwin-plugins

    # 权限提权弹窗 (替代无法编译的 lingmo-polkit-agent)
    kdePackages.polkit-kde-agent-1
    
    # Python3 required by lingmo-wallpaper-color-pick script
    python3
    
    # ---- Lingmo 的生态底座 (KDE/Qt) ----
    kdePackages.kwin
    kdePackages.qtwayland
    kdePackages.qtsvg
    kdePackages.plasma-wayland-protocols
    kdePackages.layer-shell-qt
  ];

  # 5. 会话注册：让 SDDM 能识别并启动 Lingmo
  services.displayManager.sessionPackages = [ nurPkgs.lingmo-core ];

  # 6. 基础系统服务补充
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  programs.dconf.enable = true;
}
