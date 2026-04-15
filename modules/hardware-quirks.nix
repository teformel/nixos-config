# modules/hardware-quirks.nix
{ config, pkgs, ... }:

{
  # 把内核参数移过来
  boot.kernelParams = [ 
    # === 🔊 新增：音频修复参数 ===
    # 0x01 是最通用的值，如果重启后还没声音，可以尝试 0x02 或 0x04
    "snd_soc_sof_8336.quirk=0x01"
  ];
  # 固件支持
  hardware.enableAllFirmware = true;
  hardware.firmware = [ pkgs.sof-firmware ];

  # 音频服务
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # 把音频相关的包移过来
  environment.systemPackages = with pkgs; [
    alsa-ucm-conf
    alsa-utils
    # 推荐装这个，方便图形化看哪个通道没开
    pavucontrol
  ];

  # 🔊 声明式音频修复 (Sof-Essx8336)
  # 这种声卡默认会把 DAC 通道静音，这里我们强制在开机时打开它
  systemd.services.fix-sof-sound = {
    description = "Unmute sof-essx8336 channels on boot";
    after = [ "sound.target" "pipewire.service" ]; 
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      # 给驱动一点反应时间
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
    };
    script = ''
      # 自动查找包含 sof-ess8336 的声卡编号
      CARD_ID=$(${pkgs.alsa-utils}/bin/aplay -l | grep -i "essx8336" | head -n1 | cut -d' ' -f2 | tr -d ':')
      if [ -z "$CARD_ID" ]; then CARD_ID="0"; fi # 找不到则默认 0
  
      # 强制开启所有可能被静音的通道
      ${pkgs.alsa-utils}/bin/amixer -c $CARD_ID sset 'Left Headphone Mixer Left DAC' on || true
      ${pkgs.alsa-utils}/bin/amixer -c $CARD_ID sset 'Right Headphone Mixer Right DAC' on || true
      ${pkgs.alsa-utils}/bin/amixer -c $CARD_ID sset 'Speaker' on || true
      ${pkgs.alsa-utils}/bin/amixer -c $CARD_ID sset 'Headphone' on || true
      ${pkgs.alsa-utils}/bin/amixer -c $CARD_ID sset 'DAC' 100% || true
      ${pkgs.alsa-utils}/bin/amixer -c $CARD_ID sset 'Output System Free' on || true
    '';
  };
}
