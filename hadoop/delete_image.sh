#!/bin/bash
docker images -a | grep 'ruteng.*hadoop'
if [ $? -eq 0 ]
then
	docker rmi -f ruteng/ubuntu_1604:hadoop
fi
