#!/bin/bash
# run-gui-docker.sh
# 自动启动或进入 GUI Docker 容器

# 容器名称（可自定义）
CONTAINER_NAME="cartographer-gui"
IMAGE_NAME="cartographer-base-gui:latest"

# 检测 DISPLAY
DISPLAY_NUM=${DISPLAY:-:0}

# 给当前用户授权访问 X11
echo "授权当前用户访问 X11..."
xhost +SI:localuser:$(whoami) >/dev/null

# 检查容器是否已存在
EXISTING_CONTAINER=$(docker ps -a --filter "name=^/${CONTAINER_NAME}$" --format "{{.Names}}")

if [ "$EXISTING_CONTAINER" == "$CONTAINER_NAME" ]; then
    # 如果容器存在，直接进入
    RUNNING=$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME)
    if [ "$RUNNING" == "true" ]; then
        echo "容器已在运行，直接进入..."
        docker exec -it $CONTAINER_NAME bash
    else
        echo "容器存在但未运行，启动容器..."
        docker start -ai $CONTAINER_NAME
    fi
else
    # 容器不存在，创建新容器
    echo "创建并启动新容器..."
    docker run -it --name $CONTAINER_NAME \
        --net=host \
        -e DISPLAY=$DISPLAY_NUM \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        $IMAGE_NAME
fi

# 容器退出后撤销 X11 授权
echo "撤销 X11访问授权..."
xhost -SI:localuser:$(whoami) >/dev/null

