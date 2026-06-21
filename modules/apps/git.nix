{ config, pkgs, ... }:

{
  home-manager.users.maorila = {
    programs.git = {
      enable = true;
      settings.user.email = "maorila@qq.com";
      settings.user.name = "maorila";
    };
    home.packages = with pkgs; [ git ];
  };
}
