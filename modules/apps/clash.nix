{ config, pkgs, ... }:

{
  # 代理与网络特殊配置 (Clash Party TUN 模式防火墙放行)
  networking.firewall = {
    enable = true;
    checkReversePath = "loose"; # 代理软件的 TUN 模式必须
    trustedInterfaces = [ "Mihomo" "mihomo" "Meta" ];
  };
}
