#!/bin/bash
OPTS=`getopt -o vhcirRf --long verbose,help,commit,install-deps,revert-zshrc,remove-nanc,force -n 'parse-options' -- "$@"`
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

VERBOSE=false
HELP=false
COMMIT=false #default to non-destructive
INSTALLDEPS=false
REMOVENANC=false
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
   echo "-c     --commit     Commit changes. (Defatul is dry-run)."
   echo "-i     --installdeps Install pakages that are needed."
   echo "-r     --revert-zsh.    replace your .zshrc \
   file with the one that was there when this environment was installed."
   echo "-R     --remove-nanc.    remove nanc function from .zshrc"
   echo "       --force.    remove nanc function from .zshrc"
   echo
}
installdeps() {
  echo "querying current environment for: zsh curl git nano net-tools screenfetch"
	#TODO: add support for other distributions
  installList=""

  if  ! which zsh > /dev/null; then installList=$installList' zsh';echo "zsh will be installed";else echo "zsh already installed";fi
  if  ! which curl > /dev/null; then installList=$installList' curl';echo "curl will be installed";else echo "curl already installed";fi
  if  ! which git > /dev/null; then installList=$installList' git';echo "git will be installed";else echo "git already installed";fi
  if  ! which netstat > /dev/null; then installList=$installList' net-tools';echo "net-tools will be installed";else echo "net-tools already installed";fi
  if  ! which screenfetch > /dev/null; then installList=$installList' screenfetch';echo "screenfetch will be installed";else echo "screenfetch already installed";fi

  if [ -z "$installList" ]; then
      echo "the installList is empty"
      echo "no candidates available for installation, exiting."  
      exit
  else
      #echo "\$installList is NOT empty"
      echo "running: sudo apt install $installList"
      sudo apt install $installList -y
      echo "installation completed, exiting"
      exit
  fi
  installList=""
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
removenanc() {
	# remove nanc.function to ~/.zshrc
	startLineNum="$(awk '/###NANCSTART/{ print NR; exit }' $ZSHRC)"
	endLineNum="$(awk '/###NANCEND/{ print NR; exit }' $ZSHRC)"
	#echo $startLineNum
	#echo $endLineNum
	awk -v m=$startLineNum -v n=$endLineNum 'm <= NR && NR <= n {next} {print}' $ZSHRC > $ZSHRC.working && mv $ZSHRC.working $ZSHRC
	# end remove nanc.function
}
# handle parameters and set flags.
while true; do
  case "$1" in
    -v | --verbose ) VERBOSE=true; shift ;;
    -h | --help ) HELP=true; showhelp; exit;;
    -c | --commit ) COMMIT=true; shift ;;
    -i | --install-deps ) INSTALLDEPS=true; installdeps; exit;;
    -r | --revert-zshrc )  REVERTZSHRC=true; revertzshrc; exit;;
	  -R | --remove-nanc )  REMOVENANC=true; removenanc; exit;;
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
mylog COMMIT=$COMMIT
mylog INSTALLDEPS=$INSTALLDEPS
mylog REVERTZSHRC=$REVERTZSHRC
mylog REMOVENANC=$REMOVENANC
### End Some logging

[ $COMMIT = true ] && mylog 'COMMIT' || mylog "NO-COMMIT"

