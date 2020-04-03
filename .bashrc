# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

#path
export PATH=$PATH:/usr/local/bin/jdk1.8.0_121/bin
export PATH=$PATH:/usr/local/MATLAB/R2016a/bin
export PATH=$PATH:/usr/lib/google-cloud-sdk/bin
export PATH=$PATH:~/.local/bin
export PATH=$PATH:~/bin

# NFS-specific paths

[ -d '/mnt/j/local/bin' ] && export PATH=$PATH:/mnt/j/local/bin
[ -d '/mnt/j/local/bin/MATLAB/R2016a/bin' ] && export PATH=$PATH:/mnt/j/local/bin/MATLAB/R2016a/bin
[ -d '/mnt/j/local/include' ] && export CPATH=$CPATH:/mnt/j/local/include
[ -d '/mnt/j/local/lib' ] && export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/mnt/j/local/lib
[ -d '/mnt/j/local/miniconda3/bin' ] && export PATH=$PATH:/mnt/j/local/miniconda3/bin

# Slurm path
[ -d '/mnt/j/proj/cloud/slurm/conf/' ] && export SLURM_CONF=/mnt/j/proj/cloud/slurm/conf/slurm.conf

# Java paths
export JAVA_HOME=/usr/local/bin/jdk1.8.0_121/

#from Broad server:
export EDITOR=vim
export VISUAL=$EDITOR
export EXINIT="set ai aw sm"
export FCINIT vim
export PAGER=less
export LESS=-ceR
export MAIL=/usr/spool/mail/$USER
export MAILCHECK=30
export MAILFILE=$MAIL
export PRINTER=lw

alias ls='ls -Ch --color=auto'
alias grep='grep --color=auto'
alias awkt="awk -F'\t'" 
alias columnt="column -tn -s$'\t'" 
alias hnum="tr '\t' '\n' | nl"
alias rp='realpath'
alias rm='rm -i'
alias mv='mv -i'
alias vi='vim'
alias matlab='matlab -nodesktop'
alias xtitle='echo -n "]0;\!*"'
alias resetw='kill -WINCH $$'
alias hgit='git --git-dir ~/.hesshome/.git --work-tree=$HOME'

#TODO: add conditional around these to ensure they're necessary
alias python='python3'
alias pip='pip3'
alias ipython='ipython3'

hexdumpc () {
	hexdump -C $1 | sed 's/|.*$//'
}

#
# VNC stuff

vncstart () {
	[ "$#" -ne 3 ] && { echo "Usage: vncstart <session> <resolution> <port>"; return; }
	/opt/TurboVNC/bin/vncserver :$1 -depth 24 -geometry $2 -rfbauth ~/.vnc/passwd -rfbport $3 -interframe &
}

x11vncstart () {
	[ "$#" -ne 3 ] && { echo "Usage: x11vncstart <session> <resolution> <port>"; return; }
	Xvfb :$1 -screen 0 ${2}x16 &
	x11vnc -display :$1 -rfbauth ~/.vnc/passwd -rfbport $3 -shared -forever -xd_mem 10 -xd_area 100 &
}

xps () {
	echo -n $@ | xclip -selection clipboard
}

xp () {
	echo -n $@ | xclip
}

#
# gcloud stuff

# swap boot disk of an instance for a new disk created from some image.
# TODO: add sanity checks
swap_instance_boot_disk () {
	img=$1
	shift
	zone=$2
	shift

	for i in "$@"; do
		gcloud compute disks create ${i}-new --image $img --zone us-east1-d && \
		gcloud compute instances detach-disk $i --disk $i --zone us-east1-d && \
		gcloud compute instances attach-disk $i --disk ${i}-new --zone us-east1-d && \
		gcloud compute disks delete $i --quiet --zone us-east1-d
	done
}

#
# misc. stuff

# ssh and change into CWD.  assumes shared filesystem.
sshc () {
	ssh $@ -t 'cd '`pwd`'; exec $SHELL -l'
}


#
#prompt stuff

PS1='\[\e[0;33m\][\[\e[m\]\u\[\e[0;33m\]@\[\e[m\]\h \[\e[0;35m\]\W\[\e[m\]\[\e[0;33m\]]\[\e[m\]$ '

#
# define ls colors

LS_COLORS='rs=0:di=01;34:ln=01;93:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:';
export LS_COLORS

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

stty -ixon
