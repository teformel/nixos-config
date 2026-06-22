{ config, pkgs, ... }:

{
  home-manager.users.maorila = {
    # Git 的基础配置
    programs.git = {
      enable = true;
    };
  };
}
