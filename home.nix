{ config, pkgs, ... }:

{
  imports = [
    ./modules/desktop/hyprland
    ./modules/desktop/waybar
    ./modules/desktop/fastfetch
    ./modules/desktop/shell
  ];

  # 注意：这是必须要有的基本信息
  home.username = "maorila";
  home.homeDirectory = "/home/maorila";
  # 必须和系统版本一致
  home.stateVersion = "25.11";

  # === 你的个人软件 ===
  home.packages = with pkgs; [
    # 以后你想装 QQ、网易云、Spotify 都在这里加
    # === 代理工具 ===
    clash-verge-rev  # 现代化的 Clash GUI 客户端
    mihomo           # 强大的代理内核 (原 Clash Meta)
    kitty        # 终端
    wofi         # 菜单
    dunst        # 通知
    kdePackages.dolphin # 文件管理器
    # 定义一个叫 start-waybar 的小脚本
    (pkgs.writeShellScriptBin "start-waybar" ''
      # 先杀掉所有可能存在的 waybar 进程
      killall .waybar-wrapped waybar 2>/dev/null

      # 等待 1 秒，确保 Hyprland 图形界面已就绪
      sleep 0.3

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
    mangohud    # 游戏里显示 FPS/CPU 温度
    protonup-qt # 必装！用于下载 GE-Proton (解决很多游戏打不开的问题)
    wlogout  # 关机菜单
    btop     # 任务管理器
    brightnessctl # ✨ 控制屏幕亮度的神器
    playerctl   # ✨ 媒体控制 (切歌/暂停)
    # === 📸 截屏工具 ===
    grim    # 核心：负责把屏幕画面抓下来
    slurp   # 核心：负责让你用鼠标画一个框
    swappy  # 核心：负责弹出一个编辑窗口，让你画箭头、保存
    adwaita-icon-theme  # ✨ 修复 Fcitx 和系统托盘图标丢失
    # === 🎬 多媒体全家桶 ===
    mpv              # 视频播放器 (极简、高性能)
    imv              # 图片查看器 (Wayland 原生，超快)
    amberol          # 音乐播放器 (界面很美，专注听歌)
    # === 🧩 缩略图增强 (让 Dolphin 显示视频预览) ===
    ffmpegthumbnailer 
    kdePackages.qtimageformats # 让 Dolphin 支持更多图片格式(如webp)
    # 🩹 核心修复：提供 Dolphin 缺失的菜单结构文件
    gnome-menus
    # 📶 网络管理全家桶
    networkmanagerapplet  # 提供 nm-applet (托盘图标) 和 nm-connection-editor (编辑工具)
    tree  # 经典树状图工具
    eza   # 现代 ls 替代品 (支持 tree 模式)
  ];

  # === 1. 定义默认软件关联 (这是核心配置) ===
  xdg.mimeApps = {
    enable = true;
    
    # 强制让这套配置生效，不让 KDE 乱改
    # 这会解决 "Existing file ... would be clobbered" 的报错
    # 也会解决 Dolphin 记不住的问题
    associations.added = {
      "image/jpeg" = ["imv.desktop"];
      "image/png" = ["imv.desktop"];
      "video/mp4" = ["mpv.desktop"];
    };
    
    defaultApplications = {
      # 🖼️ 图片 -> imv
      "image/jpeg" = [ "imv.desktop" ];
      "image/png"  = [ "imv.desktop" ];
      "image/gif"  = [ "imv.desktop" ];
      "image/webp" = [ "imv.desktop" ];
      "image/bmp"  = [ "imv.desktop" ];

      # 🎬 视频 -> mpv
      "video/mp4"  = [ "mpv.desktop" ];
      "video/mkv"  = [ "mpv.desktop" ];
      "video/webm" = [ "mpv.desktop" ];
      "video/x-matroska" = [ "mpv.desktop" ];

      # 🎵 音乐 -> Amberol
      "audio/mpeg" = [ "io.bassi.Amberol.desktop" ];
      "audio/flac" = [ "io.bassi.Amberol.desktop" ];
      
      # 📄 文本 -> VSCode
      "text/plain" = [ "code.desktop" ];
      "application/pdf" = [ "google-chrome.desktop" ]; 
      "text/html" = [ "google-chrome.desktop" ];
    };
  };
  # === 2. ✨ 关键修复：强制接管配置文件 ===
  # 这行代码的意思是：如果不小心产生了冲突文件，直接覆盖它！
  # 这样你就再也不用手动去 rm 删除文件了。
  xdg.configFile."mimeapps.list".force = true;

  # === 定义截图脚本 ===
  # 这个脚本的逻辑是：
  # 1. 运行 slurp 让用户选区
  # 2. 运行 grim 把选区截图
  # 3. 传给 swappy 进行编辑
  home.file.".local/bin/myshot".source = pkgs.writeShellScript "myshot" ''
    # 如果没选区直接取消，不报错
    GEOMETRY=$(slurp) || exit 1
    
    # 截图并发送给 Swappy 编辑
    grim -g "$GEOMETRY" - | swappy -f -
  '';

  # 配置 Swappy 把图片默认保存在哪里
  xdg.configFile."swappy/config".text = ''
    [Default]
    save_dir=$HOME/Pictures/Screenshots
    save_filename_format=Screenshot_%Y-%m-%d_%H-%M-%S.png
    show_panel=true
    line_size=5
    text_size=20
    text_font=sans-serif
    paint_mode=brush
    early_exit=false
    fill_shape=false
  '';

  # === 你的 Git 配置 ===
  programs.git = {
    enable = true;
    # ✨ 改成这种层级结构
    settings = {
      user = {
        name = "maorila";
        email = "maorila@qq.com";
      };
    };
  };

  # === Shell 别名配置 ===
  # 这会同时应用到 bash, zsh, fish 等所有 Shell
  home.shellAliases = {
    # 常用命令缩写示例 (顺便送你两个好用的)
    c = "clear";
    rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config";
    ff = "fastfetch";
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    # ✨ 新增这层 profiles.default
    profiles.default = {
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

  # === 🔒 锁屏界面 (Hyprlock) ===
  programs.hyprlock = {
    enable = true;
    
    settings = {
      general = {
        no_fade_in = false;
        grace = 0;
        disable_loading_bar = true;
      };

      # 🖼️ 背景配置 (毛玻璃效果)
      background = [
        {
          path = "/home/maorila/Pictures/壁纸/杂图/IMG_20251220_094732.png"; # 你的壁纸路径
          blur_passes = 2; # 模糊强度 (0-4)
          blur_size = 7;
          noise = 0.0117;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
        }
      ];

      # 🕒 时间显示 (大字体)
      label = [
        {
          text = "$TIME";
          color = "rgba(200, 200, 200, 1.0)";
          font_size = 120;
          font_family = "JetBrains Mono ExtraBold";
          position = "0, -300";
          halign = "center";
          valign = "top";
          shadow_passes = 2;
        }
        # 👤 用户问候语
        {
          text = "Hi, $USER";
          color = "rgba(200, 200, 200, 1.0)";
          font_size = 25;
          font_family = "JetBrains Mono";
          position = "0, -40";
          halign = "center";
          valign = "center";
        }
      ];

      # ⌨️ 输入框 (极简风格)
      input-field = [
        {
          size = "250, 60";
          position = "0, -20";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgba(0, 0, 0, 0.5)"; # 半透明黑色背景
          outer_color = "rgba(0, 0, 0, 0)";   # 无边框
          outline_thickness = 5;
          placeholder_text = "Password...";
          shadow_passes = 2;
        }
      ];
    };
  };

  # === 💤 自动休眠服务 (Hypridle) ===
  # 必须装这个，否则无法自动锁屏
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";       # 锁屏命令
        before_sleep_cmd = "loginctl lock-session";    # 睡眠前锁屏
        after_sleep_cmd = "hyprctl dispatch dpms on";  # 唤醒后打开屏幕
      };

      listener = [
        {
          timeout = 300;                                # 5分钟无操作
          on-timeout = "loginctl lock-session";         # 锁屏
        }
        {
          timeout = 330;                                # 5.5分钟无操作
          on-timeout = "hyprctl dispatch dpms off";     # 关闭屏幕省电
          on-resume = "hyprctl dispatch dpms on";       # 动鼠标就亮屏
        }
      ];
    };
  };

  # === 🖱️ 全局鼠标光标配置 (修复 Gdk-Message 报错) ===
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  # === ⌨️ 强制修复 Fcitx5 输入法界面太小 ===
  # 直接生成配置文件，强制设置大字体
  home.file.".config/fcitx5/conf/classicui.conf".text = ''
    # 垂直列表 (选词更符合直觉)
    Vertical Candidate List=False
    
    # 按屏幕 DPI 缩放 (如果这个不管用，下面的 Font 会兜底)
    PerScreenDPI=True
    
    # ✨ 核心修复：强制设置一个大字体
    # "字体名 字号"，比如这里设为 16 或 18 (默认通常是 10，太小了)
    Font="JetBrains Mono 16"
    
    # 主题设置 (你可以选个喜欢的主题，或者用默认)
    Theme=default
  '';
}

