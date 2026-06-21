{ config, pkgs, lib, ... }:

let
  # 挂载我们自己从源码编译打包的 Lingmo 专属 Derivations！
  lingmoui = pkgs.callPackage ./lingmo-pkgs/lingmoui.nix {};
  lingmo-core = pkgs.callPackage ./lingmo-pkgs/lingmo-core.nix { inherit lingmoui; };
  lingmo-settings = pkgs.callPackage ./lingmo-pkgs/lingmo-settings.nix { inherit lingmoui lingmo-core; };
in
{
  # === Lingmo OS 桌面环境 ===
  # 极致硬核：当官方没有二进制包时，我们在 NixOS 本地现场为您从 C++ 源码编译！

  # 1. 启用显示服务
  services.xserver.enable = true;
  
  # 2. 标配 SDDM 显示管理器
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # 3. 注入 Lingmo 专属全局环境变量
  environment.variables = {
    QT_QPA_PLATFORMTHEME = "lingmo"; 
    XDG_CURRENT_DESKTOP = "lingmo";
  };

  # 4. 注册所有组件到系统
  environment.systemPackages = with pkgs; [
    # ---- 我们的自编译成果 ----
    lingmoui
    lingmo-core
    lingmo-settings
    
    # ---- Lingmo 的生态底座 (KDE/Qt) ----
    kdePackages.kwin
    kdePackages.qtwayland
    kdePackages.qtsvg
    kdePackages.plasma-wayland-protocols
    kdePackages.layer-shell-qt
  ];

  # 5. 会话注册：让 SDDM 能识别并启动 Lingmo
  # lingmo-core 编译后通常会抛出 /share/wayland-sessions/lingmo.desktop
  # NixOS 的 sessionPackages 选项会自动抓取它并送到登录界面
  services.displayManager.sessionPackages = [ lingmo-core ];

  # 6. 基础系统服务补充
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  programs.dconf.enable = true;
}
