{ config, pkgs, ... }:

{
  # 1. 开启图形驱动及 32 位支持 (Steam 和 Proton 强依赖)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # 2. 启用 Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # 打开防火墙以支持 Steam 局域网串流
    dedicatedServer.openFirewall = true; # 支持起源引擎独立服务器
  };
}
