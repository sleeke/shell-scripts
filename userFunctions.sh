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
source ~/bash-scripts/playground.sh

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

function bn
{
    branchName=$(git branch  --show-current)
    echo -n $branchName | pbcopy
    echo 
    echo -e "> Copied branch name $blueText$branchName$normalText to clipboard"
    echo
}

function buildNumber 
{
    buildNumber=$(git rev-list --all --count)
    echo $buildNumber | pbcopy
    echo
    echo "> Copied unique build number $blueText$buildNumber$normalText to clipboard."
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

    # Open the results
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
    
    # Open the results
    open builds/tmp/*.xml
  elif [[ "$currentFolder" == *m-pathy-mobile-automation* ]]
  then
    ./gradlew clean -P=smokeSuite test --rerun-tasks  
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

# Test a command until failure, quoting number of successful attempts
function soak
{
  numTests=0
  command=$1
  while "$command"
  do 
    numTests=$((numTests+1))    
    echo -e "\n$blueText$numTests successful runs so far...$normalText\n"
  done

  echo -e "\n$redText$numTests runs before failure$normalText\n"
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

function setJDK
{
  version=$1

  if [[ "$version" == "18" ]]
  then 
    JAVA_HOME="/Library/Java/JavaVirtualMachines/alts/jdk-18.0.1.jdk/Contents/Home"
  elif [[ "$version" == "11" ]]
  then 
    JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home"
  elif [[ "$version" == "8" ]]
  then 
    JAVA_HOME=/Library/Java/JavaVirtualMachines/alts/jdk1.8.0_201.jdk/Contents/Home
  fi

  java -version
}

function automatedTests
{
  suiteFile=$1
  ./gradlew -PsuiteFile=$suiteFile test --rerun-tasks

  open ./build/reports/tests/test/index.html
  rm -rf ./build/resources
}

function clearSdkArtefactsFromM2cache
{
  rm -rf ~/.m2/repository/com/verint/xm/sdk/core
  rm -rf ~/.m2/repository/com/verint/xm/sdk/dba
  rm -rf ~/.m2/repository/com/verint/xm/sdk/predictive
  rm -rf ~/.m2/repository/com/verint/xm/sdk/digital
}

function searchEverywhere
{
  searchTerm=$1

  # Google
  open "https://www.google.com/search?q=${searchTerm}"
  
  # Sharepoint
  open "https://verint.sharepoint.com/_layouts/15/sharepoint.aspx?q=${searchTerm}&v=%2Fsearch"
  
  # Confluence
  open "https://kanasoftware.jira.com/wiki/search?text=${searchTerm}"

  #Jira
  open "https://kanasoftware.jira.com/issues/?jql=text%20~%20%22${searchTerm}%22%20order%20by%20updated%20desc"
}

function fetchAndRepeat
{
  git fetch; history -p !:0
}

function qaBuildIosSdk
{
  branch=$1
  if [ -z "$branch" ]
  then
    branch="core"
  fi

  curl https://app.bitrise.io/app/8680baa58cb0b480/build/start.json -L --data '{"build_params":{"branch":"'$branch'","commit_message":"Ad-hoc QA build","workflow_id":"Build-QA-Automated"},"hook_info":{"build_trigger_token":"2XNwNb0fTrUdn7SwuM3IGQ","type":"bitrise"},"triggered_by":"curl"}'
}

function qaBuildAndroidSdk
{
  branch=$1
  if [ -z "$branch" ]
  then
    branch="core"
  fi

  curl https://app.bitrise.io/app/2cec4f19031194c1/build/start.json -L --data '{"build_params":{"branch":"'$branch'","commit_message":"Ad-hoc QA build","workflow_id":"Build-QA-Automated"},"hook_info":{"build_trigger_token":"tWLcwoQ9i6OdRYMC2B31sQ","type":"bitrise"},"triggered_by":"curl"}'
}

function generateTestReport
{
  product=$1

  predictive="%22%2FMobSDK%2FPredictive%20%26%20Digital%20App%2F**%22"
  xmApp="%22%2FMobius%2FXM%20App%2F**%22"

  if [[ "$product" == "predictive" ]]
  then
    productString=$predictive
  elif [[ "$product" == "xm-app" ]]
  then
    productString=$xmApp
  else
    echo "Incorrect arguments; please select 'predictive' or 'xm-app'"
  fi


  twoWeeksAgo=$(date -r $(expr $(date +%s) - 1209600) +%Y-%m-%d)

  if [ -n "$productString" ]
  then 
    echo "Generating a report for $product"
    open "https://kanasoftware.jira.com/projects/VOC?selectedItem=com.atlassian.plugins.atlassian-connect-plugin:com.kanoah.test-manager__main-project-page#!/reports/testresults/board/view?tql=testResult.projectId%20IN%20(21079)%20AND%20testCase.priorityName%20IN%20(%22Critical%22)%20AND%20testResult.executionDate%20%3E%3D%20%27${twoWeeksAgo}%27%20AND%20testRun.folderName%20IN%20(${productString})%20AND%20testRun.statusName%20IN%20(%22Done%22)%20AND%20testRun.onlyLastTestResult%20IS%20true&epicJQL=&title=Test%20execution%20results%20(summary)&projectId=21079&traceabilityReportOption=COVERAGE_TEST_CASES&traceabilityTreeOption=COVERAGE_TEST_CASES&traceabilityCustomTreeDisplayOption=CONDENSED&traceabilityMatrixOption=COVERAGE_TEST_CASES&scorecardOption=EXECUTION_RESULTS&displayUnit=PERCENTAGE&period=WEEK&timezone=America%2FLos_Angeles"
  fi
}