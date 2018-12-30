sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

git clone https://github.com/import-yuefeng/fonts.git ~/fonts

cd ~/fonts && ./install.sh

cd ~/ && echo "export LC_POWERLINE_FONT=true; export ZSH=~/.oh-my-zsh;" > .userrc

rm -rf .oh-my-zsh && cp -r oh-my-zsh .oh-my-zsh
cp ~/.oh-my-zsh/templates/zshrc.zsh-yuefeng ~/.zshrc

chsh -s /bin/zsh

source ~/.zshrc

zsh
