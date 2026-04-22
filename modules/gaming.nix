# modules/gaming.nix
{ config, pkgs, ... }:

{
  # 1. 开启图形驱动及 32 位支持 (Steam 和 Proton 强依赖)
  # 注意：在最新的 nixos-unstable (24.11/25.05+) 中，hardware.opengl 已更名为 hardware.graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # 2. 启用 Steam (必须通过 programs 启用，不要只放在 environment.systemPackages)
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # 打开防火墙以支持 Steam 局域网串流
    dedicatedServer.openFirewall = true; # 支持起源引擎独立服务器
    # gamescopeSession.enable = true; # 可选：启用 gamescope 独立会话，适合做类似 SteamOS 的全屏游戏机体验
  };

  # 3. 启用 Gamemode (系统服务，游戏启动时动态优化 CPU 调度和 GPU 性能)
  programs.gamemode.enable = true;

  programs.gamescope = {
    enable = true;
    capSysNice = false;
  };

  # 4. 安装 Lutris 及其他辅助工具
  environment.systemPackages = with pkgs; [
    lutris
    protonplus     # 现代化的 Proton 版本管理工具
    mangohud       # 游戏性能监控浮窗 (类似 MSI Afterburner)
    protonup-qt    # 图形化工具，用于方便地下载并安装非官方的 Proton-GE 兼容层
    gamescope-wsi
    #gamescope      # 微型合成器，常用来强行给游戏限制分辨率或突破无边框全屏限制
  ];

  # 可选：如果你使用特定的手柄，建议开启系统级 udev 规则
  # hardware.xpadneo.enable = true; # Xbox One 蓝牙手柄
}