### Start Payload Section
# these lines skip the payload if -c or --commit is ommitted
#[ $COMMIT ]&& COMMAND || echo '*** Skipping due to NO-COMMIT:'
    
	  #TODO: add verbosity to let users know what is going on
    #mylog 'Verbose Mode Active'
    # install oh_my_zsh
    mylog 'downloading and executing Oh My Zsh intall script'
    
    mylog "$COMMIT"
    mylog "$COMMIT"
    mylog "$COMMIT"
    mylog "$COMMIT"
    mylog "$COMMIT"
    
    
    if [[ $COMMIT = true ]];then
      if [ ! -d "~/.oh-my-zsh" ];then #if the .oh-my-zsh directory is not there, install it.
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 
      else #if the .oh-my-zsh directory exists it's already installed
        mylog '*** --- Skipping due to EXISTS: downloading and executing Oh My Zsh intall script'
      fi
    else
      mylog '*** -- Skipping due to NO-COMMIT: downloading and executing Oh My Zsh intall script'
    fi
    # end install oh_my_zsh
   
    # if $ZSHRC still doesn't exist, lets use the template


    if [ ! -f $ZSHRC ]; then
      [ $COMMIT = true ] && /bin/cp -rf ~/.oh-my-zsh/templates/zshrc.zsh-template $ZSHRC || mylog "*** --- Skipping due to NO-COMMIT: Not Overwriting - $ZSHRCBACKUPFILE" 
    fi
   
    mylog "Copying $ZSHRC to $ZSHRCBACKUPFILE"
    # try to backup .zshrc
    if [ -f "$ZSHRCBACKUPFILE" ]; then      
      if [ $FORCE = true ]; then
        mylog "$ZSHRCBACKUPFILE exists but you used --force, copying."
        [ $COMMIT = true ] && /bin/cp -rf $ZSHRC $ZSHRCBACKUPFILE || mylog "*** --- Skipping due to NO-COMMIT: Not Overwriting - $ZSHRCBACKUPFILE" 
      else
        mylog "$ZSHRCBACKUPFILE exists. Please use --force to overwrite"
        mylog 'Exiting without safe .zshrc backup'
        exit
      fi
    else 
      mylog "$ZSHRCBACKUPFILE does not exist, copying."
      [ $COMMIT = true ] && /bin/cp $ZSHRC $ZSHRCBACKUPFILE || echo "*** -- Skipping due to NO-COMMIT: /bin/cp $ZSHRC $ZSHRCBACKUPFILE" 
    fi
    # end backup .zshrc
      
    # add support for oh_my_zsh plugins
    mylog 'adding support for oh_my_zsh plugins'
    if [[ $COMMIT = true ]];then
      sed -i 's/plugins=(git)/plugins=(aliases brew common-aliases docker emoji extract gh git history iterm2 macos pip redis-cli sudo ubuntu ufw vscode web-search wp-cli xcode)/g' $ZSHRC || echo '*** -- Skipping due to NO-COMMIT: Enabling Plugins'
    else 
      mylog '*** -- Skipping due to NO-COMMIT: adding support for oh_my_zsh plugins'
    fi
    # end add oh_my_zsh plugins
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10" ]; then echo "DIR not there"; else echo "DIR there";fi

    # clone and install powerlevel10k
    
    mylog 'cloning powerlevel10k'
    if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10" ]; then # if directory does not exist
      if [[ $COMMIT = true ]];then
        git clone https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k else  
        mylog '*** --- Skipping due to NO-COMMIT: Cloning powerlevel10k'
      fi  
    else
        mylog "*** --- Skipping due to EXISTS: powerlevel10k already present in $HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    fi
    mylog 'updating .zshrc with powerlevel10k'
    if [[ $COMMIT = true ]];then
      sed -i "s/robbyrussell/powerlevel10k\/powerlevel10k/g" $ZSHRC 
    else
      mylog '*** -- Skipping due to NO-COMMIT: updating .zshrc with powerlevel10k'
    fi
    mylog 'copying powerlevel10k config'
    [ $COMMIT = true ]&& cp .p10k.zsh ~/ || mylog '*** - Skipping due to NO-COMMIT: Copying p10k configuration'
    # end install powerlevel10k

    # add nanc.function to $ZSHRC
    if ! grep -q "###NANCSTART" "$ZSHRC"; then # String NOT found in .zshrc
      mylog "add nanc.function to $ZSHRC"
      if [[ $COMMIT = true ]];then
        nanc_lines=$(cat nanc.function)
        awk -v addpattern="$nanc_lines" '/# User configuration/{print $0 "\n" addpattern;next}1' $ZSHRC > $ZSHRC.tmp && mv $ZSHRC.tmp $ZSHRC
      else
        mylog "*** --- Skipping due to NO-COMMIT: add nanc.function to $ZSHRC"
      fi
    else
        mylog "*** --- Skipping due to EXISTS: nanc.function is already present in $ZSHRC"
    fi

    # end add nanc.function

    # add locale infomation to to $ZSHRC
    #export LANG=en_US.UTF-8
    if ! grep -q "export LANG=en_US.UTF-8" "$ZSHRC"; then # String NOT found in .zshrc
      mylog "add locale infomation 'export LANG=en_US.UTF-8' to to $ZSHRC"
      if [[ $COMMIT = true ]];then # check COMMIT flag: true
        sed -i '1i\export LANG=en_US.UTF-8' $ZSHRC # add line at top of .zshrc to comply with powerlevel10k
      else # check COMMIT flag: false
        mylog "*** --- Skipping due to NO-COMMIT: add locale 'export LANG=en_US.UTF-8' to $ZSHRC"
      fi
    else # String 'export LANG' found in .zshrc
      # get the offending line, the previous grep run was quiet.
      result=`grep "export LANG=en_US.UTF-8" "$ZSHRC"`
      if [[ $result == \#* ]]; then # check if the line found is commented
        mylog "result is commented, uncomment it."
        if [[ $COMMIT = true ]];then # check COMMIT flag: true
          sed -i '/export LANG=en_US.UTF-8/s/^#//g' $ZSHRC
          mylog "'export LANG=en_US.UTF-8' is now uncommented."
        else # check COMMIT flag: false
          mylog "*** --- Skipping due to NO-COMMIT: uncommenting 'export LANG=en_US.UTF-8' in $ZSHRC"
        fi
      else # line found is uncommented
          mylog "'export LANG=en_US.UTF-8' is uncommented."
      fi
      result=`grep "export LANG" "$ZSHRC"`
        mylog "*** --- Skipping due to EXISTS: loacle information 'export LANG' is already present in $ZSHRC."
        mylog "Can not add 'LANG=en_US.UTF-8', please add manually to $ZSHRC."
    fi

    #export LC_ALL=en_US.UTF-8
    if ! grep -q "export LC_ALL=en_US.UTF-8" "$ZSHRC"; then # String NOT found in .zshrc
      mylog "add locale infomation 'export LC_ALL=en_US.UTF-8' to to $ZSHRC"
      if [[ $COMMIT = true ]];then # check COMMIT flag: true
        sed -i '1i\export LC_ALL=en_US.UTF-8' $ZSHRC # add line at top of .zshrc to comply with powerlevel10k
      else # check COMMIT flag: false
        mylog "*** --- Skipping due to NO-COMMIT: add locale 'export LC_ALL=en_US.UTF-8' to $ZSHRC"
      fi
    else # String 'export LANG' found in .zshrc
      # get the offending line, the previous grep run was quiet.
      result=`grep "export LC_ALL=en_US.UTF-8" "$ZSHRC"`
      if [[ $result == \#* ]]; then # check if the line found is commented
        mylog "result is commented, uncomment it."
        if [[ $COMMIT = true ]];then # check COMMIT flag: true
          sed -i '/export LC_ALL=en_US.UTF-8/s/^#//g' $ZSHRC
          mylog "'export LC_ALL=en_US.UTF-8' is now uncommented."
        else # check COMMIT flag: false
          mylog "*** --- Skipping due to NO-COMMIT: uncommenting 'export LC_ALL=en_US.UTF-8' in $ZSHRC"
        fi
      else # line found is uncommented
          mylog "'export LC_ALL=en_US.UTF-8' is uncommented."
      fi
      result=`grep "export LANG" "$ZSHRC"`
        mylog "*** --- Skipping due to EXISTS: loacle information 'export LANG' is already present in $ZSHRC."
        mylog "Can not add 'LANG=en_US.UTF-8', please add manually to $ZSHRC."
    fi
    # end add locale infomation to to $ZSHRC

### End Payload Section 