{ config, pkgs, ... }:

{
  programs.bash.enable = true;
  home-manager.users.maorila = {
    programs.bash.enable = true;
  };
}
