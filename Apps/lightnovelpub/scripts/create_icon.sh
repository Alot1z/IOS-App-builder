#!/bin/bash

# Create a base icon with text and background
magick convert -size 1024x1024 xc:white \
  -fill "#4A90E2" -draw "rectangle 0,0 1024,1024" \
  -fill white \
  -font Arial-Bold -pointsize 200 \
  -gravity center -annotate 0 "LNP" \
  -gravity south -pointsize 100 -annotate +0+100 "Light Novel Pub" \
  "assets/icon.png"

# Make the corners rounded
magick convert "assets/icon.png" \
  \( +clone -alpha extract \
    -draw "fill black polygon 0,0 0,15 15,0 fill white circle 15,15 15,0" \
    \( +clone -flip \) -compose Multiply -composite \
    \( +clone -flop \) -compose Multiply -composite \
  \) -alpha off -compose CopyOpacity -composite "assets/icon.png"
