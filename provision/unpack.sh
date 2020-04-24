#!/bin/sh
# author: Jennings Zhang <jenni_zh@protonmail.com>
# date: 2020-04-24
# purpose: untar (in parallel) every *.tar.gz
#          in an input directory to output directory

mkdir -p $2

for a in $1/*.tar.gz; do
  tar -zxf $a -C $2 &
done

wait
