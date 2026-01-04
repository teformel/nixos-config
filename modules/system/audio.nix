{ pkgs, ... }:

{
  # === 🔊 声音服务配置 (PipeWire) ===
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # === 🚑 固件支持 ===
  hardware.enableAllFirmware = true;
  hardware.firmware = [ pkgs.sof-firmware ];

  # === 🔊 声明式音频修复 (Sof-Essx8336) ===
  # 这种声卡默认会把 DAC 通道静音，这里我们强制在开机时打开它
  systemd.services.fix-sof-sound = {
    description = "Unmute sof-essx8336 channels on boot";
    after = [ "sound.target" "pipewire.service" ]; 
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      CARD="sofessx8336"
      ${pkgs.alsa-utils}/bin/amixer -c $CARD sset 'Left Headphone Mixer Left DAC' on
      ${pkgs.alsa-utils}/bin/amixer -c $CARD sset 'Right Headphone Mixer Right DAC' on
      ${pkgs.alsa-utils}/bin/amixer -c $CARD sset 'Speaker' on
      ${pkgs.alsa-utils}/bin/amixer -c $CARD sset 'Headphone' on
      ${pkgs.alsa-utils}/bin/amixer -c $CARD sset 'DAC' 100% || true
    '';
  };
}