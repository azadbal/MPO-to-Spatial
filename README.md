# MPO-to-Spatial
Converts Fujifilm MPO stereo photos to Vision Pro Spatial photos 

Note: this works on MacOS only (the main limitation is due to [Spatial Video Tools](https://blog.mikeswanson.com/spatial/)) being MacOS only)

## What it does
This script is made to convert Fujifilm finepix W3 3D camera MPO files to Apple Vision Pro Spatial photos.

It uses:
- Masuji Suto's [StereoAutoAlign](https://stereo.jpn.org/stereoautoalign/index_mace.html) utlity to
	- extract the images from the MPO files
	- align and color match the images (using the L image as ref)
	- export them as SBS files
- and combines it with Mike Swanson's [Spatial Video tool](https://blog.mikeswanson.com/spatial/) to 
	- convert the SBS images to Spatial photos with the correct camera parameters that match the Fujifilm W3 specifications. 

## HOW TO USE
1. install all dependancies (described below)
2. In terminal, call this script and the path to a folder of MPO files
    for example
        `MPO_to_SpatialPhoto_converter.sh "/Users/azadbalabanian/Desktop/Photos/Day1/MPO"`

## Folder structure
The script assumes you have a folder of MPO files in a root directory. It will create converted 3d photos in this format and directory:


* root/
	* MPO (this is where your input images should be)
	* SBS
	* Spatial



## Install Dependancies
1. EXIF tool
2. StereoAutoAlign
3. Spatial Video Toolkit

installation instructions bellow

### 1. Exif Tool
- Download
	- https://exiftool.org/
		- MacOS Package: ExifTool-13.21.pkg (5.2 MB)

- Installation
	- Launch it, you'll likely have a security issue.
		- Go to System Preferences > Privacy and Security > scroll down to "Security" > Exif tool was blocked > "Open Anyway"
	- Verify
		- launch terminal, type
			- `exiftool -h`
		- see if the tool gets called and spits out help info
		- Quit terminal cause it get stuck in wanting some input.

### 2. StereoAutoAlign
Download from: https://stereo.jpn.org/stereoautoalign/index_mace.html

- Install
	- you'll have issues with Mac security stuff so follow these steps.
	- Launch Terminal
		- `sudo xattr -r -d com.apple.quarantine [insert dir to the StereoAutoAlign unix file]`
		- enter your mac password
	- verify that it works by using the sample SBS photo in the folder 
		- Drag StereoAutoAlign to the Terminal, then drag the sbs image, and press Enter to activate it.
- Change StereoAutoAlign location in the script
	- in the `MPO_to_Spatial` file, change the directory of StereoAutoAlign to match wherever the file is in your computer.
	- `STEREOAUTOALIGN_BIN="/Users/azadbalabanian/Desktop/Spatial/utilities/stereoautoalign_030_mac/StereoAutoAlign"`


### 3. Spatial Video Toolkit
Link: https://blog.mikeswanson.com/spatial/

- Install
	- option 1: using homebrew (recommended)
		- `brew install spatial`
			- this what I use and what this "MPO to Spatial script" is written around
- option 2: download zip
	- https://www.mikeswanson.com/spatial/releases/spatial_0.6.2.zip (might be outdated)

