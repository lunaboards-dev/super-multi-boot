#!/bin/bash
echo "may god help us" 1>&2
luacomp -mluamin src/init.lua | lua zip.lua > bios.bin
#luacomp src/init.lua | lua zip.lua > bios.bin
luacomp src/init.lua > debug.lua