# /bin/sh
set -ue

check_cmd() {
    which $1 > /dev/null 2>&1
}

detect_pkg_tool() {
    check_cmd apt && {
        UPDATE="apt update -q"
        INSTALL="apt install -y"
        REMOVE="apt remove -y"
        return 0
    }

    check_cmd apt-get && {
        UPDATE="apt-get update -q"
        INSTALL="apt-get install -y"
        REMOVE="apt-get remove -y"
        return 0
    }

    check_cmd yum && {
        UPDATE="yum update -yq"
        INSTALL="yum install -y"
        REMOVE="yum "
        PKG_LIBEV="libev-devel"
        PKG_SSL="openssl-devel"
        return 0
    }

    check_cmd pacman && {
        UPDATE="pacman -Sy --noprogressbar"
        INSTALL="pacman -S --noconfirm --noprogressbar"
        REMOVE="pacman -R --noconfirm --noprogressbar"
        PKG_LIBEV="libev"
        PKG_SSL="openssl"
        return 0
    }

    return 1
}

if [[ detect_pkg_tool == 1 ]]; then
    echo 'not support platform'
    echo 'please manual install zsh'
    exit 1
fi

check_cmd zsh || {
    $UPDATE && $INSTALL zsh
}



git clone https://github.com/import-yuefeng/fonts.git ~/fonts

chmod +x ~/fonts/install.sh && sh -c ~/fonts/install.sh

echo "export LC_POWERLINE_FONT=true; export ZSH=~/.oh-my-zsh;" > ~/.userrc


rm -rf .oh-my-zsh && cp -r ../oh-my-zsh ~/.oh-my-zsh
cp ~/.oh-my-zsh/templates/zshrc.zsh-yuefeng ~/.zshrc

chsh  /bin/zsh

source ~/.zshrc
