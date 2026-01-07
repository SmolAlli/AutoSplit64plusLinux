<h1 align="center"> AutoSplit64+ </h1><br>
<p align="center">
    <img alt="AS64+" title="AS64+" src="resources\gui\icons\as64plus.png" width="256">
</p>

# A fork of Autosplit64Plus
Run ./run.sh to open Autosplit64Plus

## Currently the only capture method that works is through the obs plugin
Find the obs plugin in /obs-plugin/build
take autosplit64plus-framegrabber.so and place into the /usr/lib/obs-plugins directory (if obs is installed system wide)

To compile yourself delete the /build directory and run 
mkdir build && cd ./build
cmake ..
make

