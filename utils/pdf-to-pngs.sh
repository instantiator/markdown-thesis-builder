#!/bin/sh

brew install ghostscript imagemagick
gs -dNOPAUSE -sDEVICE=png16m -r256 -sOutputFile=page%03d.png $1

for FILENAME in `ls page*.png | sort`; do
  convert $FILENAME -bordercolor white -border 13 \( +clone -background black -shadow 80x3+2+2 \) +swap -background white -layers merge +repage $FILENAME.shadow.png

done
