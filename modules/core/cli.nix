{ config, pkgs, ... }: {
  # 【系统层配置】
  programs.bash.enable = true;
  programs.fish.enable = true;
  
  # 【用户层配置】
  home-manager.users.maorila = {
    home.packages = with pkgs; [ 
      fastfetch 
      neovim
      wget
      curl
      micro
      eza
      git
      htop
      btop
      yazi
      p7zip
      android-tools
      fish
    ];

    programs.bash.enable = true;
    
    programs.fish = {
      enable = true;
    };
    
    programs.eza = {
      enable = true;
      git = true;
      icons = "auto";
    };

    programs.bottom.enable = true;

    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    };

    programs.git = {
      enable = true;
      settings.user.email = "maorila@qq.com";
      settings.user.name = "maorila";
    };
  };
}
