#!/usr/bin/env bash

tmux ls &>/dev/null
TMUX_STATUS=$?

get_fzf_prompt() {
	local fzf_prompt
	local fzf_default_prompt='>  '
	if [ $TMUX_STATUS -eq 0 ]; then # tmux is running
		fzf_prompt="$(tmux show -gqv '@t-fzf-prompt')"
	fi
	[ -n "$fzf_prompt" ] && echo "$fzf_prompt" || echo "$fzf_default_prompt"
}

HOME_REPLACER=""                                          # default to a noop
# echo "$HOME" | grep -E "^[a-zA-Z0-9\-_/.@]+$" &>/dev/null # chars safe to use in sed
HOME="/var/www/html/"
HOME_SED_SAFE=$?
if [ $HOME_SED_SAFE -eq 0 ]; then # $HOME should be safe to use in sed
	HOME_REPLACER="s|^$HOME/|~/|"
fi

BORDER_LABEL=" t - smart tmux session manager "
HEADER=" ctrl-s: sessions / ctrl-d: directory"
PROMPT=$(get_fzf_prompt)
SESSION_BIND="ctrl-s:change-prompt(sessions> )+reload(tmux list-sessions -F '#S')"
# ZOXIDE_BIND="ctrl-x:change-prompt(zoxide> )+reload(zoxide query -l | sed -e \"$HOME_REPLACER\")"

if fd --version &>/dev/null; then # fd is installed
	DIR_BIND="ctrl-d:change-prompt(directory> )+reload(cd $HOME && echo $HOME; fd --type d -d 2 --hidden --absolute-path --color never --exclude .git --exclude node_modules --exclude build --exclude .local)"
else # fd is not installed
	DIR_BIND="ctrl-d:change-prompt(directory> )+reload(cd $HOME && find ~+ -type d -name node_modules -prune -o -name .git -prune -o -type d -print)"
fi

get_sessions_by_mru() {
	tmux list-sessions -F '#{session_last_attached} #{session_name}' | sort --numeric-sort --reverse | awk '{print $2}'
}

	if [ "$TMUX" = "" ]; then        # not in tmux
		if [ $TMUX_STATUS -eq 0 ]; then # tmux is running
			RESULT=$(
      (get_sessions_by_mru) | fzf-tmux \
          --bind "$SESSION_BIND" \
					--bind "$DIR_BIND" \
					--border-label "$BORDER_LABEL" \
					--header "$HEADER" \
					--no-sort \
					--prompt "$PROMPT" \
          -p 60%,50% --reverse
			)
		else # tmux is not running
			RESULT=$(
				(sed -e "$HOME_REPLACER") | fzf-tmux \
					--bind "$DIR_BIND" \
					--border-label "$BORDER_LABEL" \
					--header " ctrl-d: directory" \
					--no-sort \
					--prompt "$PROMPT" \
          -p 60%,50% --reverse
			)
		fi
	else # in tmux
		RESULT=$(
			(get_sessions_by_mru && (sed -e "$HOME_REPLACER")) | fzf-tmux \
        --bind "$SESSION_BIND" \
				--bind "$DIR_BIND" \
				--border-label "$BORDER_LABEL" \
				--header "$HEADER" \
				--no-sort \
				--prompt "$PROMPT" \
				-p 60%,50% --reverse
		)
	fi

if [ "$RESULT" = "" ]; then # no result
	exit 0                     # exit silently
fi

if [ $HOME_SED_SAFE -eq 0 ]; then
	RESULT=$(echo "$RESULT" | sed -e "s|^~/|$HOME/|") # get real home path back
fi

# zoxide add "$RESULT" &>/dev/null # add to zoxide database
FOLDER=$(basename "$RESULT")
SESSION_NAME=$(echo "$FOLDER" | tr ' .:' '_')

if [ $TMUX_STATUS -eq 0 ]; then                                 # tmux is running
	SESSION=$(tmux list-sessions -F '#S' | grep "^$SESSION_NAME$") # find existing session
else
	SESSION=""
fi

if [ "$TMUX" = "" ]; then                          # not currently in tmux
	if [ "$SESSION" = "" ]; then                      # session does not exist
    CUSTOM_SESSION_NAME=$(echo "$RESULT" |  awk -F / -v OFS=_ '{ print $(NF-1), $NF }' ) # custom seesion name
		tmux new-session -s "$CUSTOM_SESSION_NAME" -c "$RESULT" # create session and attach
	else                                              # session exists
		tmux attach -t "$SESSION"                        # attach to session
	fi
else                                                  # currently in tmux
	if [ "$SESSION" = "" ]; then                         # session does not exist
    CUSTOM_SESSION_NAME=$(echo "$RESULT" |  awk -F / -v OFS=_ '{ print $(NF-1), $NF }' ) # custom session name
		tmux new-session -d -s "$CUSTOM_SESSION_NAME" -c "$RESULT" # create session
		tmux switch-client -t "$CUSTOM_SESSION_NAME"               # attach to session
	else                                                 # session exists
		tmux switch-client -t "$SESSION"                    # switch to session
	fi
fi
