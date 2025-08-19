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
将 catkin workspace 移到work中然后进行编译：  
`cd /work`  
`mkdir -p catkin_ws/src`  
`cp -r /opt/catkin_ws/src/cartographer_ros /work/catkin_ws/src/`  
`cd /work/catkin_ws`  
`catkin_make`  
安装完成后source一下：  
`source /work/catkin_ws/devel/setup.bash`  
`echo "source /work/catkin_ws/devel/setup.bash" >> ~/.bashrc`  
`source ~/.bashrc`  
最后在docker容器中安装ros(使用fishros最快):  
`wget http://fishros.com/install -O fishros && . fishros`  
安装好后进行测试：
`wget -P ~/Downloads https://storage.googleapis.com/cartographer-public-data/bags/backpack_2d/cartographer_paper_deutsches_museum.bag`  
`roslaunch cartographer_ros demo_backpack_2d.launch bag_filename:=${HOME}/Downloads/cartographer_paper_deutsches_museum.bag`  
如果出现x11使用不了的情况：
1.ubuntu22.04请注销用户后在登陆页面的右下角切换到Xorg
2.其余版本暂时没有测试。
