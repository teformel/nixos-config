{ pkgs, ... }:
{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [ "/home/maorila/Pictures/壁纸/杂图/IMG_20251220_094732.png" ];
      wallpaper = [ ",/home/maorila/Pictures/壁纸/杂图/IMG_20251220_094732.png" ];
    };
  };
}