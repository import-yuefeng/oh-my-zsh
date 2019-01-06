# /bin/sh
set -ue

git clone https://github.com/import-yuefeng/fonts.git ~/fonts

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

chmod +x ~/fonts/install.sh && sh -c ~/fonts/install.sh

echo "export LC_POWERLINE_FONT=true; export ZSH=~/.oh-my-zsh;" > ~/.userrc

rm -rf .oh-my-zsh && cp -r ../oh-my-zsh ~/.oh-my-zsh
cp ~/.oh-my-zsh/templates/zshrc.zsh-yuefeng ~/.zshrc

chsh  /bin/zsh

source ~/.zshrc
