#通过docker搭建ubuntu:18.04完成Cartographer的安装与使用#  
将工程拉取到本地：  
`git clone https://github.com/tuwu223/Cartographer-docker-18.04.git`  
运行dockerfile创建镜像：  
`cd Cartographer-docker-18.04`  
`docker build -t cartographer-base-gui:latest .`  
给.sh脚本加权：  
`chmmod +x start_cartographer_gui.sh`  
运行脚本(创建容器一次后再次使用此脚本将直接进入容器)：  
`./start_cartographer_gui.sh`  
将 catkin workspace 移到work中：  
`cd /work`  
`mkdir -p catkin_ws/src`  
`cp -r /opt/catkin_ws/src/cartographer_ros /work/catkin_ws/src/`  
`cd /work/catkin_ws`  
`catkin_make`

