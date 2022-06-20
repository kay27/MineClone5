#!/bin/bash

for name in ./*.tga
do
    convert "$name" "${name%.*}".png

#    Slow and useless:
#    optipng -o7 -zm1-9 "${name%.*}".png

done
