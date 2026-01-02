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
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    sarasa-gothic
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
    (google-chrome.override {
      commandLineArgs = builtins.concatStringsSep " " [
        "--ozone-platform=x11"

        # ✨ 这里设置你想要的缩放比例
        # 如果你确实想要 "缩放为 1" (原始大小)，就填 1
        # 如果你觉得 1 太小了，可以填 1.25, 1.5 (配合你的屏幕倍率)
        # 只要这里填了参数，字就是清晰的，不会糊！
        "--force-device-scale-factor=1.5" 
      ];
    })
    # === 剪贴板工具 ===
    wl-clipboard  # 基础工具 (Wayland 剪贴板后端)
    cliphist      # 历史记录管理器
    # === 手机同步 ===
    kdePackages.kdeconnect-kde # KDE Connect 核心程序
    pavucontrol  # 必装：图形化音量控制器
    alsa-utils
    qq          # 官方 Linux QQ (新版 NT 架构，体验很好)
    wechat-uos  # 官方 Linux 微信 (UOS 适配版，功能较全)
    udiskie  # 自动挂载工具
    appimage-run  # ✨ 必装：AppImage 运行器
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
    # 常用命令缩写示例 (顺便送你两个好用的)
    c = "clear";
    rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config";
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

  # === 🖼️ 壁纸管理 (Hyprpaper) ===
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false; # 关闭那个烦人的启动文字
      
      # 1. 预加载图片 (必须先加载才能用)
      preload = [
        "/home/maorila/Pictures/壁纸/杂图/IMG_20251220_094732.png"
      ];

      # 2. 设置壁纸
      # 格式: "显示器名,图片路径"
      # 第一个参数留空 (,,) 表示应用到所有显示器
      wallpaper = [
        ",/home/maorila/Pictures/壁纸/杂图/IMG_20251220_094732.png"
      ];
    };
  };

  # === 关键：让 Home Manager 接管字体配置 ===
  # 这能解决部分软件在用户级安装后字体发虚、锯齿的问题
  fonts.fontconfig.enable = true;

  # 让 Home Manager 管理自己
  programs.home-manager.enable = true;
}

