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
source ~/Documents/DEV/useful-scripts/shell-scripts/git.sh

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
  read "baseBranch?"
  
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
  read  "confirm?"

  if [[ "$confirm" =~ ^[Yy]$ ]]
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

    open sdk/tests/build/reports/tests/testQaReleaseUnitTest/index.html
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

function remindMe
{
  currentFolder=$(pwd)
  if [[ "$currentFolder" == *"foresee-sdk-android"* ]]
  then
    whatDidIForget core
  elif [[ "$currentFolder" == *"foresee-sdk-ios"* ]]
  then
    whatDidIForget core
  elif [[ "$currentFolder" == *"djfx-ios"* ]]
  then
    whatDidIForget develop
  elif [[ "$currentFolder" == *"djfx"* ]]
  then
    whatDidIForget core
  else
    echo -e $redText"\nRepo not recognized...\n"$normalText
  fi
}

function droidLogs
{
  searchPhrase=$1
  adb logcat -d -t 1000000000 -e ".*"$searchPhrase".*"
}

function videoLinks
{
  adb logcat -d -t 1000000 | grep "Video Metadata" | sed 's/.*uuid\\:\\/http:\/\/\mpathy-video-mobilesdk.s3.amazonaws.com\//g' | sed 's/\\,\\.*//g'
}

function quickTests
{
  filename=$1
  ./gradlew sdk:tests:testQaDebugUnitTest --tests "**$filename*" --rerun-tasks
}

# Test a command 100 times and drop out if failed, quoting number of successful attempts
function soak
{
  numTests=0
  command=$1
  while "$command"
  do numTests=numTests+1
  done

  echo "Tested $numTests times"
}

function releaseNotes
{
  startTag=$1
  stopTag=$2
  ticketList=$( git log --pretty=oneline $startTag..$stopTag | grep -o -E "[A-Z]+-[0-9]+" )

  sortedUniqueTickets=($(echo "${ticketList[@]}" | sort -u ))
 
  outputTicketList "${sortedUniqueTickets[@]}"
}

# Returns All tickets which modified a file/folder containing "Test"
# Usage:  testingTickets <date>
# E.g.    testingTickets 2022-03-01
function testingTickets 
{
  date=$1
  
  ticketList=$( git log --after $1 "**Test*" | grep -o -E "[A-Z]+-[0-9]+" )

  sortedUniqueTickets=($(echo "${ticketList[@]}" | sort -u ))

  outputTicketList "${sortedUniqueTickets[@]}"
}

# Returns a formatted list of Jira tickets, including links and JQL filter
# Usage: outputTicketList <arrayOfTickets>
function outputTicketList 
{
  jiraBaseUrl="https://kanasoftware.jira.com/"
  jiraTicketBaseUrl="${jiraBaseUrl}browse/"
  jiraSearchBaseUrl="${jiraBaseUrl}issues/?jql="
  ticketList=("$@")

  echo "\nTickets found:"
  for ticket in "${ticketList[@]}"
  do
      echo $jiraTicketBaseUrl$ticket
  done

  echo "\nSearch JQL:"
  searchUrl=$jiraSearchBaseUrl"issueKey%20in%20("
  for ticket in "${ticketList[@]}"
  do
      searchUrl=$searchUrl$ticket","
  done
  searchUrl=${searchUrl%,}
  searchUrl="$searchUrl)"

  echo $searchUrl
  echo
}

function refreshBash
{
  source ~/.zshrc
  echo "All changes applied"
}

function testSamplingPercentage
{
  cid=$1
  sid=$2
  for i in `seq 1 100`; do curl "https://cx.foresee.com/survey/invite?cid=${cid}&sid=${sid}"; done
}