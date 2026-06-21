{
  imports = [
    # 1. 大一统：所有日常应用软件的清单
    ./apps.nix

    # 2. 图形桌面环境 (当前处于 gnome 分支)
    ./desktop.nix
  ];
}
