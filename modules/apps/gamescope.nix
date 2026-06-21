{ config, pkgs, ... }:

{
  programs.gamescope = {
    enable = true;
    capSysNice = false;
  };
  
  home-manager.users.maorila = {
    home.packages = with pkgs; [ gamescope-wsi ];
  };
}
