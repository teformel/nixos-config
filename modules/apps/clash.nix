{ config, pkgs, inputs, ... }:

{
  # 代理与网络特殊配置 (Clash Party TUN 模式防火墙放行)
  networking.firewall = {
    enable = true;
    checkReversePath = "loose"; # 代理软件的 TUN 模式必须
    trustedInterfaces = [ "Mihomo" "mihomo" "Meta" ];
  };

  # 将软件安装也聚合于此，实现“装配一体”
  home-manager.users.maorila = {
    home.packages = [
      pkgs.clash-verge-rev  # 官方源的 Clash Verge Rev
      (inputs.my-nur.packages.${pkgs.system}.clash-party or inputs.my-nur.packages.${pkgs.system}.mihomo-party)
    ];
  };
}
