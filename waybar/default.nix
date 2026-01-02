{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    # 这一行很重要，确保 waybar 能找到 systemd
    systemd.enable = true;
  };

  # 直接把配置文件映射到 ~/.config/waybar/ 下
  xdg.configFile."waybar/config.jsonc".source = ./config.jsonc;
  xdg.configFile."waybar/style.css".source = ./style.css;
}
