{ config, pkgs, ... }:

{
  programs.fish.enable = true;
  home-manager.users.maorila = {
    home.packages = with pkgs; [ fish ];
    programs.fish = {
      enable = true;
    };
  };
}
