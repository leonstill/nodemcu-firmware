#!/bin/sh
sudo docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware -v `pwd`/lua_leon:/opt/lua marcelstoer/nodemcu-build /bin/bash