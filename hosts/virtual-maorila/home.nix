{ config, pkgs, ... }:

{
  # 注意：这里必须是你真实的用户名和家目录路径
  home.username = "maorila";
  home.homeDirectory = "/home/maorila";

  # 1. 软件安装：这里安装的软件只有 maorila 能用
  home.packages = with pkgs; [
    fastfetch
    # 你可以在这里继续添加你想用的工具，比如 ripgrep, fzf 等
  ];

  programs.eza = {
    enable = true;
    # 是否开启 Git 集成（显示文件是被修改还是新增）
    git = true;
    # 自动开启图标支持（极其绚丽）
    icons = "auto";
  };

  # 明确启用 Bash 管理，这样 Home Manager 会自动把 direnv 注入到你的 .bashrc 中
  programs.bash = {
    enable = true;
    shellAliases = {
      ls = "eza --icons=always --color=always";
      ll = "eza -hl --icons=always --color=always --git"; # 替代 ls -l
      la = "eza -hla --icons=always --color=always --git"; # 替代 ls -la
      tree = "eza --tree --icons=always"; # 甚至可以替代 tree 命令！
    };
  };
 
  programs.direnv = {
    enable = true;
    enableBashIntegration = true; # 明确开启 Bash 支持
    # 这一行极其重要，它是闪电加载的核心（nix-direnv 缓存机制）
    nix-direnv.enable = true; 
  };

  # 3. 开发工具配置：接管 Git
  programs.git = {
  	enable = true;
  	settings.user.email = "maorila@qq.com"; # 换成你真实提交代码的邮箱
  	settings.user.name = "maorila";
  };

  # 🌟 这一行不要改，它与系统版本的含义类似，用于兼容性控制
  home.stateVersion = "25.11"; 

  # 让 Home Manager 能够管理自己
  programs.home-manager.enable = true;
}
