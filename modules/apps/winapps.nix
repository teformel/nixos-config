{ config, pkgs, inputs, ... }:

{
  home-manager.users.maorila = {
    home.packages = with pkgs; [
      # WinApps 及其依赖
      libnotify
      freerdp
      inputs.winapps.packages.${pkgs.system}.winapps
      inputs.winapps.packages.${pkgs.system}.winapps-launcher
  
      # WinApps 专属 RDP 启动脚本
      (pkgs.writeShellScriptBin "win11-full" ''
        export LIBVIRT_DEFAULT_URI="qemu:///system"
        unset GDK_BACKEND
        unset WLD_CHECK
        ${pkgs.freerdp}/bin/xfreerdp \
          /v:192.168.122.180 /u:maorila /p:maorila /cert:ignore /f \
          /bpp:32 /gfx /kbd:layout:0x00000804 /network:lan \
          /scale-desktop:125 /scale-device:140 /clipboard \
          /audio-mode:0 /sound:sys:pulse /microphone:sys:pulse
      '')
    ];
  };
}
