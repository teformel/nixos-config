{
  imports = [
    # 1. 大一统：所有日常应用软件的清单
    ./apps.nix

    # 2. 桌面环境 (按需开启其中一个)
    ./desktop/niri+noctalia.nix
    # ./desktop/lingmo.nix
    # ./desktop/kde.nix
  ];
}
