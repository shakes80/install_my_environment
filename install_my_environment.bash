#!/bin/bash
#
# 
#
OPTS=`getopt -o vhrf --long verbose,help,revert-zshrc,force -n 'parse-options' -- "$@"`
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

VERBOSE=false
HELP=false
REVERTZSHRC=false
ZSHRC=~/.zshrc
ZSHRCBACKUPFILE=$PWD/.zshrc.original.bak
FORCE=false

### Some helpful Functions
showhelp(){
   # Display Help
   echo "Hi! Please specify options."
   echo
   echo "Syntax: install_my_environment.bash [-v|h|c|n]"
   echo "options:"
   echo "-v     --verbose    Verbose mode."
   echo "-h     --help       Print this Help."
   echo "-r     --revert-zsh.    replace your .zshrc \
   file with the one that was there when this environment was installed."
   echo "       --force.    remove nanc function from .zshrc"
   echo
}
revertzshrc() {
  # revert .zshrc to original
    if [ -f "$ZSHRC" ]; then      
      if [[ $FORCE -eq 1  ]]; then
        echo "$ZSHRC exists but you used --force, overwriting."
        /bin/cp -rf $ZSHRC $ZSHRCBACKUPFILE
      else
        echo '$ZSHRC exists. Please use --force to overwrite'
        echo 'Exiting without without overwritting $ZSHRC'
        exit
      fi
    else 
      mylog "$ZSHRC does not exist, copying."
      /bin/cp $ZSHRCBACKUPFILE $ZSHRC 
    fi
  # end revert
}

# handle parameters and set flags.
while true; do
  case "$1" in
    -v | --verbose ) VERBOSE=true; shift ;;
    -h | --help ) HELP=true; showhelp; exit;;
    -r | --revert-zshrc )  REVERTZSHRC=true; revertzshrc; exit;;
    -f | --force )  FORCE=true;shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

# helper function to log more cleanly -- MUST be after the parameters are handled
mylog() {
    if [ $VERBOSE = true ]; then
        echo "$@" | tee -a lastrun.log 
    else
        echo "$@" >> lastrun.log
    fi
}
### End Some helpful Functions
### Some logging
> lastrun.log # Initialize log
mylog $@
# do some checks and log them for debugging
if [ $VERBOSE ]; then 
	mylog 'Verbose mode enabled.'
fi
if [ "$(whoami)" != root ]; then
    mylog "Hi, $(whoami). You are not root user."
else
    mylog "You $(whoami), are the root user. Greetings Master!"
fi
if  test -z ${BASH_VERSION+y}; then
    mylog "Not using bash"
else 
    mylog "bash is version: '$BASH_VERSION'"
fi
if  which zsh > /dev/null; then
    mylog "found zsh."
    mylog "zsh is version: $(zsh --version)"
else 
    mylog "zsh is not in your path."
    mylog 'zsh is required! Consider using --install-deps. Exiting now.'
    exit
fi
mylog "$OPTS"
mylog VERBOSE=$VERBOSE
mylog FORCE=$FORCE
mylog HELP=$HELP
mylog REVERTZSHRC=$REVERTZSHRC
### End Some logging

### Start Payload Section
# these lines skip the payload if -c or --commit is ommitted
#[ $COMMIT ]&& COMMAND || echo '*** Skipping due to NO-COMMIT:'
    
	  #TODO: add verbosity to let users know what is going on
    #mylog 'Verbose Mode Active'
    # install oh_my_zsh
    mylog 'downloading and executing Oh My Zsh intall script'
      if [ ! -d "~/.oh-my-zsh" ];then #if the .oh-my-zsh directory is not there, install it.
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 
      else #if the .oh-my-zsh directory exists it's already installed
        mylog '*** --- Skipping due to EXISTS: downloading and executing Oh My Zsh intall script'
      fi
    # end install oh_my_zsh
   
    # if $ZSHRC still doesn't exist, lets use the template
    if [ ! -f $ZSHRC ]; then
    #TODO: COPY .ZSHRC TEMPLATE
      /bin/cp -rf ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
    fi
   
    mylog "Copying $ZSHRC to $ZSHRCBACKUPFILE"
    # try to backup .zshrc
    /bin/cp -rf $ZSHRC $ZSHRCBACKUPFILE 
    # end backup .zshrc
      
    # add support for oh_my_zsh plugins
    mylog 'adding support for oh_my_zsh plugins'
    sed -i 's/plugins=(git)/plugins=(aliases brew common-aliases docker emoji extract gh git history iterm2 macos pip redis-cli sudo ubuntu ufw vscode web-search wp-cli xcode)/g' $ZSHRC || echo '*** -- Skipping due to NO-COMMIT: Enabling Plugins'
    # end add oh_my_zsh plugins

#if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10" ]; then echo "DIR not there"; else echo "DIR there";fi

    # clone and install powerlevel10k
    mylog 'cloning powerlevel10k'
    if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10" ]; then # if directory does not exist
        git clone https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k 
    fi  
    
    mylog 'copying powerlevel10k config'
    cp .p10k.zsh ~/
    # end install powerlevel10k

### End Payload Section 