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
export PATH=$PATH:/opt/bin

# NFS-specific paths

[ -d '/mnt/j/local/bin' ] && export PATH=$PATH:/mnt/j/local/bin
[ -d '/mnt/j/local/bin/jvarkit' ] && export PATH=$PATH:/mnt/j/local/bin/jvarkit
[ -d '/mnt/j/local/bin/MATLAB/R2016a/bin' ] && export PATH=$PATH:/mnt/j/local/bin/MATLAB/R2016a/bin
[ -d '/mnt/j/local/include' ] && export CPATH=$CPATH:/mnt/j/local/include
[ -d '/mnt/j/local/lib' ] && export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/mnt/j/local/lib
[ -d '/mnt/j/local/miniconda3/bin' ] && export PATH=$PATH:/mnt/j/local/miniconda3/bin
[ -d '/usr/local/lib' ] && export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

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

# text manipulation aliases
alias awkt="awk -F'\t'" 
alias columnt="column -t -s$'\t'" 
alias hnum="tr '\t' '\n' | nl"
alias cath="tail -n+1"
alias rp='realpath'
alias wdiffc="wdiff -n -w $'\033[30;41m' -x $'\033[0m' -y $'\033[30;42m' -z $'\033[0m'"

# "safe" deletion aliases
alias rm='rm -i'
alias mv='mv -i'

# application aliases
alias vi='vim' 
alias matlab='matlab -nodesktop'

# terminal control aliases
alias xtitle='echo -n "]0;\!*"'
alias resetw='kill -WINCH $$'

# git aliases
alias hgit='git --git-dir ~/.hesshome/.git --work-tree=$HOME'
alias git-graph='git log --all --graph --oneline'
alias gsu='git status -uno'
alias gsd='git status -- .'
alias gca='git commit --amend --no-edit'
alias gds='git diff --staged'
alias gap='git add --patch'
alias gau='git add -u'
alias gdf='git --no-pager diff --stat' # only show files changed between two commits
gsn () {
  cat <(git show --name-only $1)
}

alias samtools_refresh='export GCS_OAUTH_TOKEN=$(gcloud auth application-default print-access-token)'

## Docker aliases

# spin up a Docker image (with some nice defaults) and drop into a shell
dkrr () {
	image=$1
	shift
	flags=$1
	docker run --rm -ti $flags $image /bin/bash
}

# drop into a shell into an already running Docker container
dkre () {
	image=$1
	shift
	flags=$1
	docker exec -ti $flags $image /bin/bash
}

# run arbitrary command in an already running container
dkrx () {
	image=$1
	shift
	cmd=$1
	shift
	flags=$1
	docker exec $flags $image $cmd
}

## Docker/Slurm aliases
for slurm_cmd in sacct sacctmgr salloc sattach sbatch sbcast scancel scontrol \
    scrontab sdiag sinfo sprio squeue sreport srun sshare sstat strigger; do
	eval "function $slurm_cmd () { docker exec wolf $slurm_cmd "'$@'"; }"
done

#TODO: add conditional around these to ensure they're necessary
alias python='python3'
alias pip='pip3'
alias ipython='ipython3'

export PYTHONBREAKPOINT=ipdb.set_trace

hexdumpc () {
	hexdump -C $1 | sed 's/|.*$//'
}

#
# VNC stuff

