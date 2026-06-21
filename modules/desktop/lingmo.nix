{ config, pkgs, inputs, ... }:

{
  # === Lingmo OS 桌面环境 ===
  # 根据 Arch Linux AUR 和官方构建逻辑复刻的 NixOS 原生配置

  # 1. 启用显示服务
  services.xserver.enable = true;
  
  # 2. Lingmo 官方标配 SDDM 作为显示管理器
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # 3. 注入 Lingmo 专属全局环境变量
  environment.variables = {
    QT_QPA_PLATFORMTHEME = "lingmo"; 
    XDG_CURRENT_DESKTOP = "lingmo";
  };

  # 4. 系统核心依赖与包
  environment.systemPackages = with pkgs; [
    # 核心组件库 (从您引入的 lingmo-nix flake 中获取)
    # inputs.lingmo-nix.packages.${pkgs.system}.lingmo-core
    # inputs.lingmo-nix.packages.${pkgs.system}.lingmoui
    # inputs.lingmo-nix.packages.${pkgs.system}.lingmo-settings
    # inputs.lingmo-nix.packages.${pkgs.system}.lingmo-terminal
    
    # 🚨 关键依赖：Lingmo 是基于 KWin 的，必须安装 KDE 窗口管理器及其 Wayland 支持
    kdePackages.kwin
    kdePackages.qtwayland
    kdePackages.qtsvg
  ];

  # 5. 基础文件管理器服务
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  programs.dconf.enable = true;
}
