{ pkgs, ... }:

{
  # 安装 fastfetch
  home.packages = with pkgs; [ fastfetch ];

  # 生成配置文件
  xdg.configFile."fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": {
        "type": "nixos",
        "padding": {
          "top": 2
        }
      },
      "display": {
        "separator": " "
      },
      "modules": [
        // ─── Title ───
        {
            "type": "title",
            "format": "{user}@{host-name}"
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