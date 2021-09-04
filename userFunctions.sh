# ██╗   ██╗ ███████╗ ███████╗ ██████╗       ███╗   ███╗ ███████╗ ████████╗ ██╗  ██╗  ██████╗  ██████╗  ███████╗
# ██║   ██║ ██╔════╝ ██╔════╝ ██╔══██╗      ████╗ ████║ ██╔════╝ ╚══██╔══╝ ██║  ██║ ██╔═══██╗ ██╔══██╗ ██╔════╝
# ██║   ██║ ███████╗ █████╗   ██████╔╝      ██╔████╔██║ █████╗      ██║    ███████║ ██║   ██║ ██║  ██║ ███████╗
# ██║   ██║ ╚════██║ ██╔══╝   ██╔══██╗      ██║╚██╔╝██║ ██╔══╝      ██║    ██╔══██║ ██║   ██║ ██║  ██║ ╚════██║
# ╚██████╔╝ ███████║ ███████╗ ██║  ██║      ██║ ╚═╝ ██║ ███████╗    ██║    ██║  ██║ ╚██████╔╝ ██████╔╝ ███████║
#  ╚═════╝  ╚══════╝ ╚══════╝ ╚═╝  ╚═╝      ╚═╝     ╚═╝ ╚══════╝    ╚═╝    ╚═╝  ╚═╝  ╚═════╝  ╚═════╝  ╚══════╝

#!/bin/bash
IFS=$'\n'

# Import useful shell commands
source ~/Documents/DEV/mobile-scripts/process-utility/textStyles.sh

function returnToBase
{
  echo "This will wipe the build files for the project and switch branches"
  echo -e $blueText"You may want to close your IDE and/or commit these changes:"$normalText
  echo -e $blueText"-----------------------------------------------------------"$normalText
  echo
  git status
  echo
  echo -e $blueText"-----------------------------------------------------------"$normalText
  echo
  echo "> Which branch is base? (type 'x' to chicken out, or leave blank to use current branch)"
  read -p "" baseBranch
  
  if [ "$baseBranch" != "x" ] 
  then 
    git fetch
    git clean -dfx
    git reset --hard
    if [ "$baseBranch" != "" ]
    then
      git checkout $baseBranch
    fi
    git pull
  fi
}

function deepClean
{
  echo 
  echo -e $redText"WARNING: This will wipe all residual build files and repo changes"$normalText
  echo -e $redText"Including the following:"$normalText

  echo
  echo "----------------------"
  echo
  
  git status

  echo
  echo "----------------------"
  echo
  
  echo -e $blueText"You should close your IDE before continuing"$normalText
  echo -e $redText"Are you sure? (y/n)"$normalText
  read -p "" confirm

  if [ "$confirm" == "y" ] 
  then
    git clean -dfx
    git reset --hard
    rm -rf ~/Library/Developer/Xcode/DerivedData
  else
    echo "Come back soon, y'hear?"
  fi 
}

function backupAndExtractApk 
{
    packageName=$1
   	adb backup -f __data.ab -noapk $packageName
    mkdir extractedApk
	dd if=__data.ab bs=1 skip=24 | openssl zlib -d | tar -xvf - --directory extractedApk

}

function sha
{
    sha=$(git rev-parse --short HEAD)
    echo -n $sha | pbcopy
    echo 
    echo "> Copied SHA [$sha] to clipboard"
    echo
}

function buildNumber 
{
    buildNumber=$(git rev-list --all --count)
    echo $buildNumber | pbcopy
    echo
    echo "> Copied unique build number [$buildNumber] to clipboard."
    echo
}

function verifyQuickly 
{
  currentFolder=$(pwd)
  if [[ "$currentFolder" == *"foresee-sdk-android"* ]]
  then
    ./gradlew assembleDevDebug
  elif [[ "$currentFolder" == *"foresee-sdk-ios"* ]]
  then
    fastlane tests
  else
    echo -e $redText"\nRepo not recognized...\n"$normalText
  fi
}

function verify
{
  echo -e $blueText"Would you like to clean first? (y/n)"$normalText
  read  "confirm?"

  currentFolder=$(pwd)
  if [[ "$currentFolder" == *foresee-sdk-android* ]]
  then
    if [[ "$confirm" =~ ^[Yy]$ ]]
    then 
      ./gradlew clean testQaRelease
    else
      ./gradlew testQaRelease
    fi    
  elif [[ "$currentFolder" == *foresee-sdk-ios* ]]
  then
    if [[ "$confirm" =~ ^[Yy]$ ]]
    then 
      git clean -dfx
      pod install
      fastlane tests
    else
      fastlane tests
    fi
  else
    echo -e $redText"\nRepo not recognized...\n"$normalText
  fi
}

function buildAndRun
{
  currentFolder=$(pwd)
  if [[ "$currentFolder" == *"foresee-sdk-android"* ]]
  then
   ./gradlew clean :replaytestapp:assembleQaDebug && adb install -r replaytestapp/build/outputs/apk/qa/debug/replaytestapp-qa-debug.apk 
  else
    echo -e $redText"\nRepo not recognized...\n"$normalText
  fi
}

function whatDidIForget
{
  # initializers
  lastFileLine=""
  lastPositionLine=""
  baseBranch="core"

  echo 
  echo "Let's take a look..."
  echo
  
  # Grep strings
  positionLineId="@@"
  addLineId="+++"
  todoLineId="TODO"

  # some funky zsh to get the git output as an array, grepped to find the right lines
  rawOutputArray=("${(@f)$(git diff $baseBranch | grep "\($addLineId\)\|\($todoLineId\)\|\($positionLineId\)" )}")

  # string replacement regexes
  toRemoveFromAddLine="+++\ b/"        
  toRemoveFromPositionLineStart="^.*+"
  toRemoveFromPositionLineEnd=" @@.*"
  toRemoveFromTodoLineStart="\+ *"

  for line ("$rawOutputArray[@]")
  do
    fileAddLine=$(echo $line | grep $addLineId | sed s/$toRemoveFromAddLine/g)
    if [[ "${#fileAddLine}" != 0 ]]
    then
      lastFileLine="$fileAddLine"
    fi

    positionLine=$(echo $line | grep $positionLineId  | sed s/$toRemoveFromPositionLineStart//g | sed s/$toRemoveFromPositionLineEnd//g)
    if [[ "${#positionLine}" != 0 ]]
    then
      lastPositionLine="$positionLine"
    fi

    todoLine=$(echo $line | grep $todoLineId | sed s/$toRemoveFromTodoLineStart//g)
    if [[ "${#todoLine}" != 0 ]]
    then
      echo -e "$blueText$lastFileLine:[$lastPositionLine]$normalText"
      echo "$redText$todoLine$normalText"
      echo
    fi

  done

  # echo
}

