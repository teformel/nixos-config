{ config, pkgs, inputs, ... }: {
  # Clash Party (Mihomo Party) 的用户级安装
  home-manager.users.maorila = {
    home.packages = [
      # 注意：由于 clash-party (mihomo-party) 目前并未正式进入 nixpkgs 官方源，
      # 此处假设你在自定义的 my-nur 中对其进行了打包。
      # 如果名字不对，请修改为 pkgs.mihomo-party 或相应的包名。
      (inputs.my-nur.packages.${pkgs.system}.clash-party or inputs.my-nur.packages.${pkgs.system}.mihomo-party)
    ];
  };

  # 专属的防火墙规则（保留 TUN 模式支持）
  networking.firewall = {
    enable = true;
    # 宽松的反向路径过滤，代理和 TUN 模式必须
    checkReversePath = "loose";
    # 信任 Clash/Mihomo 创建的虚拟网卡（根据 clash-party 的实际网卡名调整）
    trustedInterfaces = [ "Mihomo" "mihomo" "Meta" ];
  };
}
