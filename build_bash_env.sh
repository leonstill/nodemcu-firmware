#!/bin/sh

usage() 
{
    echo "Usage: ./build_bash_env.sh <help|build|client|lfs-image> [relative path]"
    exit 1
}

# 编译firmware
[ "$1" = "build" ] && {
    sudo docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware  \
        marcelstoer/nodemcu-build build
    exit $?
}
lua_dir=`pwd`/${2:-"lua_leon"}
# 编译lsf image
[ "$1" = "lfs-image" ] && {
    sudo docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware -v $lua_dir:/opt/lua \
        marcelstoer/nodemcu-build lfs-image
    exit $?
}
# 直接进入bashs
[ "$1" = "client" ] && {
    sudo docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware -v $lua_dir:/opt/lua \
        marcelstoer/nodemcu-build /bin/bash
    exit $?
}

usage