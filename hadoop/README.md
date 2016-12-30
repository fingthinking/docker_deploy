## 使用说明
---
1. 下载share目录下的Hadoop-2.7.3.tar.gz放在该文件夹下

运行下面命令安装并创建Hadoop集群
```sh
./install_hadoop.sh [slave_num默认3] [block_num默认为3] [has_master默认Y] [share_file默认共享文件夹] [image_name默认ruteng/ubuntu_1604:hadoop]
```
以上参数不可隔断设置,如果要设置第3位的,则必须提供之前的参数
- slave_num: 为集群中slave的数量
- block_num: 为hdfs块的备份数量,不得大于slave_num
- has_master: 为master节点是否也是slave
- share_file: 为docker容器的共享文件夹挂在到/mnt下面,方便共享文件操作
- image_name: 为创建容器的基础镜像

运行该命令期间如果不存在image_name的镜像,则会自动根据Dockerfile构建

2. config文件夹下为Hadoop的配置文件,其中slaves和hdfs会根据slave_num和block_num动态调整
