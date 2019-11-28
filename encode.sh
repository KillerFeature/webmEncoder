#!/bin/bash

# source  : https://developer.mozilla.org/en-US/docs/Web/HTML/DASH_Adaptive_Streaming_for_HTML_5_Video

filename=$(basename "$1")

filename="${filename%.*}"
dir=$(dirname "$1")

./ffmpeg -i $1 -vn -acodec libvorbis -ab 128k -dash 1 $dir/$filename"_audio.webm"

./ffmpeg -i $1 -threads 8 -c:v libvpx-vp9 -keyint_min 150 -g 150 -tile-columns 4 -frame-parallel 1  -f webm -dash 1 \
-an -vf scale=160:90 -b:v 250k -dash 1 $dir/$filename"_160x90_250k.webm" \
-an -vf scale=320:180 -b:v 500k -dash 1 $dir/$filename"_320x180_500k.webm" \
-an -vf scale=640:360 -b:v 750k -dash 1 $dir/$filename"_640x360_750k.webm" \
-an -vf scale=640:360 -b:v 1000k -dash 1 $dir/$filename"_640x360_1000k.webm" \
-an -vf scale=1280:720 -b:v 1500k -dash 1 $dir/$filename"_1280x720_1500k.webm" \
-an -vf scale=1920:1080 -b:v 2500k -dash 1 $dir/$filename"_1920x1080_2500k.webm" \
-an -vf scale=1920:1080 -b:v 5000k -dash 1 $dir/$filename"_1920x1080_5000k.webm" \
-an -vf scale=1920:1080 -b:v 10000k -dash 1 $dir/$filename"_1920x1080_10000k.webm"


./ffmpeg \
  -f webm_dash_manifest -i $dir/$filename"_160x90_250k.webm" \
  -f webm_dash_manifest -i $dir/$filename"_320x180_500k.webm" \
  -f webm_dash_manifest -i $dir/$filename"_640x360_750k.webm" \
  -f webm_dash_manifest -i $dir/$filename"_1280x720_1500k.webm" \
  -f webm_dash_manifest -i $dir/$filename"_1920x1080_2500k.webm" \
  -f webm_dash_manifest -i $dir/$filename"_1920x1080_5000k.webm" \
  -f webm_dash_manifest -i $dir/$filename"_1920x1080_10000k.webm" \
  -f webm_dash_manifest -i $dir/$filename"_audio.webm" \
  -c copy \
  -map 0 -map 1 -map 2 -map 3 -map 4 \
  -f webm_dash_manifest \
  -adaptation_sets "id=0,streams=0,1,2,3 id=1,streams=4" \
  $dir/$filename"_manifest.mpd"

echo "<html><body><video><source src='$filename"_manifest.mpd"'><source src='$filename".webm"'>Your browser does not support the video tag.</video></body></html>" >> $dir/index.html
