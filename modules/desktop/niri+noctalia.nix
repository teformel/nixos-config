# modules/desktop.nix
{ config, pkgs, inputs, ... }:

{
  # KDE Connect 防火墙规则
  networking.firewall.allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
  networking.firewall.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];

  # === 桌面环境与显示管理器 ===
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-mocha-mauve"; 
    
    # 🌟 1. 显式告诉 SDDM 使用哪个鼠标指针主题
    settings = {
      Theme = {
        # 这里的名字必须和光标主题文件夹的名字完全对应
        CursorTheme = "catppuccin-mocha-mauve-cursors"; 
      };
    };
    
    extraPackages = with pkgs; [
      kdePackages.qtsvg
      kdePackages.qtmultimedia
      kdePackages.qtvirtualkeyboard
      kdePackages.qt5compat
      
      # 🌟 2. 补上 Qt6 的 Wayland 支持模块，确保输入设备在 Wayland 下正确渲染
      kdePackages.qtwayland 
    ];
  };

  # 2. 保持 Niri 混成器为主力
  programs.niri.enable = true;

  # === 字体配置 ===
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    wqy_microhei
    wqy_zenhei
    nerd-fonts.fira-code  
    nerd-fonts.meslo-lg   
  ];

  # === 外观与基础配置 ===
  # 开启 dconf (虽然删了 GNOME，但许多 GTK 应用和 Niri 的某些底层行为仍依赖 dconf)
  programs.dconf.enable = true;
  
  qt = {
    enable = true;
    platformTheme = "qt5ct"; 
  };

  programs.firefox.enable = false;

  # === XDG 门户机制 ===
  xdg.portal = {
    enable = true;
    # 移除了 GNOME 专属的 portal，换成更通用的 wlr，保障 Niri 下的录屏和截图
    extraPortals = with pkgs; [ 
      xdg-desktop-portal-gtk 
      xdg-desktop-portal-wlr
    ];
    config.common.default = "*"; 
  };

  # === 文件管理器 ===
  # GNOME 的 Nautilus 被干掉了，Thunar 正式上位成为主力
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin 
      thunar-volman         
    ];
  };

  # === 基础服务 ===
  # Thunar 极度依赖 gvfs 和 udisks2 来实现垃圾篓、U盘自动挂载等功能，必须保留
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # 🌟 新增：声明全局默认终端
  environment.variables = {
    TERMINAL = "alacritty";
    # 顺手加上这个，能让很多终端应用（比如 bottom）的色彩显示更正常
    COLORTERM = "truecolor"; 
  };

  # === 系统包 ===
  environment.systemPackages = with pkgs; [
    glib                       
    gsettings-desktop-schemas  
    inputs.noctalia.packages.${pkgs.system}.default    
    wl-clipboard       
    xwayland-satellite 
    papirus-icon-theme 
    
    # 🌟 恢复 nwg-look！脱离了 GNOME Tweaks，你需要它来修改 GTK 主题、图标和鼠标指针
    nwg-look           
    
    kdePackages.qt6ct 
    libsForQt5.qt5ct  
    
    catppuccin-sddm
    # 🌟 3. 安装与你主题配套的 Catppuccin 鼠标包，提供实体的光标文件
    catppuccin-cursors.mochaMauve
  ];

  # 【用户层配置】
  home-manager.users.maorila = {
    # 🌟 Niri 极简配置内联管理
    # 你可以直接将 ~/.config/niri/config.kdl 的内容原封不动地粘贴到下面这对单引号中。
    # 每次 rebuild，它都会自动帮你覆盖生成标准的配置文件，彻底实现全系统配置一体化。
    xdg.configFile."niri/config.kdl".text = ''
      // ==========================================================
      // Niri + Noctalia 完整配置指南
      // ==========================================================
      
      // === 输入设备 ===
      input {
          keyboard {
              xkb {
                  // layout "us"
                  // options "caps:escape" // 可选: 将大写锁定键映射为 ESC
              }
          }
          touchpad {
              tap
              natural-scroll
              accel-speed 0.2 // 触摸板加速
              accel-profile "adaptive"
          }
          mouse {
              accel-profile "flat" // 禁用鼠标加速
          }
          // 焦点跟随鼠标
          focus-follows-mouse max-scroll-amount="0%"
      }

      // === 输出设备 (显示器) ===
      output "eDP-1" {
          // 笔记本屏幕缩放比例
          scale 1.25
          // variable-refresh-rate // 可选: 启用 VRR (防撕裂)
      }

      // === 布局配置 ===
      layout {
          gaps 16 // 窗口与窗口、窗口与屏幕边缘的间距
          center-focused-column "never" // 永远不将焦点列居中 ("never", "always", "on-overflow")
          
          preset-column-widths {
              proportion 0.33333
              proportion 0.5
              proportion 0.66667
          }
          default-column-width { proportion 0.5; }

          // 窗口焦点边框
          focus-ring {
              width 4
              active-color "#cba6f7" // Catppuccin Mocha Mauve (匹配你的系统主题)
              inactive-color "#585b70" // Catppuccin Mocha Surface 2
          }

          // 窗口插入提示
          insert-hint {
              color "rgba(203, 166, 247, 0.5)" // 半透明的 Mauve 色
          }
      }

      // === 偏好设置 ===
      prefer-no-csd // 强制移除客户端装饰 (CSD, 如 GTK 标题栏)

      // === 光标设置 ===
      cursor {
          // 这里 Niri 使用系统 Xcursor 机制
          xcursor-theme "catppuccin-mocha-mauve-cursors"
          xcursor-size 24
      }

      // === 动画设置 ===
      animations {
          workspace-switch { spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001; }
          window-open { duration-ms 150; curve "ease-out-expo"; }
          window-close { duration-ms 150; curve "ease-out-quad"; }
          horizontal-view-movement { spring damping-ratio=1.0 stiffness=800 epsilon=0.0001; }
          window-movement { spring damping-ratio=1.0 stiffness=800 epsilon=0.0001; }
          window-resize { spring damping-ratio=1.0 stiffness=800 epsilon=0.0001; }
      }

      // === 窗口规则 ===
      // 让画中画模式、部分弹窗自动浮动
      window-rule {
          match app-id="firefox$" title="^Picture-in-Picture$"
          match app-id="thunar" title="File Operation Progress"
          open-floating true
      }

      // === 自启动项 ===
      spawn-at-startup "fcitx5" "-d"
      spawn-at-startup "noctalia" // 🌟 启动 Noctalia Shell (状态栏/通知中心/OS 交互界面)

      // 可以考虑添加其他自启动项，例如壁纸工具：
      // spawn-at-startup "swaybg" "-i" "/path/to/wallpaper.png" "-m" "fill"

      // === 核心快捷键 (Binds) ===
      binds {
          // --- 基础控制 ---
          Mod+Shift+Slash { show-hotkey-overlay; }
          Mod+Return { spawn "alacritty"; }
          Mod+D { spawn "fuzzel"; }
          Mod+Q { close-window; }
          Mod+Shift+E { quit; }
          
          // --- 多媒体快捷键 (需系统中存在对应工具如 wireplumber/brightnessctl) ---
          XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
          XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
          XF86AudioMute        allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
          XF86MonBrightnessUp  allow-when-locked=true { spawn "brightnessctl" "set" "5%+"; }
          XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "5%-"; }

          // --- 截图 (Niri 原生支持) ---
          Print { screenshot; } // 交互式截图
          Ctrl+Print { screenshot-screen; } // 当前屏幕截图
          Alt+Print { screenshot-window; } // 当前窗口截图

          // --- 焦点切换 (方向键与 VIM 键位) ---
          Mod+Left  { focus-column-left; }
          Mod+Down  { focus-window-down; }
          Mod+Up    { focus-window-up; }
          Mod+Right { focus-column-right; }
          Mod+H     { focus-column-left; }
          Mod+J     { focus-window-down; }
          Mod+K     { focus-window-up; }
          Mod+L     { focus-column-right; }

          Mod+Home { focus-column-first; }
          Mod+End  { focus-column-last; }

          // --- 窗口移动 ---
          Mod+Ctrl+Left  { move-column-left; }
          Mod+Ctrl+Down  { move-window-down; }
          Mod+Ctrl+Up    { move-window-up; }
          Mod+Ctrl+Right { move-column-right; }
          Mod+Ctrl+H     { move-column-left; }
          Mod+Ctrl+J     { move-window-down; }
          Mod+Ctrl+K     { move-window-up; }
          Mod+Ctrl+L     { move-column-right; }

          Mod+Ctrl+Home { move-column-to-first; }
          Mod+Ctrl+End  { move-column-to-last; }

          // --- 窗口缩放 ---
          Mod+Minus { set-column-width "-10%"; }
          Mod+Equal { set-column-width "+10%"; }
          Mod+Shift+Minus { set-window-height "-10%"; }
          Mod+Shift+Equal { set-window-height "+10%"; }

          // --- 列布局与最大化 ---
          Mod+F { maximize-column; }
          Mod+Shift+F { fullscreen-window; }
          Mod+C { center-column; }

          // --- 浮动窗口 ---
          Mod+Shift+Space { toggle-window-floating; }
          Mod+Space       { switch-focus-between-floating-and-tiling; }

          // --- 工作区切换 ---
          Mod+1 { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+5 { focus-workspace 5; }
          Mod+6 { focus-workspace 6; }
          Mod+7 { focus-workspace 7; }
          Mod+8 { focus-workspace 8; }
          Mod+9 { focus-workspace 9; }

          Mod+Page_Down { focus-workspace-down; }
          Mod+Page_Up   { focus-workspace-up; }

          // --- 移动窗口到工作区 ---
          Mod+Shift+1 { move-column-to-workspace 1; }
          Mod+Shift+2 { move-column-to-workspace 2; }
          Mod+Shift+3 { move-column-to-workspace 3; }
          Mod+Shift+4 { move-column-to-workspace 4; }
          Mod+Shift+5 { move-column-to-workspace 5; }
          Mod+Shift+6 { move-column-to-workspace 6; }
          Mod+Shift+7 { move-column-to-workspace 7; }
          Mod+Shift+8 { move-column-to-workspace 8; }
          Mod+Shift+9 { move-column-to-workspace 9; }
          
          Mod+Shift+Page_Down { move-column-to-workspace-down; }
          Mod+Shift+Page_Up   { move-column-to-workspace-up; }
      }
    '';

    home.packages = with pkgs; [
      alacritty     # Niri 官方默认终端
      fuzzel        # Niri 官方默认的应用程序启动器 (Mod+D)
      brightnessctl # 屏幕亮度控制
      wireplumber   # 声音控制 (提供 wpctl)
    ];

    services.udiskie = {
      enable = true;
      tray = "always";
    };
  };
}
