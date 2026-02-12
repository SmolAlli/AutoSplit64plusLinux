source .venv/bin/activate

pyinstaller \
--noconfirm \
--name "AutoSplit64plus" \
--splash "resources/gui/icons/icon.png" \
--icon "resources/gui/icons/icon.ico" \
--noconsole \
--clean \
--noupx \
--contents-directory "libraries" \
AutoSplit64.py

cp -r logic dist/AutoSplit64plus/logic
cp -r resources dist/AutoSplit64plus/resources
cp -r routes dist/AutoSplit64plus/routes
cp -r templates dist/AutoSplit64plus/templates
cp defaults.ini dist/AutoSplit64plus/

tar -czvf Autosplit64.tar.gz ./dist/AutoSplit64plus
