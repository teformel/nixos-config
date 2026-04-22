{
  imports = [
    ./gaming.nix          # 🎮 [游戏] Steam, Lutris, ProtonPlus
    ./virt.nix            # 🖥️ [虚拟机] KVM, FreeRDP, WinApps, 大页脚本
    ./desktop.nix         # 🎨 [图形桌面] Niri, SDDM, 字体, UI 包
    ./i18n.nix            # 🌐 [本地化] 中文、时间格式、Fcitx5 输入法
    ./hardware-quirks.nix # 🚑 [硬件特调] Intel 12代参数, SOF 补丁, 蓝牙, 电池管理
  ];
}
