{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/sda"; 
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # 1. ESP 分区 (UEFI 引导必须)
            # 大小建议 1G 比较充容，文件系统必须是 vfat
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                # 建议加上 umask 权限控制
                mountOptions = [ "umask=0077" ];
              };
            };
            # 2. Btrfs 主分区
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; 
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}

