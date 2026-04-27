{ config, pkgs, ... }:

{
  # 注意：这里必须是你真实的用户名和家目录路径
  home.username = "maorila";
  home.homeDirectory = "/home/maorila";

  # 1. 软件安装：这里安装的软件只有 maorila 能用
  home.packages = with pkgs; [
    fastfetch
    pkgs.go-musicfox
    pkgs.cava
  ];

  programs.bottom.enable = true;

  programs.eza = {
    enable = true;
    # 是否开启 Git 集成（显示文件是被修改还是新增）
    git = true;
    # 自动开启图标支持（极其绚丽）
    icons = "auto";
    #enableBashIntegration = false;
  };

  # 明确启用 Bash 管理，这样 Home Manager 会自动把 direnv 注入到你的 .bashrc 中
  programs.bash = {
    enable = true;
  };

  # 🌟 新增：让 Home Manager 接管 Fish 的配置
  programs.fish = {
    enable = true;
    # 你可以在这里顺手配几个日常缩写（可选）
    shellAliases = {
      #ls = "eza";
      #ll = "eza -l";
      #la = "eza -la";
    };
  };  
 
  programs.direnv = {
    enable = true;
    enableBashIntegration = true; # 明确开启 Bash 支持
    enableFishIntegration = true; # 🌟 新增：让闪电加载环境在 Fish 里也能生效！
    # 这一行极其重要，它是闪电加载的核心（nix-direnv 缓存机制）
    nix-direnv.enable = true; 
  };

  # 3. 开发工具配置：接管 Git
  programs.git = {
  	enable = true;
  	settings.user.email = "maorila@qq.com"; # 换成你真实提交代码的邮箱
  	settings.user.name = "maorila";
  };

  # 📥 aria2 后台下载服务
  programs.aria2 = {
    enable = true;
    # 核心配置：开启 RPC 接口
    settings = {
      dir = "${config.home.homeDirectory}/Downloads";
      enable-rpc = true;
      rpc-listen-all = true;
      max-connection-per-server = 16;
      rpc-allow-origin-all = true;
      # 如果你担心安全，可以加个 token，否则留空
      # rpc-secret = "your_token_here";
      # 性能优化
      continue = true;           # 断点续传
      split = 10;
      min-split-size = "10M";
      # 增加 Tracker 列表（这里建议去 github 找最新的列表，或者加一行静态的）
      bt-tracker = "udp://tracker.opentrackr.org:1337/announce,udp://tracker.openbittorrent.com:6969/announce";
    };
  };
  # 🚀 让 Aria2 读取上面生成的配置，并作为后台常驻进程运行
  systemd.user.services.aria2 = {
    Unit = {
      Description = "Aria2c download manager";
      After = [ "network.target" ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      # 🚨 核心修改：去掉 -D，并明确指定配置文件路径
      # %h 在 Systemd 里代表当前用户的家目录 (即 /home/maorila)
      ExecStart = "${pkgs.aria2}/bin/aria2c --conf-path=%h/.config/aria2/aria2.conf"; 
      Restart = "on-failure";
    };
  };

  services.udiskie = {
    enable = true;
    tray = "always"; # 对应你的 -t 参数
  };

  programs.obs-studio = {
    enable = true;
    # Niri 环境下不需要 wlrobs 插件，OBS 30+ 原生支持 PipeWire
    # 如果需要高级音频处理或特效，可以按需添加其它插件
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
    ];
  };

  # 🌟 这一行不要改，它与系统版本的含义类似，用于兼容性控制
  home.stateVersion = "25.11"; 

  # 让 Home Manager 能够管理自己
  programs.home-manager.enable = true;
}
