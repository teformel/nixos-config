{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;

    # ✨ 核心改变：使用 settings 代替 extraConfig
    settings = {
      
      # === 1. 显示器与基础变量 ===
      monitor = ",preferred,auto,auto";
      
      "$terminal" = "kitty";
      "$menu" = "wofi --show drun";
      "$mainMod" = "SUPER";

      # === 2. 环境变量 (列表形式) ===
      env = [
        "QT_QPA_PLATFORM,wayland;xcb"
        "XCURSOR_THEME,Bibata-Modern-Ice"
        "XCURSOR_SIZE,24"
        
        # 📺 屏幕缩放修复
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "QT_SCALE_FACTOR,1.5"
        "GDK_SCALE,2"
        
        # 📂 修复 Dolphin 关联问题的关键 (GNOME 菜单)
        "XDG_MENU_PREFIX,gnome-"
      ];

      # === 3. 自启服务 (列表形式，更加整洁) ===
      exec-once = [
        "dunst"
        "start-waybar" # 确保你有这个脚本，或者直接写 "waybar"
        "fcitx5 -d --replace"
        "clash-verge &"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "kdeconnect-indicator &"
        "udiskie -t -a &"
        "nm-applet --indicator" # WiFi 托盘
      ];

      # === 4. 输入设备配置 ===
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = false;
        };
      };

      # === 5. 外观与装饰 ===
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(89b4faee) rgba(cba6f7ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 15;

        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
        };

        # 适配 Hyprland v0.45+ 的阴影写法
        shadow = {
          enabled = true;
          range = 30;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };

      # === 6. 动画配置 ===
      animations = {
        enabled = true;
        # 贝塞尔曲线定义
        bezier = [
          "wind, 0.05, 0.9, 0.1, 1.05"
          "winIn, 0.1, 1.1, 0.1, 1.1"
          "winOut, 0.3, -0.3, 0, 1"
          "liner, 1, 1, 1, 1"
        ];
        # 动画规则
        animation = [
          "windows, 1, 6, wind, slide"
          "windowsIn, 1, 6, winIn, slide"
          "windowsOut, 1, 5, winOut, slide"
          "windowsMove, 1, 5, wind, slide"
          "border, 1, 1, liner"
          "borderangle, 1, 30, liner, loop"
          "fade, 1, 10, default"
          "workspaces, 1, 5, wind"
        ];
      };

      # === 7. 布局与 XWayland ===
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      xwayland = {
        force_zero_scaling = true; # 解决模糊问题
      };

      # === 8. 窗口规则 (Window Rules) ===
      windowrulev2 = [
        "float, class:^(steam)$, title:^(好友列表)$"
        "float, class:^(steam)$, title:^(Steam - News)$"
        "center, class:^(steam)$, title:^(Steam - News)$"
        "stayfocused, title:^()$,class:^(steam)$"
        "minsize 1 1, title:^()$,class:^(steam)$"
      ];

      # === 9. 按键绑定 (Keybinds) ===
      bind = [
        "$mainMod, T, exec, $terminal"
        "$mainMod, C, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, dolphin"
        "$mainMod, V, togglefloating,"
        "$mainMod, R, exec, $menu"
        "$mainMod, L, exec, hyprlock"

        # 截图
        ", Print, exec, ~/.local/bin/myshot"
        "SHIFT, Print, exec, grim - | swappy -f -"
        
        # 剪贴板
        "SUPER SHIFT, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"

        # 焦点移动
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # 工作区切换
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"

        # 移动窗口到工作区
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
      ];

      # 媒体与特殊按键 (bindl / bindel)
      # 这里比较特殊，Nix 的 keys 必须是唯一的，所以我们将它们混入 bind 列表
      # 或者使用 bindl = [...] 和 bindel = [...] 分开写
      
      bindel = [
        # 音量
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        # 亮度
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      bindl = [
        # 静音与媒体控制
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];
    };
  };
}