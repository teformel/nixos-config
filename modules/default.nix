{
  imports = [
    # Core 系统核心
    ./core/i18n.nix
    ./core/cli.nix

    # Desktop 桌面环境
    ./desktop/niri+noctalia.nix
    # ./desktop/lingmo.nix

    # Apps 独立软件
    ./apps/gaming.nix
    ./apps/virt.nix
    ./apps/downloader.nix
    ./apps/media.nix
    ./apps/clash-verge.nix
    ./apps/ww-manager.nix
  ];
}
