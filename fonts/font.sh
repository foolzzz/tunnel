# wget https://down.gloriousdays.pw/Fonts/Consolas.zip
unzip Consolas.zip
sudo mkdir -p /usr/share/fonts/consolas
sudo cp consola*.ttf /usr/share/fonts/consolas/
sudo chmod 644 /usr/share/fonts/consolas/consola*.ttf
cd /usr/share/fonts/consolas
sudo mkfontscale && sudo mkfontdir && sudo fc-cache -fv
