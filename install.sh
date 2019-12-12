#!/bin/bash

# dotfiles deployment file

usage() { 
    echo "Usage: $0 OPTION[S]"
    echo
    echo "OPTIONS are:"
    echo "  -s      change system settings"
    echo "  -p      install packages"
    echo "  -d      install dotfiles"
    exit 1
}

dotfiles() {
    # Git settings
    git config --global core.excludesfile ~/.cvsignore
    git config --global user.name "natl"
    git config --global user.email "natl@users.noreply.github.com"
    git config --global push.default simple
    git config --global alias.hist '!tput rmam; git log --graph --full-history --all --pretty=format:"%Cred%h%Creset %ad %<(40,trunc) %s %C(yellow)%d%Creset %C(bold blue)<%an>%Creset" --date=short; tput smam'
    git config --global alias.co checkout
    git config --global alias.st status
    git config --global alias.wipe '!git add -A && git commit -qm "WIPE SAVEPOINT" && git reset HEAD~1 --hard'
    git config --global init.templatedir '~/.git_template'

    # vim settings
    mkdir -p ~/.vim/tmp

    # install and pull submodules
    git submodule update --init --recursive
    git submodule update --recursive

    # make links from location to dotfiles
    read -p 'old-dotfiles will be overwritten! OK? ' yn
    case $yn in
        [Yy]* ) mv old-dotfiles/.gitignore /tmp/; \
                rm -rf old-dotfiles/; \
                mkdir old-dotfiles/; \
                mv /tmp/.gitignore old-dotfiles/;;
        * ) exit;;
    esac

    for filename in \
        ~/.vimrc \
        ~/.cvsignore \
        ~/.inputrc \
        ~/.vim/pack/git-plugins/start/jedi-vim \
        ~/.vim/pack/git-plugins/start/solarized \
        ~/.vim/pack/git-plugins/start/vim-fugitive \
        ~/.vim/pack/git-plugins/start/vim-unimpaired \
        ~/.vim/pack/git-plugins/start/tagbar \
        ~/.vim/pack/git-plugins/start/tcomment_vim \
        ~/.vim/pack/git-plugins/start/vim-surround \
        ~/.vim/pack/git-plugins/start/supertab \
        ~/.vim/pack/git-plugins/start/ale \
        ~/.bashrc \
        ~/.pythonrc.py \
        ~/.abcde.conf \
        ~/.git_template \
        ;
    do
        if [ -L $filename ]
        then
            rm $filename
        elif [ -a $filename ]
        then
            mv $filename old-dotfiles/
            echo moving ${filename##*/} to old-dotfiles/
        fi
        mkdir -p ${filename%/*}
        ln -s $(pwd)/${filename##*/} ${filename%/*}
    done
}

while getopts "pds" o; do
    case "${o}" in
        s)
            ./system.sh;;
        p)
            ./packages.sh;;
        d)
            dotfiles;;
        *)
            usage
            exit 1;;
    esac
done

if [ $OPTIND -eq 1 ]; then
    usage
fi
