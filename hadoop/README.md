## 使用说明
---
#### 下载share目录下的Hadoop-2.7.3.tar.gz放在该文件夹下

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

#### config文件夹
为Hadoop的配置文件,其中slaves和hdfs会根据slave_num和block_num动态调整

#### Dockerfile 
该文件为构建docker镜像的文件,请不要单独使用docker build构建

#### authorized_keys.tpl 授权模板文件
该文件为镜像使用ssh的授权文件,会根据这个模板文件和宿主机的上的ssh构建临时授权文件

#### hosts.tpl hosts授权文件
由于docker容器中/etc/hosts文件是通过挂载的方式,每次都可能改变,顾使用该模板文件动态构建hosts文件,然后设置到容器中
原理：使用Dockerfile中的CMD命令,每次启动都重新替换hosts文件

#### delete_contain.sh
删除Hadoop容器

#### delete_images.sh
删除基础镜像

#### install_hadoop.sh
一键部署Hadoop集群的命令

---
在执行完之后,会生成Hadoop集群,可以通过宿主机ssh连接
例: ssh root@hadoop-master即可
进入hadoop-master,运行命令`hdfs namenode -format`
