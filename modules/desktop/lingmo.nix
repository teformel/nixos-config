{ config, pkgs, lib, inputs, ... }:

let
  # 从我们在 NUR 中托管的专属包中，拉取 Lingmo 桌面套件
  nurPkgs = (import inputs.nur { inherit pkgs; }).repos.teformel;
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
  };

  # 3. 注入 Lingmo 专属全局环境变量
  environment.variables = {
    QT_QPA_PLATFORMTHEME = "lingmo"; 
    XDG_CURRENT_DESKTOP = "lingmo";
  };

  # 4. 注册所有组件到系统
  environment.systemPackages = with pkgs; [
    # ---- 我们的自编译成果 (来自 NUR) ----
    nurPkgs.lingmoui
    nurPkgs.lingmo-core
    nurPkgs.lingmo-settings
    
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
