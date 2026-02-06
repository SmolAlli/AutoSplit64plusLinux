<h1 align="center">AutoSplit64+ Linux</h1><br>
<p align="center">
    <img alt="AS64+" title="AS64+" src="resources\gui\icons\icon.png" width="256">
</p>

# A badly coded linux fork of Autosplit64Plus
Run ./run.sh to open Autosplit64Plus
# Requirements
Python 3.11 <br />
(AND) <br />
libobs-dev (for the obs plugin)

## Currently the only capture method that works is through the obs plugin
Find the obs plugin in /obs-plugin
take autosplit64plus-framegrabber.so and place into the `/usr/lib/obs-plugins` directory (if obs is installed system wide) or `~/.config/obs-studio/plugins`

To compile yourself delete the /build directory and run <br />
```
mkdir build && cd ./build
cmake ..
make
```
May also need to install `libsimde-dev`

## Building AppImage
To build the AppImage, simply run the build script:
```bash
./build_appimage.sh
```
This will generate `AutoSplit64plus-x86_64.AppImage` in the root directory.

### Using the AppImage
1. Make it executable: `chmod +x AutoSplit64plus-x86_64.AppImage`
2. Run it: `./AutoSplit64plus-x86_64.AppImage`
