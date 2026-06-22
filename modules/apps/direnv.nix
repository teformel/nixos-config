{ config, pkgs, ... }:

{
  home-manager.users.maorila = {
    # Direnv 环境隔离
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
