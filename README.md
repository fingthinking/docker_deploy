# docker_distribute_hadoop
docker分布式部署hadoop

### 文件分析
- authorized_keys.ct: 该文件为image镜像中的ssh授权密钥
- make_contains.sh: 该文件可以在构建好Hadoop镜像之后,用来部署Hadoop集群

1. 在image中镜像的基础上构建Hadoop集群镜像


