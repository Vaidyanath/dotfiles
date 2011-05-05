alias py='python'
alias ip='ipython'
alias ls='ls -FG' #Colorize and show folders, symlinks, etc
alias la='ls -la' # List style, show all (hidden)
alias so='source' # Like vim
alias nose='nosetests'
alias cover='nosetests --with-cover --cover-html --cover-package=`basename $PWD` && open cover/index.html'
alias rmpyc='rm *.pyc'
alias ..='cd ..'
alias pu='pushd'
alias po='popd'
alias git='hub'

# Django related aliases
alias djsh='python manage.py shell'
alias djru='python manage.py runserver'
alias djte='python manage.py test --verbosity 0'
alias djtx='python manage.py test --verbosity 0 -x'

# Vendor everything, aka cache gems with project files
# Ref http://ryan.mcgeary.org/2011/02/09/vendor-everything-still-applies/
alias b="bundle"
alias bi="b install --path vendor"
alias bu="b update"
alias be="b exec"
alias binit="bi && b package && echo 'vendor/ruby' >> .gitignore"

# Case insensitive completion
# Add `set completion-ignore-case on` to /etc/inputrc

# Tmux aliases
alias tls="tmux list-sessions"
alias ta="tmux attach"

# Remote hosts => moved to .ssh/config file
# alias webf='ssh nation@nation.webfactional.com'
# alias aws='ssh ubuntu@ec2-50-16-123-42.compute-1.amazonaws.com'

# Git bash completion
source ~/.git-completion.bash

# Easy editing of bashrc
alias ebrc="vim ~/.bashrc"
alias sobrc="source ~/.bashrc"

# TODO Figure out how to highlight from within function. Specifically for
# git PS1 with staged, modified, and untracked as green, red, yellow
PS1='\n\e[33;1m\]$PWD'                # {YELLOW} working dir
PS1+='\e[31;1m\]$(jobcount)'          # {RED} Current background jobs
PS1+='\e[35;1m\]$(dirstack_count)'    # {VIOLET} Dirs in the stack
PS1+='\e[34;1m\]$(git_branch)'        # {BLUE} My fancy git PS1
PS1+='\e[32;1m\]$(git_staged)'        # {GREEN} My fancy git PS1
PS1+='\e[31;1m\]$(git_modified)'      # {RED} My fancy git PS1
PS1+='\e[33;1m\]$(git_untracked)'     # {YELLOW} My fancy git PS1
PS1+='\e[34;1m\]$(git_close_branch)'  # {VIOLET} My fancy git PS1
PS1+='\n\[\e[0m\]$=>'                 # Restore normal color

# List the number of background jobs. See next section for details
function jobcount {
    count=`jobs | wc -l | awk '{print $1}'`
    if [ $count -eq "0" ]; then
        echo ""
    else
        echo " j(+$count)"
    fi
}
function dirstack_count {
    count=`dirs | wc -w | awk '{print $1}'`
    let "count-=1" # Returns current dir in list, so less one
    if [ $count -eq "0" ]; then
        echo ""
    else
        echo " d(+$count)"
    fi
}
function git_branch {
    branch=`__git_ps1 "%s"`
    if [ -z "$branch" ]; then
        echo ""
    else
        echo " ($branch"
    fi
}
function git_staged {
    branch=`__git_ps1 "%s"`
    if [ -z "$branch" ]; then
        echo ""
    else
        staged=`git diff --cached --name-status | \
            wc -l | awk '{print $1}'`
        if [ $staged -gt "0" ]; then
            echo " $staged"
        else
            echo ""
        fi
    fi
}
function git_modified {
    branch=`__git_ps1 "%s"`
    if [ -z "$branch" ]; then
        echo ""
    else
        modified=`git diff --name-status | wc -l | awk '{print $1}'`
        if [ $modified -gt "0" ]; then
            echo " $modified"
        else
            echo ""
        fi
    fi
}
function git_untracked {
    branch=`__git_ps1 "%s"`
    if [ -z "$branch" ]; then
        echo ""
    else
        untracked=`git ls-files --other --exclude-standard | \
            wc -l | awk '{print $1}'`
        if [ $untracked -gt "0" ]; then
            echo " $untracked"
        else
            echo ""
        fi
    fi
}
function git_close_branch {
    branch=`__git_ps1 "%s"`
    if [ -z "$branch" ]; then
        echo ""
    else
        echo ")"
    fi
}
function rvm_info {
    local gemset=$(echo $GEM_HOME | awk -F'@' '{print $2}')
    [ "$gemset" != "" ] && gemset="@$gemset"
    local version=$(echo $MY_RUBY_HOME | awk -F'-' '{print $2}')
    [ "$version" == "1.8.7" ] && version=""
    local full="$version$gemset"
    [ "$full" != "" ] && echo "$full "
}

# Some fun with switching the foreground terminal process
# Use Ctrl-z to freeze current fg process (ie vim), do something else
# in the shell, ie manpage lookup, then use Ctrl-g to get back to vim
# ref: http://oinopa.com/2010/10/24/laptop-driven-development.html
# TODO Get Ctrl-f set as the freeze command
export HISTIGNORE="fg*"
bind '"\C-g": "fg %-\n"'

function mkcd {
    dir=$1;
    mkdir -p $dir && cd $dir;
}

function mkgit {
    dir=$1;
    mkdir $dir && cd $dir && echo $dir > README.md && git init && git add . && git commit -m 'Initial commit' && git create;
}

function gitd {
    vim -d $1 <(git show HEAD:$1);
    cols 80
}

function git_show_deleted_file {
    git show $(git rev-list -n 1 HEAD -- $1)^:$1
}

function mgitd {
    mvim -d $1 <(git show HEAD:$1);
}

function gitup {
    branch=`__git_ps1 "%s"`
    if [ -z "$branch" ]; then #Not a git repo
        return
    else
        cd "./"$(git rev-parse --show-cdup)
    fi
}

# Vim split diff view function for modified hg file
# Additional settings applied in the vimrc
function hgd {
    vim -d $1 <(hg cat $1);
    cols 80
}

# MacVim Diff ftw
function mhgd {
    mvim -d $1 <(hg cat $1);
    return 0
}

# Positive integer test (including zero)
function positive_int() {
    return $(test "$@" -eq "$@" > /dev/null 2>&1 && test "$@" -ge 0 > /dev/null 2>&1);
}

# Set the terminal to the specified number of columns
function cols() {
    if [ $# -eq 1 ] && $(positive_int "$1"); then
        printf "\e[8;999;${1};t"
        return 0
    fi
    if [ $# -eq "0" ]; then
        printf "\e[8;999;80;t"
    fi
    return 1
}

# Markdown preview to html with local css
function mkd2tmphtml {
    tempfile="/tmp/$$.html";
    pandoc $1 -t html -c $HOME/.pandoc-mkd-style.css > $tempfile;
    open $tempfile;
    return 0;
}

# Less severe than rm
function trash() { mv "$@" ~/.Trash; }

# Python virtualenv support
export WORKON_HOME=~/envs
export PIP_RESPECT_VIRTUALENV=true
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export VIRTUAL_ENV_DISABLE_PROMPT=1
source /usr/local/bin/virtualenvwrapper.sh

# Make sure rvm works right
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
