## 使用说明
---
1. 下载share目录下的Hadoop-2.7.3.tar.gz放在该文件夹下

运行下面命令安装并创建Hadoop集群
```sh
./install_hadoop.sh [slave_num默认3] [has_master默认Y] [share_file默认共享文件夹] [image_name默认ruteng/ubuntu_1604:hadoop]
```
以上参数不可隔断设置,如果要设置第3位的,则必须提供之前的参数
