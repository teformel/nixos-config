{ config, pkgs, inputs, ... }:

{
  home-manager.users.maorila = {
    home.packages = with pkgs; [
      libnotify # 用于接收 Windows 的系统通知
      freerdp
      # 恢复最纯净的官方 winapps
      inputs.winapps.packages.${pkgs.system}.winapps
      inputs.winapps.packages.${pkgs.system}.winapps-launcher
  
      (pkgs.writeShellScriptBin "win11-full" ''
        export LIBVIRT_DEFAULT_URI="qemu:///system"
            
        # 清除 Wayland 强制环境变量，安稳走 XWayland
        unset GDK_BACKEND
        unset WLD_CHECK
        
        ${pkgs.freerdp}/bin/xfreerdp \
          /v:192.168.122.180 \
          /u:maorila \
          /p:maorila \
          /cert:ignore \
          /f \
          /bpp:32 \
          /gfx \
          /kbd:layout:0x00000804 \
          /network:lan \
          /scale-desktop:125 \
          /scale-device:140 \
          /clipboard \
          /audio-mode:0 \
          /sound:sys:pulse \
          /microphone:sys:pulse
      '')
    ];
  };
}
