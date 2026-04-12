{
  description = "My first NixOS Flake configuration";

  # 这是你的材料供应商：指定使用 25.11 稳定版
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # 🌟 新增：引入 Home Manager 的代码仓库，并保持版本与系统一致
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # 🌟 新增 disko
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # 这是你的施工图纸：教 Nix 如何组装系统
  outputs = { self, nixpkgs, home-manager, disko, ... }@inputs: {
    nixosConfigurations = {
      # 🚨 重要：请把这里的 "nixos" 替换成你真实的电脑主机名！
      "nixos" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko # 🌟 加载模块
          ./disko-config.nix       # 🌟 加载刚才写的分区配置
          # 导入你原本的硬件配置
          ./hardware-configuration.nix
          # 导入你原本的系统配置
          ./configuration.nix
          # 🌟 新增：将 Home Manager 作为系统模块加载
          home-manager.nixosModules.home-manager
          {
            # 告诉 Home Manager 使用系统的包管理器，避免下载两份相同的软件
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
                      
            # 告诉系统：maorila 这个用户的家目录，由 ./home.nix 这个文件来管理
            home-manager.users.maorila = import ./home.nix;
          }
        ];
      };
    };
  };
}
