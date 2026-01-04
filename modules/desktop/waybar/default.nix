{ pkgs, ... }:

{
  # === 1. Waybar 基础配置 ===
  programs.waybar = {
    enable = true;
    systemd.enable = false; # 我们自己用脚本管理启动
  };

  # === 2. 配置文件映射 ===
  xdg.configFile."waybar/config.jsonc".source = ./config.jsonc;
  xdg.configFile."waybar/style.css".source = ./style.css;

  # === 3. 伴生工具与脚本 ===
  home.packages = with pkgs; [
    # 🔧 依赖工具：脚本里用到了 killall，所以必须装这个
    psmisc 

    # 📜 自定义启动脚本
    (writeShellScriptBin "start-waybar" ''
      # 杀掉所有旧进程 (防止重复启动)
      killall .waybar-wrapped waybar 2>/dev/null

      # 等待一小会儿，确保图形服务就绪
      sleep 0.3

      # 启动 waybar，并屏蔽烦人的日志输出
      waybar > /dev/null 2>&1 &
    '')
  ];
}