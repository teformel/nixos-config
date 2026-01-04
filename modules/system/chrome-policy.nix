{ config, pkgs, ... }:

{
  # === Google Chrome 强制插件策略 ===
  # 这里通过写入系统级 JSON 策略文件，强制 Chrome 加载这些扩展
  # 即使是新创建的用户，打开 Chrome 也会自动带上这些插件
  environment.etc."opt/chrome/policies/managed/extensions.json".text = builtins.toJSON {
    ExtensionSettings = {
      # 1. Bitwarden (密码管理)
      "nngceckbapebfimnlniiiahkandclblb" = {
        installation_mode = "force_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
      };
      # 2. Raindrop.io (书签管理)
      "ldgfbffkinooeloadekpmfoklnobpien" = {
        installation_mode = "force_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
      };
      # 3. 你的另一个扩展
      "fdpohaocaechififmbbbbbknoalclacl" = {
        installation_mode = "force_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
      };
    };
  };
}