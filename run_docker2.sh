#!/bin/bash


XSOCK=/tmp/.X11-unix
XAUTH=$HOME/.Xauthority

docker build -t georgno/sjtu_drone:ros22 -f dos.Dockerfile .

if [ $? -ne 0 ]; then
    exit 1
fi


xhost +local:docker
docker run \
    -it --rm \
    $VOLUMES \
    -v ${XSOCK}:${XSOCK} \
    -v ${XAUTH}:${XAUTH} \
    -e DISPLAY=${DISPLAY} \
    -e XAUTHORITY=${XAUTH} \
    --env=QT_X11_NO_MITSHM=1 \
    --privileged \
    --net=host \
    --name="sjtu_drone" \
    georgno/sjtu_drone:ros22
xhost -local:docker
