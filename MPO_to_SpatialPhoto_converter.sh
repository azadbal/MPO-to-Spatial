#!/usr/bin/env bash

################################################################################
# MPO -> SBS -> Spatial Script
#
# Usage:
#   ./mpo_to_sbs_and_spatial.sh /path/to/root/MPO
#
# Steps:
#   1) Takes .mpo / .MPO files from /path/to/root/MPO
#   2) Outputs SBS to a sibling folder /path/to/root/SBS
#   3) Converts those SBS images into Spatial format in /path/to/root/Spatial
################################################################################

########################################
# 1) Configuration
########################################

# Absolute path to the StereoAutoAlign utility
STEREOAUTOALIGN_BIN="/Users/azadbalabanian/Desktop/Spatial/utilities/stereoautoalign_030_mac/StereoAutoAlign"

########################################
# 2) Check required tools
########################################

echo "Checking exiftool..."
command -v exiftool >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "ERROR: exiftool is not installed or not in PATH."
    exit 1
fi

echo "Checking StereoAutoAlign..."
if [ ! -x "$STEREOAUTOALIGN_BIN" ]; then
    echo "ERROR: StereoAutoAlign not found or not executable at:"
    echo "       $STEREOAUTOALIGN_BIN"
    exit 1
fi

echo "Checking 'spatial' command..."
command -v spatial >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "ERROR: 'spatial' command not found in PATH."
    echo "Install or add to PATH, or adjust the script if needed."
    exit 1
fi

########################################
# 3) Parse the MPO folder argument
########################################

if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/MPO_folder"
    exit 1
fi

MPO_DIR="$1"

# Validate that the MPO_DIR is indeed a directory
if [ ! -d "$MPO_DIR" ]; then
    echo "ERROR: '$MPO_DIR' is not a valid directory."
    exit 1
fi

# The parent directory of the MPO folder
ROOT_DIR="$(dirname "$MPO_DIR")"

# Output folders for SBS and Spatial
SBS_DIR="$ROOT_DIR/SBS"
SPATIAL_DIR="$ROOT_DIR/Spatial"
mkdir -p "$SBS_DIR" "$SPATIAL_DIR"

########################################
# 4) Convert MPO -> SBS
########################################

echo "===================="
echo "Converting MPO to SBS"
echo "===================="

# Temporary frames
L_TEMP="tmp_mpo_l.jpg"
R_TEMP="tmp_mpo_r.jpg"

# Gather .mpo & .MPO files
mpo_files=( "$MPO_DIR"/*.mpo "$MPO_DIR"/*.MPO )
actual_mpo_files=()

for f in "${mpo_files[@]}"; do
    [ -f "$f" ] && actual_mpo_files+=( "$f" )
done

if [ ${#actual_mpo_files[@]} -eq 0 ]; then
    echo "No MPO files found in $MPO_DIR"
else
    idx=1
    total=${#actual_mpo_files[@]}
    for file in "${actual_mpo_files[@]}"; do
        echo "---------------------------------------------------------"
        echo "[$idx/$total] Processing: $file"
        idx=$((idx + 1))

        # Strip .mpo/.MPO to get a base filename
        tmpname="$(basename "$file" .mpo)"
        base_name="$(basename "$tmpname" .MPO)"

        # Extract left image
        exiftool -trailer:all= "$file" -o "$SBS_DIR/$L_TEMP"
        # Extract right image
        exiftool "$file" -mpimage2 -b > "$SBS_DIR/$R_TEMP"

        # Perform stereo alignment
        "$STEREOAUTOALIGN_BIN" \
            "$SBS_DIR/$L_TEMP" \
            "$SBS_DIR/$R_TEMP" \
            16 \
            "$SBS_DIR/$base_name.jpg"

        # Copy EXIF data from MPO to new SBS
        exiftool \
            -TagsFromFile "$file" \
            -overwrite_original \
            -all:all \
            "$SBS_DIR/$base_name.jpg"

        # Reset orientation tag
        exiftool \
            -Orientation=1 -n -overwrite_original \
            "$SBS_DIR/$base_name.jpg"

        # Clean up temporary images
        rm -f "$SBS_DIR/$L_TEMP" "$SBS_DIR/$R_TEMP"

        echo "SBS image created: $SBS_DIR/$base_name.jpg"
    done
fi

########################################
# 5) Convert SBS -> Spatial
########################################

echo "==========================="
echo "Converting SBS to Spatial"
echo "==========================="

shopt -s nullglob
sbs_jpg_files=( "$SBS_DIR"/*.jpg )
shopt -u nullglob

if [ ${#sbs_jpg_files[@]} -eq 0 ]; then
    echo "No SBS .jpg files found in $SBS_DIR"
else
    count=1
    total_sbs=${#sbs_jpg_files[@]}
    for file in "${sbs_jpg_files[@]}"; do
        echo "---------------------------------------------------------"
        echo "[$count/$total_sbs] Processing: $file"
        count=$((count + 1))

        out_file="$SPATIAL_DIR/$(basename "$file")"

        spatial make \
            -i "$file" \
            -f sbs \
            --cdist 75 \
            --hfov 54 \
            --hadjust 0.00 \
            --primary right \
            -o "$out_file"

        echo "Spatial image created: $out_file"
    done
fi

echo "All Done!"
