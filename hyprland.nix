{ config, pkgs, ... }:

{
  # 开启 Hyprland 的 Home Manager 模块
  wayland.windowManager.hyprland = {
    enable = true;

    # 这里是自动配置环境变量，为了保证最好的兼容性，建议设为 true
    systemd.enable = true;
    xwayland.enable = true;

    # === 方法 A：直接粘贴你的旧配置 ===
    # 把你之前的 hyprland.conf 内容全部粘贴到下面两个单引号之间
    extraConfig = ''
      
# ==========================================
#  我的第一个 Hyprland 配置
# ==========================================

# 1. 显示器配置 (自动适配分辨率，如果不自动适配请手动指定)
monitor=,preferred,auto,auto

# 2. 启动时自动运行的软件
exec-once = dunst    # 通知
exec-once = sh -c "sleep 1"; waybar & # 状态栏
exec-once = fcitx5 -d --replace  # 输入法 (后面会教你装)
exec-once = hyprpaper       # 壁纸 (后面教你装)
exec-once = clash-verge &

# 3. 默认程序设定
$terminal = kitty
$menu = wofi --show drun

# 4. 环境变量 (让鼠标和界面更好看)
env = XCURSOR_SIZE,32

env = QT_AUTO_SCREEN_SCALE_FACTOR,1
env = QT_QPA_PLATFORM,wayland;xcb
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1

env = GDK_SCALE,1

# 5. 核心输入配置
input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = no
    }
}

# 6. 外观配置 (圆角、边框颜色)
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

# 7. 动画配置 (Hyprland 的精髓)
animations {
    enabled = yes
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# 8. 关键快捷键 (绑定)
$mainMod = SUPER

bind = $mainMod, Q, exec, $terminal      # 打开终端
bind = $mainMod, C, killactive,          # 关闭当前窗口
bind = $mainMod, M, exit,                # 退出 Hyprland
bind = $mainMod, E, exec, dolphin        # 打开文件管理器 (如果你修好了的话)
bind = $mainMod, V, togglefloating,      # 切换窗口悬浮/平铺
bind = $mainMod, R, exec, $menu          # 打开程序启动菜单 (Wofi)

# 切换焦点的快捷键 (用方向键或 hjkl)
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# 切换工作区 (1-5)
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5

# 移动窗口到工作区
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
# ...以此类推
    '';
  };
}
