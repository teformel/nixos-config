{ config, pkgs, ... }:

{
  # 开启 Hyprland 的 Home Manager 模块
  wayland.windowManager.hyprland = {
    enable = true;

    # 系统集成
    systemd.enable = true;
    xwayland.enable = true;

    # === 配置内容 ===
    extraConfig = ''
      
# ==========================================
#  ✨ Hyprland 美化版配置
# ==========================================

# 1. 显示器配置
monitor=,preferred,auto,auto

# 2. 自启应用
exec-once = dunst
exec-once = start-waybar
exec-once = fcitx5 -d --replace
exec-once = clash-verge &
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
exec-once = kdeconnect-indicator &
exec-once = udiskie -t -a &

# 3. 默认程序
$terminal = kitty
$menu = wofi --show drun

# === 🎨 装饰配置 (核心美化) ===
# 让窗口变得圆润、透明、有阴影
decoration {
    rounding = 15  # 圆角大小 (越大越圆)

    # ☁️ 毛玻璃模糊效果
    blur {
        enabled = true
        size = 5        # 模糊半径
        passes = 3      # 模糊强度 (3是黄金数值)
        new_optimizations = true
        ignore_opacity = true # 即使窗口全透明也模糊
    }

    # 🌑 阴影效果 (增加立体感)
    drop_shadow = true
    shadow_range = 30
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

# === 🎬 丝滑动画 (果冻效果) ===
animations {
    enabled = yes

    # 贝塞尔曲线 (定义动画的节奏：快-慢-快)
    bezier = wind, 0.05, 0.9, 0.1, 1.05
    bezier = winIn, 0.1, 1.1, 0.1, 1.1
    bezier = winOut, 0.3, -0.3, 0, 1
    bezier = liner, 1, 1, 1, 1

    # 应用动画
    animation = windows, 1, 6, wind, slide       # 窗口出现
    animation = windowsIn, 1, 6, winIn, slide    # 窗口弹入
    animation = windowsOut, 1, 5, winOut, slide  # 窗口弹出
    animation = windowsMove, 1, 5, wind, slide   # 窗口移动
    animation = border, 1, 1, liner
    animation = borderangle, 1, 30, liner, loop  # 边框流光
    animation = fade, 1, 10, default             # 渐变
    animation = workspaces, 1, 5, wind           # 工作区切换
}

# === ✨ 特效规则 ===
# 让 Waybar 也就是顶栏变成毛玻璃效果 (前提是你 CSS 里设了透明)
layerrule = blur, waybar
layerrule = ignorezero, waybar

# 4. 环境变量
env = XCURSOR_SIZE,32
env = QT_AUTO_SCREEN_SCALE_FACTOR,1
env = QT_QPA_PLATFORM,wayland;xcb
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
env = GDK_SCALE,1

xwayland {
  force_zero_scaling = true
}

# 5. 输入配置
input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = no
    }
}

# 6. 常规外观 (边框颜色)
general {
    gaps_in = 5      # 窗口间隙
    gaps_out = 10    # 边缘间隙
    border_size = 2
    
    # 🎨 边框颜色：蓝紫渐变
    col.active_border = rgba(89b4faee) rgba(cba6f7ee) 45deg
    col.inactive_border = rgba(595959aa)
    
    layout = dwindle
}

# 7. 窗口规则
windowrulev2 = float, class:^(steam)$, title:^(好友列表)$
windowrulev2 = float, class:^(steam)$, title:^(Steam - News)$
windowrulev2 = center, class:^(steam)$, title:^(Steam - News)$
windowrulev2 = stayfocused, title:^()$,class:^(steam)$
windowrulev2 = minsize 1 1, title:^()$,class:^(steam)$

# 8. 快捷键
$mainMod = SUPER

bind = $mainMod, Q, exec, $terminal
bind = $mainMod, C, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, dolphin
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, $menu

# 剪贴板历史
bind = SUPER SHIFT, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy

# 锁屏
bind = $mainMod, L, exec, hyprlock

# 焦点移动
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# 切换工作区
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5

# 移动窗口
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
    '';
  };
}
