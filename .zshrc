export LANG=en_US.UTF-8
export ZSH="/Users/julio/.oh-my-zsh"

#
# profile
#

if [ -f $HOME/.profile ]; then
	source $HOME/.profile
fi

#
# auto completion
#

autoload -U compaudit compinit
compinit
source $ZSH/lib/completion.zsh
# source $ZSH/oh-my-zsh.sh

#
# prompt functions
#

username() {
	pad=''
	if [ `whoami` != 'julio' ];then
		echo -n $(whoami)
		pad=' '
	fi

	if [ `hostname` != 'julios-mbp' ]; then
		echo -n '@'$(hostname)
		pad=' '
	fi

	echo -n $pad
}

check_or_num() {
	if [[ $1 -eq 0 ]]; then
		echo ☼
	else
		echo $1
	fi
}

git_prompt() {
	branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
	if [ $? -eq 0 ]; then
		if [[ branch == 'master' ]]; then
			branch=''
		fi

		git_status=$(git status -s)

		echo $git_status | grep -q "^M "
		if [ $? -eq 0 ]; then
			staged="+"
		fi

		echo $git_status | grep -q " M "
		if [ $? -eq 0 ]; then
			mod="M"
		fi

		echo $git_status | grep -q "?? "
		if [ $? -eq 0 ]; then
			new="?"
		fi

		echo $git_status | grep -q "A "
		if [ $? -eq 0 ]; then
			add="+"
		fi

		echo -n ' ' $branch $staged $mod $new $add $(gradient $(git_color))
	fi
}

git_color() {
	git_status=$(git status -s 2> /dev/null)
	if [ $? -ne 0 ]; then
		echo -n ""
	elif [ -z $git_status ]; then
		echo -n green
	else
		echo -n yellow
	fi
}


preexec_timer() {
	timer_var=$SECONDS
}

precmd_timer() {
	if [ $timer_var ]; then
		delta=$(( $SECONDS - $timer_var ))
		export CMD_TIME=$(printf '%02d:%02d' \
			$(( delta / 60 )) $(( delta % 60 )))
		unset timer_var
	else
		export CMD_TIME=''
	fi
}

preexec() {
	preexec_timer
}

precmd() {
	roll_die
	precmd_timer
}

gradient() {
	if [ -z $2 ]; then
		echo -n "%F{$1}%k░%f"
	else
		echo -n "%F{$1}%K{$2}░%f"
	fi
}

kf() {
	echo -n "%K{$1}%F{$2}$3%f"
}

concat() {
	for arg in $@;do
		echo -n $arg
	done
}

roll_die() {
	arr=('⚀' '⚁' '⚂' '⚃' '⚄' '⚅' '💖' '🌞' '🌻' '🌆')
	RANDOM_DIE=${arr[$(jot -r 1 1 10)]}
}

__=' '

set_prompt() {
	setopt prompt_subst

	PROMPT=$(concat \
		$(kf white black '$__ %T $__') \
		$(kf white black $(username)) \
		$(gradient white blue) ' ' $(kf blue black '%3~' ) ' ' \
		'$(gradient blue $(git_color))' \
			$(kf '$(git_color)' black '$(git_prompt)') \
		'%k' ' ☞  ')

	RPROMPT=$(concat \
		$(gradient black) $(kf black white '%(?.$RANDOM_DIE.%F{red}%?%f)') ' ' \
		$(gradient white black) $(kf white black  '${__} 𝜟$CMD_TIME') '%E')
}

set_prompt

#
# key binding
#

export KEYTIMEOUT=50

bindkey -v
bindkey -v jj vi-cmd-mode

bindkey -a '^L' forward-word # [Ctrl-RightArrow] - move forward one word
bindkey -a '^H' backward-word # [Ctrl-LeftArrow] - move backward one word

export EDITOR=vim

# Edit the current command line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey hh edit-command-line

# start typing + [Up-Arrow] - fuzzy find history forward
autoload -U up-line-or-beginning-search
zle -N up-line-or-beginning-search
bindkey -a 'k' up-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search

# start typing + [Down-Arrow] - fuzzy find history backward
autoload -U down-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey -a 'j'  down-line-or-beginning-search
bindkey '^[[B'  down-line-or-beginning-search
