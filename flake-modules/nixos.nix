{ inputs, ... }:

{
  flake = {
    nixosConfigurations = {
      # 🚨 主机名必须与主配置文件中的 networking.hostName 一致
      "Laptop-maorila" = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # 🌟 挂载稳定版 pkgs
          ({ config, pkgs, ... }: {
            nixpkgs.overlays = [
              (final: prev: {
                stable = import inputs.nixpkgs-stable {
                  system = prev.system;
                  config.allowUnfree = true;
                };
              })
              inputs.nix-cachyos-kernel.overlays.default
            ];
          })

          # 🌟 引入主机配置入口
          ../hosts/laptop-maorila/default.nix

          # 🌟 硬盘配置与分区
          inputs.disko.nixosModules.disko
          ../hosts/laptop-maorila/disko-config.nix

          # 🌟 Home Manager 集成
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # 基础的用户配置内联，其他所有应用的具体配置在对应的模块中按功能注入 (Dendritic 模式)
            home-manager.users.maorila = {
              home.username = "maorila";
              home.homeDirectory = "/home/maorila";
              home.stateVersion = "26.05";
              programs.home-manager.enable = true;
            };
          }

        ];
      };
    };
  };
}
