{ pkgs, ... }:
{
  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "image/jpeg" = ["imv.desktop"];
      "image/png" = ["imv.desktop"];
      "video/mp4" = ["mpv.desktop"];
    };
    defaultApplications = {
      "image/jpeg" = [ "imv.desktop" ];
      "image/png"  = [ "imv.desktop" ];
      "image/gif"  = [ "imv.desktop" ];
      "image/webp" = [ "imv.desktop" ];
      "image/bmp"  = [ "imv.desktop" ];
      "video/mp4"  = [ "mpv.desktop" ];
      "video/mkv"  = [ "mpv.desktop" ];
      "video/webm" = [ "mpv.desktop" ];
      "video/x-matroska" = [ "mpv.desktop" ];
      "audio/mpeg" = [ "io.bassi.Amberol.desktop" ];
      "audio/flac" = [ "io.bassi.Amberol.desktop" ];
      "text/plain" = [ "code.desktop" ];
      "application/pdf" = [ "google-chrome.desktop" ]; 
      "text/html" = [ "google-chrome.desktop" ];
    };
  };
  
  # 强制覆盖 mimeapps.list
  xdg.configFile."mimeapps.list".force = true;
}