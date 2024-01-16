#!/bin/bash

source "modules/_util.sh"
source "modules/base.sh"
source "modules/sound.sh"
source "modules/video.sh"

script_dir=$(realpath $(dirname $0))

# Checks if script is being run as root and exits case true
check_root
base_setup
sound_setup
video_setup
