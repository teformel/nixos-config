# modules/hardware-quirks.nix
{ config, pkgs, ... }:

{
  # 把内核参数移过来
  boot.kernelParams = [ 
    "snd_intel_dspcfg.dsp_driver=3" # 1 = HDA, 3 = SOF，显式强制使用 SOF 驱动链路
    "snd_soc_sof_8336.quirk=0x20"   # 华为板子优先尝试 0x02 (Headphone GPIO)，若无效则换为 0x04
    # --- 根治核心：禁用音频节能防止“睡死” ---
    "snd_hda_intel.power_save=0"
    "snd_hda_intel.power_save_controller=N"
  ];

  # 固件支持
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

  # === 3. 🔋 现代电源与功耗控制栈 (PPD 方案) ===
  powerManagement.enable = true;
  
  # 开启 Powertop 后台自动调优（将所有空闲总线和设备设为节能状态）
  powerManagement.powertop.enable = false;

  # 开启 Linux 散热守护进程（Intel 笔记本刚需，结合 PPD 动态控制温度墙，防止过热死机或掉帧）
  services.thermald.enable = true;

  # 启用 UPower (电量状态读取) 和 PPD (电源模式调度)
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # 可选：如果希望合上笔记本盖子时直接休眠（Suspend to disk）而不是睡眠（Suspend to RAM）
  # services.logind.lidSwitch = "hibernate"; 

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

    # 3. 根治方案：禁用 WirePlumber 的节点挂起功能
    # 这会防止声卡在无声音输出时自动关闭电源
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

  # 把音频相关的包移过来
  environment.systemPackages = with pkgs; [
    alsa-ucm-conf
    alsa-utils
    # 推荐装这个，方便图形化看哪个通道没开
    pavucontrol
    wireplumber # 方便使用 wpctl 调试
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
