{ pkgs, ... }:

{
  # === 🎮 Steam 游戏平台 ===
  programs.steam = {
    enable = true;
    
    # 开启 Steam 串流 (手机玩电脑游戏)
    remotePlay.openFirewall = true; 
    
    # 开启局域网联机发现
    dedicatedServer.openFirewall = true;
    
    # 修复 Steam 里的中文输入法问题
    extest.enable = true; 
  };
  
  # === 🎮 游戏模式 ===
  # 玩游戏时自动优化 CPU/GPU 性能
  programs.gamemode.enable = true;

  # 可以在这里加其他的游戏相关库，比如手柄驱动等
  hardware.xpadneo.enable = true; # 如果你有 Xbox 手柄
}