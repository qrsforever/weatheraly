#!/bin/bash

__ssh_conf() 
{
    # node0 是host主机， not虚拟机
    # vagrant up node1 node2 node3 node4 node5 之后

    user=$USER
    ssh node0 cat /home/$user/.ssh/id_rsa.pub >  authorized_keys 
    ssh node1 cat /home/$user/.ssh/id_rsa.pub >> authorized_keys 
    ssh node2 cat /home/$user/.ssh/id_rsa.pub >> authorized_keys 
    ssh node3 cat /home/$user/.ssh/id_rsa.pub >> authorized_keys 
    ssh node4 cat /home/$user/.ssh/id_rsa.pub >> authorized_keys 
    ssh node5 cat /home/$user/.ssh/id_rsa.pub >> authorized_keys 

    # cat authorized_keys >> ~/.ssh/authorized_keys

    scp -r authorized_keys node1:/home/lidong/.ssh
    scp -r authorized_keys node2:/home/lidong/.ssh
    scp -r authorized_keys node3:/home/lidong/.ssh
    scp -r authorized_keys node4:/home/lidong/.ssh
    scp -r authorized_keys node5:/home/lidong/.ssh
}

__ssh_conf()
