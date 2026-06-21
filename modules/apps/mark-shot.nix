{ config, pkgs, ... }: {
  home-manager.users.maorila = {
    home.packages = with pkgs; [
      mark-shot # 强力的 Wayland 原生截图与长截图工具
    ];
  };
}
