{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;

    extraConfig = ''
      
# ==========================================
#  ✨ Hyprland 修复版配置
# ==========================================

# 1. 显示器
monitor=,preferred,auto,auto

# 2. 自启服务
exec-once = dunst
exec-once = start-waybar
exec-once = fcitx5 -d --replace
exec-once = clash-verge &
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
exec-once = kdeconnect-indicator &
exec-once = udiskie -t -a &

# 3. 基础变量
$terminal = kitty
$menu = wofi --show drun
$mainMod = SUPER

# === 🎨 外观与装饰 (已适配 Hyprland v0.45+) ===
decoration {
    rounding = 15

    # ☁️ 毛玻璃
    blur {
        enabled = true
        size = 5
        passes = 3
        new_optimizations = true
        ignore_opacity = true
    }

    # 🌑 阴影 (新版语法：必须嵌套在 shadow {} 里)
    shadow {
        enabled = true
        range = 30
        render_power = 3
        color = rgba(1a1a1aee)
    }
}

# === 🎬 动画 (注意大括号闭合) ===
animations {
    enabled = yes
    bezier = wind, 0.05, 0.9, 0.1, 1.05
    bezier = winIn, 0.1, 1.1, 0.1, 1.1
    bezier = winOut, 0.3, -0.3, 0, 1
    bezier = liner, 1, 1, 1, 1

    animation = windows, 1, 6, wind, slide
    animation = windowsIn, 1, 6, winIn, slide
    animation = windowsOut, 1, 5, winOut, slide
    animation = windowsMove, 1, 5, wind, slide
    animation = border, 1, 1, liner
    animation = borderangle, 1, 30, liner, loop
    animation = fade, 1, 10, default
    animation = workspaces, 1, 5, wind
}

# === ✨ 特效规则 (已修复空格问题) ===
# 之前的报错 invalid field blur 就是因为这里
# layerrule = blur, waybar
# layerrule = ignorezero, waybar

# 4. 环境变量与杂项
env = QT_AUTO_SCREEN_SCALE_FACTOR,1
env = QT_QPA_PLATFORM,wayland;xcb
env = GDK_SCALE,1
# === 👇 新增：强制统一鼠标样式 (解决鼠标不一致的核心) ===
# 告诉所有 XWayland 程序使用这个主题
env = XCURSOR_THEME,Bibata-Modern-Ice
# 确保大小一致 (如果你 home.nix 里是 24，这里也写 24)
env = XCURSOR_SIZE,24

xwayland {
  force_zero_scaling = true
}

input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = no
    }
}

general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(89b4faee) rgba(cba6f7ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

# 5. 窗口规则
windowrulev2 = float, class:^(steam)$, title:^(好友列表)$
windowrulev2 = float, class:^(steam)$, title:^(Steam - News)$
windowrulev2 = center, class:^(steam)$, title:^(Steam - News)$
windowrulev2 = stayfocused, title:^()$,class:^(steam)$
windowrulev2 = minsize 1 1, title:^()$,class:^(steam)$

# 6. 快捷键
bind = $mainMod, T, exec, $terminal
bind = $mainMod, C, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, dolphin
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, $menu
bind = $mainMod, L, exec, hyprlock

# === 📸 截图快捷键 ===
    # Print 键：区域截图 -> 自动跳出编辑窗口 -> 编辑完按 Ctrl+C 复制，或点保存
    bind = , Print, exec, ~/.local/bin/myshot

    # Shift + Print 键：全屏截图 (不选区，直接截整个屏幕)
    bind = SHIFT, Print, exec, grim - | swappy -f -

# ==========================================
# 🎹 笔记本功能键修复
# ==========================================

# 1. 🔊 音量控制 (使用 wpctl，它是 PipeWire 的标准工具)
# 这里的 @DEFAULT_AUDIO_SINK@ 会自动识别你当前的声卡
bindel = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bindel = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bindl  = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
# 麦克风静音
bindl  = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

# 2. ☀️ 亮度控制 (使用 brightnessctl)
bindel = , XF86MonBrightnessUp, exec, brightnessctl set 5%+
bindel = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

# 3. 🎵 媒体控制 (使用 playerctl)
# 无论你在用 Spotify、网易云还是浏览器，它都能控制
bindl = , XF86AudioPlay, exec, playerctl play-pause
bindl = , XF86AudioNext, exec, playerctl next
bindl = , XF86AudioPrev, exec, playerctl previous

# 剪贴板
bind = SUPER SHIFT, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy

# 焦点与工作区
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5

bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
    '';
  };
}
