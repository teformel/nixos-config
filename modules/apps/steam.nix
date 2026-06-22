{ config, pkgs, ... }:

{
  # 游戏环境支持
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };
  # 游戏辅助包
  environment.systemPackages = with pkgs; [ mangohud gamescope lutris protonplus ];
}
