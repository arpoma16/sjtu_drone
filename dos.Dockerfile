ARG ROS_DISTRO=iron
FROM georgno/sjtu_drone:ros2-${ROS_DISTRO}


ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl gnupg lsb-release


# 🔥 Limpia posibles fuentes conflictivas
RUN rm -f /etc/apt/sources.list.d/ros2.list \
          /etc/apt/sources.list.d/ros2-latest.list \
          /usr/share/keyrings/ros2-latest-archive-keyring.gpg \
          /usr/share/keyrings/ros-archive-keyring.gpg \
          /etc/apt/trusted.gpg.d/ros* \
          /etc/apt/trusted.gpg

# 🗝️ Añade clave actualizada
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc \
    | gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg

# 📦 Añade repositorio ROS 2
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
    http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) main" \
    > /etc/apt/sources.list.d/ros2.list


RUN  apt-get update && \
   apt-get install  -y ros-${ROS_DISTRO}-rosbridge-server 

COPY ./sjtu_drone_description/worlds/playground.world /ros2_ws/src/sjtu_drone_description/worlds/playground.world

RUN apt-get update && \
    /bin/bash -c 'cd /ros2_ws/ \
    && source /opt/ros/${ROS_DISTRO}/setup.bash \
    && rosdep install --from-paths src --ignore-src -r -y \
    && colcon build' && \
    apt-get clean

CMD ["/bin/bash", "-c", "source /opt/ros/${ROS_DISTRO}/setup.bash && source /ros2_ws/install/setup.bash && ros2 launch sjtu_drone_bringup sjtu_drone_bringup.launch.py"]
#cd source /opt/ros/iron/setup.bash
#ros2 topic echo /simple_drone/gps/nav