vncstart () {
	[ "$#" -ne 3 ] && { echo "Usage: vncstart <session> <resolution> <port>"; return; }
	/opt/TurboVNC/bin/vncserver :$1 -depth 24 -geometry $2 $([ -f ~/.vnc/passwd ] && echo -n "-rfbauth ~/.vnc/passwd" || echo -n "-SecurityTypes None") -rfbport $3 -interframe &
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
# AWS stuff

aws_ssh () {
	HOST=$1
	shift
	USER=$1
	shift
	INST=$(aws ec2 describe-instances --filters Name=tag:Name,Values=$HOST --no-paginate --no-cli-pager --query 'Reservations[*].Instances[?PrivateDnsName != ``].PrivateDnsName[]' --output text)
	ssh -i /mnt/efs/efs1/etc/internal.pem $USER@$INST $@
}

#
# misc. stuff

# ssh and change into CWD.  assumes shared filesystem.
sshc () {
	ssh $@ -t 'cd '`pwd`'; exec $SHELL -l'
}


#
# prompt stuff

PROMPT_COMMAND=pc

# formatting characters
ul='\['$(tput smul)'\]'
bd='\['$(tput bold)'\]'
sg='\['$(tput sgr0)'\]'
rv='\['$(tput rev)'\]'

# color cycle
for i in {0..7}; do
	colorcyc[$i]='\['$(tput setaf $i)'\]'
done

# hostname color hash
hostcolor='\['$(tput setaf $(echo -n $HOSTNAME | perl -ne 'foreach (split(//, $_)) { $x += ord($_) }; print $x % 5 + 2'))'\]'

# username color hash
usercolor='\['$(tput setaf $(echo -n $USER | perl -ne 'foreach (split(//, $_)) { $x += ord($_) }; print $x % 5 + 2'))'\]'

# only display username if it's not the default
[ $USER != "jhess" ] && username=$usercolor$USER$sg'@' || username=""

pc () {
	# display exit status if nonzero
	local ec=$?
	[[ $ec != 0 ]] && local exit_code=" $bd$ec$sg" || local exit_code=""

	# display number of background jobs
	local jwc=$(jobs | wc -l)
	[ $jwc -gt 0 ] && local n_jobs=" ${colorcyc[3]}$(jobs | wc -l)$sg" || local n_jobs=""

	# display current git branch if applicable
	local gb=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
	if [ ! -z $gb ]; then
		local git_branch=" ${ul}${gb}${sg}"

		# excised from gitstatus.sh by Alan K. Stebbens <aks@stebbens.org> [http://github.com/aks]

		local num_staged=0
		local num_changed=0
		local num_conflicts=0
		while IFS='' read -r line; do
		  status="${line:0:2}"
		  while [[ -n ${status} ]]; do
			case "${status}" in
			  #two fixed character matches, loop finished
			  U?) ((num_conflicts++)); break;;
			  ?U) ((num_conflicts++)); break;;
			  DD) ((num_conflicts++)); break;;
			  AA) ((num_conflicts++)); break;;
			  #two character matches, first loop
			  ?M) ((num_changed++)) ;;
			  ?D) ((num_changed++)) ;;
			  ?\ ) ;;
			  #single character matches, second loop
			  U) ((num_conflicts++)) ;;
			  \ ) ;;
			  *) ((num_staged++)) ;;
			esac
			status="${status:0:(${#status}-1)}"
		  done
		done < <(git status -uno --porcelain)

		local git_changes=""
		[ $num_staged == 0 ] || git_changes+=${colorcyc[2]}${num_staged}
		[ $num_changed == 0 ] || git_changes+=${colorcyc[1]}${num_changed}
		[ $num_conflicts == 0 ] || git_changes+=${colorcyc[3]}${num_conflicts}

		stash_file=$(git rev-parse --git-dir 2> /dev/null)/logs/refs/stash
		[ -f "$stash_file" ] && local num_stashed=$(wc -l < "$stash_file")
		[ -z $num_stashed ] || git_changes+=${colorcyc[5]}${num_stashed}

		[ -n "$git_changes" ] && git_changes=:$rv$git_changes$sg
	else
		local git_branch=""
		local git_changes=""
	fi

	# display conda/venv environment
	[ ! -z $CONDA_PROMPT_MODIFIER ] && local conda_venv=$CONDA_PROMPT_MODIFIER || local conda_venv=""
	[ ! -z $VIRTUAL_ENV ] && local py_venv="($(basename $VIRTUAL_ENV)) " || local py_venv=""

	PS1=$conda_venv$py_venv$bd${colorcyc[3]}'['$sg$username$hostcolor'\h '${colorcyc[5]}'\W'$sg$git_branch$git_changes$n_jobs$exit_code${colorcyc[3]}$bd']'$sg'$ '
}

#
# define ls colors

LS_COLORS='rs=0:di=01;34:ln=01;93:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:';
export LS_COLORS

#
# disable Ubuntu's inane "command not found" hook
unset command_not_found_handle

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

# If we are running inside X11, export this for snaps to work
[ ! -z $DISPLAY ] && export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

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

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/tmp/google-cloud-sdk/path.bash.inc' ]; then . '/tmp/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/tmp/google-cloud-sdk/completion.bash.inc' ]; then . '/tmp/google-cloud-sdk/completion.bash.inc'; fi

