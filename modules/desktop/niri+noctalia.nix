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
      // 这是一份基于 Niri 官方默认配置精简的 KDL 文件
      
      input {
          keyboard {
              xkb { }
          }
          touchpad {
              tap
              natural-scroll
          }
      }

      output "eDP-1" {
          // 笔记本屏幕缩放比例
          scale 1.25
      }

      layout {
          gaps 16
          center-focused-column "never"
          preset-column-widths {
              proportion 0.33333
              proportion 0.5
              proportion 0.66667
          }
          default-column-width { proportion 0.5; }
          
          focus-ring {
              width 4
              active-color "#7fc8ff"
              inactive-color "#505050"
          }
      }

      // 自启动项
      spawn-at-startup "fcitx5" "-d"

      // 核心快捷键
      binds {
          // 显示所有快捷键提示面板
          Mod+Shift+Slash { show-hotkey-overlay; }
          
          // 启动默认终端和应用启动器
          Mod+Return { spawn "alacritty"; }
          Mod+D { spawn "fuzzel"; }
          
          // 窗口管理
          Mod+Q { close-window; }
          Mod+Shift+E { quit; }
          
          // 焦点切换
          Mod+Left  { focus-column-left; }
          Mod+Down  { focus-window-down; }
          Mod+Up    { focus-window-up; }
          Mod+Right { focus-column-right; }
      }
    '';

    home.packages = with pkgs; [
      alacritty # Niri 官方默认终端
      fuzzel    # Niri 官方默认的应用程序启动器 (Mod+D)
    ];

    services.udiskie = {
      enable = true;
      tray = "always";
    };
  };
}
