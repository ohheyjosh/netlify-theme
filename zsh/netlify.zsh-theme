# -*- mode: sh; -*-

# Netlify Theme v1.0.0
#
# https://github.com/ohheyjosh/netlify-theme
#
# Copyright 2020, All rights reserved
#
# Code licensed under the MIT license
#
# @author Josh Barnett <oh@heyjo.sh>

# Initialization {{{
source ${0:A:h}/lib/async.zsh
autoload -Uz add-zsh-hook
setopt PROMPT_SUBST
async_init
# }}}

# Options {{{
# Set to 1 to show the date
NETLIFY_DISPLAY_TIME=${NETLIFY_DISPLAY_TIME:-0}

# Set to 1 to show the 'context' segment
NETLIFY_DISPLAY_CONTEXT=${NETLIFY_DISPLAY_CONTEXT:-0}

# Changes the arrow icon
NETLIFY_ARROW_ICON=${NETLIFY_ARROW_ICON:-➜ }

# function to detect if git has support for --no-optional-locks
netlify_test_git_optional_lock() {
  local git_version=${DEBUG_OVERRIDE_V:-"$(git version | cut -d' ' -f3)"}
  local git_version="$(git version | cut -d' ' -f3)"
  # test for git versions < 2.14.0
  case "$git_version" in
    [0-1].*)
      echo 0
      return 1
      ;;
    2.[0-9].*)
      echo 0
      return 1
      ;;
    2.1[0-3].*)
      echo 0
      return 1
      ;;
  esac

  # if version > 2.14.0 return true
  echo 1
}

# use --no-optional-locks flag on git
NETLIFY_GIT_NOLOCK=${NETLIFY_GIT_NOLOCK:-$(netlify_test_git_optional_lock)}
# }}}

# Status segment {{{
PROMPT='%(?:%F{cyan}:%F{magenta})${NETLIFY_ARROW_ICON}'
# }}}

# Time segment {{{
netlify_time_segment() {
  if (( NETLIFY_DISPLAY_TIME )); then
    if [[ -z "$TIME_FORMAT" ]]; then
      TIME_FORMAT="%k:M"

      # check if locale uses AM and PM
      if ! locale -ck LC_TIME | grep 'am_pm=";"'; then
        TIME_FORMAT="%l:%M%p"
      fi
    fi

    print -P "%D{$TIME_FORMAT}"
  fi
}

PROMPT+='%F{cyan}%B$(netlify_time_segment) '
# }}}

# User context segment {{{
netlify_context() {
  if (( NETLIFY_DISPLAY_CONTEXT )); then
    if [[ -n "${SSH_CONNECTION-}${SSH_CLIENT-}${SSH_TTY-}" ]] || (( EUID == 0 )); then
      echo '%n@%m '
    else
      echo '%n '
    fi
  fi
}

PROMPT+='%F{magenta}%B$(netlify_context)'
# }}}

# Directory segment {{{
PROMPT+='%F{cyan}%B%c '
# }}}

# Async git segment {{{

netlify_git_status() {
  cd "$1"

  local ref branch lockflag

  (( NETLIFY_GIT_NOLOCK )) && lockflag="--no-optional-locks"

  ref=$(=git $lockflag symbolic-ref --quiet HEAD 2>/tmp/git-errors)

  case $? in
    0)   ;;
    128) return ;;
    *)   ref=$(=git $lockflag rev-parse --short HEAD 2>/tmp/git-errors) || return ;;
  esac

  branch=${ref#refs/heads/}

  if [[ -n $branch ]]; then
    echo -n "${ZSH_THEME_GIT_PROMPT_PREFIX}${branch}"

    local git_status icon
    git_status="$(LC_ALL=C =git $lockflag status 2>&1)"

    if [[ "$git_status" =~ 'new file:|deleted:|modified:|renamed:|Untracked files:' ]]; then
      echo -n "$ZSH_THEME_GIT_PROMPT_DIRTY"
    else
      echo -n "$ZSH_THEME_GIT_PROMPT_CLEAN"
    fi

    echo -n "$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}

netlify_git_callback() {
  NETLIFY_GIT_STATUS="$3"
  zle && zle reset-prompt
  async_stop_worker netlify_git_worker netlify_git_status "$(pwd)"
}

netlify_git_async() {
  async_start_worker netlify_git_worker -n
  async_register_callback netlify_git_worker netlify_git_callback
  async_job netlify_git_worker netlify_git_status "$(pwd)"
}

precmd() {
  netlify_git_async
}

PROMPT+='$NETLIFY_GIT_STATUS'

ZSH_THEME_GIT_PROMPT_CLEAN=") %F{cyan}%B✔ "
ZSH_THEME_GIT_PROMPT_DIRTY=") %F{magenta}%B✗ "
ZSH_THEME_GIT_PROMPT_PREFIX="%F{cyan}%B("
ZSH_THEME_GIT_PROMPT_SUFFIX="%f%b"
# }}}

# Ensure effects are reset
PROMPT+='%f%b'
