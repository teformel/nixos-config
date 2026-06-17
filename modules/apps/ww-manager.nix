{ config, pkgs, inputs, ... }: {
  # 独立分离的 ww-manager 应用模块 (降级为用户级安装)
  home-manager.users.maorila = {
    home.packages = [
      inputs.my-nur.packages.${pkgs.system}.ww-manager
    ];
  };
}
