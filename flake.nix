{
  description = "maorila NixOS Flake configuration";

  inputs = {
    # 🌟 主力：切换为 unstable 分支
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # 🌟 替补：保留 25.11 稳定版备用
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    # Home Manager 也要跟着主力走（使用 master 分支匹配 unstable）
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # 新增 disko
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # 引入 Noctalia 的 Flake 源
    noctalia.url = "github:noctalia-dev/noctalia-shell";

    # 🚨 原汁原味的官方上游，不加任何修改
    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 🌟 新增：直接作为独立 input 引入你自己的 NUR 仓库
    my-nur = {
      url = "github:teformel/nur-packages"; # 请确保用户名正确
      # 让你的仓库使用系统当前的 nixpkgs 版本进行构建，避免重复下载依赖
      inputs.nixpkgs.follows = "nixpkgs"; 
    };
  };

  # 这是你的施工图纸：教 Nix 如何组装系统
  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, disko, ... }@inputs: {
    nixosConfigurations = {
      # 🚨 重要：请把这里的 "nixos" 替换成你真实的电脑主机名！
      "nixos" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # 将 inputs 传递给所有的 module，这一步非常关键
        specialArgs = { inherit inputs; }; 
        modules = [
          # 🌟 新增：注入一个 overlay，把稳定版的包挂载到 pkgs.stable 上
          ({ config, pkgs, ... }: {
            nixpkgs.overlays = [
              (final: prev: {
                stable = import nixpkgs-stable {
                  system = prev.system;
                  config.allowUnfree = true; # 如果你需要非自由软件
                };
              })
            ];
          })
          
          # 导入你原本的硬件配置
          ./configuration.nix
          
          disko.nixosModules.disko # 🌟 加载模块
          ./disko-config.nix       # 🌟 加载刚才写的分区配置
          
          # 🌟 新增：将 Home Manager 作为系统模块加载
          home-manager.nixosModules.home-manager
          {
            # 告诉 Home Manager 使用系统的包管理器，避免下载两份相同的软件
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # 告诉系统：maorila 这个用户的家目录，由 ./home.nix 这个文件来管理
            home-manager.users.maorila = import ./home.nix;
          }

          ({ pkgs, ... }: {
            environment.systemPackages = [
              # 🌟 移除本地的 callPackage，改为从你的 Flake input 中拉取
              # 由于你的仓库是通过 flake-parts/templates 构建的，结构是 packages.<架构>.<包名>
              inputs.my-nur.packages.${pkgs.system}.ww-manager

              # 💡 用法示例：
              # 这里的默认包来自 unstable
              # pkgs.git 
                           
              # 如果某个软件在 unstable 坏了，你可以这样调用 25.11 的版本：
              # pkgs.stable.git
            ];
          })
        ];
      };
    };
  };
}
