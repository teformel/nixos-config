{ pkgs, lib, ... }:

let
  # === 1. 强制安装列表 (删不掉) ===
  forcedExtensions = [
    "nngceckbapebfimnlniiiahkandclblb" # Bitwarden: 必须用！
  ];

  # === 2. 推荐安装列表 (可关闭) ===
  optionalExtensions = [
    "ldgfbffkinooeloadekpmfoklnobpien" # Raindrop: 帮你装好，不用可以关
    "fdpohaocaechififmbbbbbknoalclacl" # 另一个扩展
  ];

  # === 策略生成器 ===
  makePolicy = mode: id: {
    installation_mode = mode;
    update_url = "https://clients2.google.com/service/update2/crx";
  };

  # 分别生成两组配置
  forcedConfig = lib.genAttrs forcedExtensions (makePolicy "force_installed");
  optionalConfig = lib.genAttrs optionalExtensions (makePolicy "normal_installed");

  # ✨ 优雅合并：把两组配置合并成一个大集合
  finalExtensionSettings = forcedConfig // optionalConfig;
in
{
  # ==========================================================
  # 3. 软件安装 (Package)
  #    我们把 home.nix 里的安装代码搬到这里，变成系统级安装
  # ==========================================================
  environment.systemPackages = [
    (google-chrome.override {
      commandLineArgs = builtins.concatStringsSep " " [
        "--ozone-platform=x11"
        # ✨ 这里设置你想要的缩放比例
        # 如果你确实想要 "缩放为 1" (原始大小)，就填 1
        # 如果你觉得 1 太小了，可以填 1.25, 1.5 (配合你的屏幕倍率)
        # 只要这里填了参数，字就是清晰的，不会糊！
        "--force-device-scale-factor=1.5" 
      ];
    })
  ];

  # ==========================================================
  # 4. 策略注入 (Policy)
  #    自动生成 JSON 并写入 /etc
  # ==========================================================
  environment.etc."opt/chrome/policies/managed/extensions.json".text = builtins.toJSON {
    ExtensionSettings = finalExtensionSettings;
  };
}