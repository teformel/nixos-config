{
  imports = [
    # Core 核心区域与输入法
    ./core/locale.nix
    ./core/fcitx5.nix

    # Desktop 桌面环境 (仅取消注释一个即可切换桌面，所有基础组件均内置)
    # ./desktop/niri+noctalia.nix
    # ./desktop/lingmo.nix
    ./desktop/gnome.nix

    # --- Apps 独立软件 (按需取消注释即可开启) ---
    
    # 基础命令行工具
    ./apps/bash.nix
    ./apps/fish.nix
    ./apps/git.nix
    ./apps/neovim.nix
    ./apps/micro.nix
    ./apps/fastfetch.nix
    ./apps/eza.nix
    ./apps/yazi.nix
    ./apps/direnv.nix
    ./apps/bottom.nix
    ./apps/p7zip.nix
    ./apps/android-tools.nix
    ./apps/wget.nix
    ./apps/curl.nix

    # 游戏
    ./apps/steam.nix
    ./apps/gamemode.nix
    ./apps/gamescope.nix
    ./apps/lutris.nix
    ./apps/mangohud.nix
    ./apps/protonplus.nix
    ./apps/nix-ld.nix

    # 虚拟化与远程
    # ./apps/kvm.nix
    # ./apps/winapps.nix

    # 下载器
    # ./apps/aria2.nix

    # 媒体与影音
    # ./apps/obs.nix
    # ./apps/musicfox.nix
    # ./apps/cava.nix

    # 代理网络
    ./apps/clash-verge.nix
    # ./apps/clash-party.nix

    # 系统监视器
    ./apps/resources.nix
    ./apps/mission-center.nix

    # 开发与其他通用软件
    ./apps/vscode.nix
    ./apps/ghostty.nix
    ./apps/chrome.nix
    ./apps/localsend.nix
    ./apps/file-roller.nix
    # ./apps/ww-manager.nix
    # ./apps/antigravity.nix
  ];
}
