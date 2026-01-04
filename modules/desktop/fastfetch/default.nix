{ pkgs, ... }:

{
  home.packages = with pkgs; [ fastfetch ];

  xdg.configFile."fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": {
        "source": "nixos_small",  // ✨ 改用小 Logo，更优雅
        "padding": {
          "top": 1,
          "left": 2   // 给左边一点留白，让它居中一点
        }
      },
      "display": {
        "separator": " "
      },
      "modules": [
        // ─── Title ───
        {
            "type": "title",
            "format": "{1}@{2}"  // ✨ 修复：使用 {1} (用户) 和 {2} (主机)
        },
        // ─── System Info ───
        {
            "type": "os",
            "key": "╭─ ",
            "keyColor": "blue"
        },
        {
            "type": "kernel",
            "key": "├─ ",
            "keyColor": "blue"
        },
        {
            "type": "packages",
            "key": "├─󰏖 ",
            "keyColor": "blue"
        },
        {
            "type": "uptime",
            "key": "╰─󰅐 ",
            "keyColor": "blue"
        },
        
        "break",
        
        // ─── Desktop Environment ───
        {
            "type": "shell",
            "key": "╭─ ",
            "keyColor": "yellow"
        },
        {
            "type": "terminal",
            "key": "├─ ",
            "keyColor": "yellow"
        },
        {
            "type": "wm",
            "key": "╰─ ",
            "keyColor": "yellow"
        },

        "break",

        // ─── Hardware ───
        {
            "type": "host",
            "key": "╭─󰌢 ",
            "keyColor": "green"
        },
        {
            "type": "cpu",
            "key": "├─󰻠 ",
            "keyColor": "green"
        },
        {
            "type": "gpu",
            "key": "├─󰍛 ",
            "keyColor": "green"
        },
        {
            "type": "memory",
            "key": "├─󰑭 ",
            "keyColor": "green"
        },
        {
            "type": "disk",
            "key": "├─ ",
            "keyColor": "green"
        },
        {
            "type": "display",
            "key": "├─󰍹 ",
            "keyColor": "green"
        },
        {
            "type": "sound",
            "key": "╰─ ",
            "keyColor": "green"
        },
        
        "break",
        "colors"
      ]
    }
  '';
}