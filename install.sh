sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

git clone https://github.com/import-yuefeng/fonts.git ~/

cd fonts && ./install.sh

cd .. && echo export LC_POWERLINE_FONT=true > .userrc

rm -rf .oh-my-zsh && cp -r oh-my-zsh .oh-my-zsh

chsh -s /bin/zsh

zsh
