{ config, pkgs, ... }: {
  # Clash Verge 服务与代理配置
  programs.clash-verge = {
    enable = true;
    tunMode = true;
    # 开启 serviceMode 以解决 TUN 模式权限问题
    serviceMode = true; 
    autoStart = true;
  };

  # 专属的防火墙规则
  networking.firewall = {
    enable = true;
    # 宽松的反向路径过滤，代理和 TUN 模式必须
    checkReversePath = "loose";
    # 信任 Clash 创建的虚拟网卡
    trustedInterfaces = [ "Mihomo" ];
  };
}
