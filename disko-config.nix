{
  disko.devices = {
    disk = {
      main = {
        # 1. 替换为你的 NVMe 硬盘路径
        device = "/dev/nvme0n1"; 
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # ESP 分区 (UEFI 引导)
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            # Swap 分区 (用于系统休眠 Suspend-to-Disk)
            swap = {
              # 注意：休眠需要将内存数据完整写入硬盘。
              # 请将此处的大小修改为【大于等于你电脑的物理内存大小】（如 16G 内存建议设为 18G 或 20G）
              size = "20G"; 
              content = {
                type = "swap";
                # 关键参数：告诉 Disko 这个分区用于休眠，它会自动在生成配置时注入 boot.resumeDevice
                resumeDevice = true; 
              };
            };

            # Btrfs 主分区
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; 
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    # 增加了针对 NVMe/SSD 的常用优化参数：
                    # ssd: 固态硬盘模式
                    # discard=async: 异步 TRIM 回收空间，延长硬盘寿命且不卡顿
                    # space_cache=v2: 加快挂载和空间缓存速度
                    mountOptions = [ "compress=zstd" "noatime" "ssd" "discard=async" "space_cache=v2" ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" "noatime" "ssd" "discard=async" "space_cache=v2" ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" "ssd" "discard=async" "space_cache=v2" ];
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

