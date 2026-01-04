{ pkgs, ... }:
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        no_fade_in = false;
        grace = 0;
        disable_loading_bar = true;
      };

      background = [{
        path = "/home/maorila/Pictures/壁纸/杂图/IMG_20251220_094732.png";
        blur_passes = 2;
        blur_size = 7;
        noise = 0.0117;
        contrast = 0.8916;
        brightness = 0.8172;
        vibrancy = 0.1696;
        vibrancy_darkness = 0.0;
      }];

      label = [
        {
          text = "$TIME";
          color = "rgba(200, 200, 200, 1.0)";
          font_size = 120;
          font_family = "JetBrains Mono ExtraBold";
          position = "0, -300";
          halign = "center";
          valign = "top";
          shadow_passes = 2;
        }
        {
          text = "Hi, $USER";
          color = "rgba(200, 200, 200, 1.0)";
          font_size = 25;
          font_family = "JetBrains Mono";
          position = "0, -40";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = [{
        size = "250, 60";
        position = "0, -20";
        monitor = "";
        dots_center = true;
        fade_on_empty = false;
        font_color = "rgb(202, 211, 245)";
        inner_color = "rgba(0, 0, 0, 0.5)";
        outer_color = "rgba(0, 0, 0, 0)";
        outline_thickness = 5;
        placeholder_text = "Password...";
        shadow_passes = 2;
      }];
    };
  };
}