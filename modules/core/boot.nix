{ config, pkgs, ... }:

{
  # 使用 systemd-boot 作为 EFI 启动引导
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # 使用 Zen 内核以获得更低的桌面延迟和更好的游戏响应
  boot.kernelPackages = pkgs.linuxPackages_zen;
  
  # 或者使用 linuxPackagesFor 函数包装 CachyOS 优化版内核 (需取消注释并配置 input)
  #boot.kernelPackages = pkgs.linuxPackagesFor inputs."nix-cachyos-kernel".packages.${pkgs.system}.linux-cachyos-latest-lto-x86_64-v3;

  # 确保 TUN 内核模块已加载
  boot.kernelModules = [ "tun" ];
}
