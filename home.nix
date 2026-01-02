{ config, pkgs, ... }:

{
  imports = [
    ./hyprland.nix
    ./waybar/default.nix
  ];

  # 注意：这是必须要有的基本信息
  home.username = "maorila";
  home.homeDirectory = "/home/maorila";

  # 必须和系统版本一致
  home.stateVersion = "25.11";

  # === 你的个人软件 ===
  home.packages = with pkgs; [
    fastfetch
    btop
    # 以后你想装 QQ、网易云、Spotify 都在这里加
    # === 代理工具 ===
    clash-verge-rev  # 现代化的 Clash GUI 客户端
    mihomo           # 强大的代理内核 (原 Clash Meta)
    font-awesome          # 常用图标字体
    nerd-fonts.jetbrains-mono # 你的主力字体
    # 如果想显示更多怪奇图标，可以加上 material-design-icons
    material-design-icons
    # 定义一个叫 start-waybar 的小脚本
  (pkgs.writeShellScriptBin "start-waybar" ''
    # 先杀掉所有可能存在的 waybar 进程
    killall .waybar-wrapped waybar 2>/dev/null

    # 等待 1 秒，确保 Hyprland 图形界面已就绪
    sleep 1

    # 启动 waybar，并把日志输出丢掉，防止填满缓冲区
    waybar > /dev/null 2>&1 &
  '')
  ];

  # === 你的 Git 配置 ===
  programs.git = {
    enable = true;
    userName = "maorila";
    userEmail = "maorila@qq.com";
  };

  # === 你的 Bash 配置 ===
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
    };
  };

  # === Shell 别名配置 ===
  # 这会同时应用到 bash, zsh, fish 等所有 Shell
  home.shellAliases = {
    # 给带参数的启动方式起个新名字，比如 "chrome-x11"
    chrome-x11 = "google-chrome-stable --ozone-platform=x11";

    # 常用命令缩写示例 (顺便送你两个好用的)
    c = "clear";
    rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config";
  };

  # === 覆盖 Chrome 的启动图标 ===
  xdg.desktopEntries."google-chrome" = {
    name = "Google Chrome (X11)";  # 改个名方便确认生效了
    genericName = "Web Browser";
    # 重点在这里：强制加上 --ozone-platform=x11 参数
    exec = "${pkgs.google-chrome}/bin/google-chrome-stable --ozone-platform=x11 %U";
    terminal = false;
    icon = "google-chrome";
    categories = [ "Network" "WebBrowser" ];
    mimeType = [ "text/html" "text/xml" "application/xhtml+xml" "x-scheme-handler/http" "x-scheme-handler/https" ];
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      ms-python.python
      ms-vscode-remote.remote-ssh
    ];

    userSettings = {
      "editor.fontSize" = 16;
      "editor.fontFamily" = "'Fira Code','Droid Sans Mono','monospace'";
      "nix.enableLanguageServer" = true;
      "files.autoSave" = "onFocusChange";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # 让 Home Manager 管理自己
  programs.home-manager.enable = true;
}

