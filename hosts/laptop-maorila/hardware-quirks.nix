# modules/hardware-quirks.nix
{ config, pkgs, ... }:

{
  # === 1. 内核与固件 ===
  boot.kernelParams = [ 
    "snd_intel_dspcfg.dsp_driver=3" # 1 = HDA, 3 = SOF，显式强制使用 SOF 驱动链路
    "snd_soc_sof_8336.quirk=0x02"   # 华为板子优先尝试 0x02 (Headphone GPIO)，若无效则换为 0x04
    # --- 根治核心：禁用音频节能防止“睡死” ---
    "snd_hda_intel.power_save=0"
    "snd_hda_intel.power_save_controller=N"
  ];

  hardware.enableAllFirmware = true;
  hardware.firmware = [ pkgs.sof-firmware ];

  # === 2. 硬件视频加速 (省电核心) ===
  # 在 Wayland 下硬解视频，大幅降低 CPU 占用和发热
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD (Intel 12代 Iris Xe 首选)
      intel-vaapi-driver # 备用回退
    ];
  };
  environment.variables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  # === 3. 🔋 现代电源与功耗控制栈 ===
  powerManagement.enable = true;
  powerManagement.powertop.enable = false;

  # 启用 UPower (电量状态读取)
  services.upower.enable = true;
  # 禁用默认的 PPD，给 auto-cpufreq 让路
  services.power-profiles-daemon.enable = false;

  # 🌟 开启 Intel 专属温控守护进程（防过热降频）
  services.thermald.enable = true;

  # 🌟 开启自动频率调度神器
  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    # 🔋 拔电状态（电池模式）
    battery = {
      governor = "powersave";   
      turbo = "never";          
    };
    
    # 🔌 插电状态（日常平衡模式）
    charger = {
      governor = "powersave"; 
      turbo = "auto";           
    };
  };

  # === 4. 蓝牙服务 ===
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # === 5. 音频服务及修复脚本 ===
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # 禁用 WirePlumber 的节点挂起功能，防止没声音时声卡休眠睡死
    wireplumber.extraConfig = {
      "10-disable-suspend" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "node.name" = "~alsa_output.*"; }
            ];
            actions = {
              update-props = {
                "session.suspend-on-idle" = false;
              };
            };
          }
        ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    alsa-ucm-conf
    alsa-utils
    pavucontrol
    wireplumber 
  ];

  # 🔊 声明式音频修复 (Sof-Essx8336)
  systemd.services.fix-sof-sound = {
    description = "Unmute sof-essx8336 channels on boot";
    # 🚨 修复：去掉了 pipewire.service，仅依赖底层硬件初始化完成
    after = [ "sound.target" "alsa-restore.service" ]; 
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
      if [ -z "$CARD_ID" ]; then CARD_ID="0"; fi 
  
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
