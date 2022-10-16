wget https://down.gloriousdays.pw/Fonts/Consolas.zip
unzip Consolas.zip
mkdir ~/.fonts
cp consola*.ttf ~/.fonts
cd ~/.fonts
mkfontscale
mkfontdir
fc-cache -fv ~/.fonts
