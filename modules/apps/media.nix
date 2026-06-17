{ config, pkgs, ... }: {
  # 【用户层配置】
  home-manager.users.maorila = {
    home.packages = with pkgs; [
      go-musicfox
      cava
    ];
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-pipewire-audio-capture
      ];
    };
  };
}
