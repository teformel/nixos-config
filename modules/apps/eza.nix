{ config, pkgs, ... }:

{
  home-manager.users.maorila = {
    home.packages = with pkgs; [ eza ];
    programs.eza = {
      enable = true;
      git = true;
      icons = "auto";
    };
  };
}
