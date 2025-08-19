# -------------------------------
# Ubuntu 18.04 + Cartographer (保留 Cartographer ROS 源码，不编译)
# -------------------------------

FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# 用户和 UID/GID
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000

# -------------------------------
# 1) 安装基础工具与 Cartographer 依赖
# -------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential clang cmake gdb git curl ca-certificates \
    google-mock libboost-all-dev libcairo2-dev libceres-dev \
    libeigen3-dev libgflags-dev libgoogle-glog-dev liblua5.2-dev \
    libsuitesparse-dev lsb-release ninja-build python3-sphinx stow \
    pkg-config python3 python3-pip rsync unzip sudo wget x11-apps \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------
# 2) 创建非 root 用户
# -------------------------------
RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd -m --uid ${USER_UID} --gid ${USER_GID} -s /bin/bash ${USERNAME} && \
    usermod -aG sudo ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# -------------------------------
# 3) 安装 Abseil 与 Protobuf
# -------------------------------
WORKDIR /opt/src

# 3.1 Abseil (COPY 本地源码)
COPY abseil-cpp /opt/src/abseil-cpp
RUN cd /opt/src/abseil-cpp && \
    mkdir build && cd build && \
    cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
      -DCMAKE_INSTALL_PREFIX=/usr/local/stow/absl \
      .. && \
    ninja && ninja install && \
    cd /usr/local/stow && stow absl

# 3.2 Protobuf v3.4.1 (COPY 本地源码)
COPY protobuf /opt/src/protobuf
RUN cd /opt/src/protobuf && \
    mkdir build && cd build && \
    cmake -G Ninja \
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -Dprotobuf_BUILD_TESTS=OFF \
      ../cmake && \
    ninja && ninja install && ldconfig

# -------------------------------
# 4) 安装 Cartographer
# -------------------------------
COPY cartographer /opt/cartographer
RUN cd /opt/cartographer && mkdir build && cd build && \
    cmake -G Ninja -DCMAKE_BUILD_TYPE=Release .. && \
    ninja && CTEST_OUTPUT_ON_FAILURE=1 ninja test && ninja install

# -------------------------------
# 5) 保留 Cartographer ROS 源代码
# -------------------------------
WORKDIR /opt/catkin_ws/src
COPY cartographer_ros /opt/catkin_ws/src/cartographer_ros

# -------------------------------
# 6) 预创建工作目录
# -------------------------------
RUN mkdir -p /work && chown ${USER_UID}:${USER_GID} /work
WORKDIR /work

# -------------------------------
# 7) 设置默认用户 & PATH & DISPLAY
# -------------------------------
USER ${USERNAME}
ENV PATH="/usr/local/bin:/usr/bin:/bin:${PATH}"
# 保留 DISPLAY 变量（运行时 docker run 会覆盖）
ENV DISPLAY=:0
