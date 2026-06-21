{ config, pkgs, ... }: {
  home-manager.users.maorila = {
    home.packages = with pkgs; [ ghostty ];
  };
}
