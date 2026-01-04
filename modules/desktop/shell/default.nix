{ pkgs, ... }:

{
  # === Starship 提示符 (那个漂亮的火箭/箭头) ===
  programs.starship = {
    enable = true;
    # 自定义配置：让它更紧凑
    settings = {
      add_newline = false; # 命令之间不空行
      character = {
        success_symbol = "[➜](bold green)"; # 成功时显示绿色箭头
        error_symbol = "[➜](bold red)";     # 失败时显示红色箭头
      };
    };
  };

  # === Zsh Shell ===
  programs.zsh = {
    enable = true;  # ✨ 这一行会自动安装 zsh 包
    enableCompletion = true; # 启用自动补全
    autosuggestion.enable = true; # 启用“灰色幽灵”建议 (神技！)
    syntaxHighlighting.enable = true; # 启用语法高亮
    
    # 你的别名
    shellAliases = {
      
    };
    
    # 历史记录
    history = {
      size = 10000;
      path = "$HOME/.zsh_history";
    };
  };
}