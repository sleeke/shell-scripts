# ██████╗ ██╗      █████╗ ██╗   ██╗ ██████╗ ██████╗  ██████╗ ██╗   ██╗███╗   ██╗██████╗ 
# ██╔══██╗██║     ██╔══██╗╚██╗ ██╔╝██╔════╝ ██╔══██╗██╔═══██╗██║   ██║████╗  ██║██╔══██╗
# ██████╔╝██║     ███████║ ╚████╔╝ ██║  ███╗██████╔╝██║   ██║██║   ██║██╔██╗ ██║██║  ██║
# ██╔═══╝ ██║     ██╔══██║  ╚██╔╝  ██║   ██║██╔══██╗██║   ██║██║   ██║██║╚██╗██║██║  ██║
# ██║     ███████╗██║  ██║   ██║   ╚██████╔╝██║  ██║╚██████╔╝╚██████╔╝██║ ╚████║██████╔╝
# ╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═════╝ 
 
##############################################################
# A place for temporary experiments waiting for the big time #
##############################################################

#!/bin/bash
IFS=$'\n'

# Import useful shell commands
source ~/Documents/DEV/mobile-scripts/process-utility/textStyles.sh
source ~/Documents/DEV/useful-scripts/shell-scripts/git.sh

# Test the IngestionLogger module of the iOS SDK
function dbaTests
{
  # This doesn't look like it works, but it does; the error is stored elsewhere (in stdErr, I'm guessing...) and returned
  error=$(bundle exec fastlane scan --scheme EXPDBA --workspace "Verint.xcworkspace" --clean false --device "iPhone 8")
  return
}

function quickTestIos
{
  scheme=$1
  if [ -z "$scheme" ]
  then
    fastlane scan --workspace "Verint.xcworkspace" --clean false --device "iPhone 8"
  else
    fastlane scan --scheme $scheme --workspace "Verint.xcworkspace" --clean false --device "iPhone 8"
  fi
}

function droidTests
{
  error=$(./gradlew clean testQaRelease)
  open sdk/tests/build/reports/tests/testQaReleaseUnitTest/index.html
  return 
}

function fullTests
{
  # This doesn't look like it works, but it does; the error is stored elsewhere (in stdErr, I'm guessing...) and returned
  error=$(fastlane test)
  return
}

function fullAndroidTests
{
  # This doesn't look like it works, but it does; the error is stored elsewhere (in stdErr, I'm guessing...) and returned
  error=$(./gradlew testQaDebugUnitTest)
  return
}

function allIosTests
{
  fastlane scan --scheme CxMeasure --workspace "Verint.xcworkspace" --clean true --device "iPhone 11"
}

function workingArgument
{
  adb shell am start -n com.verint.xm.tracker.testApp/.MainActivity --es "EXP_config_raw" '{\"clientId\":\"Ij6P1lfZHchO/co10lQ4BQ==\"\,\"customerKey\":4453888\,\"repeatDaysAfterDecline\":1\,\"repeatDaysAfterComplete\":1\,\"repeatDaysAfterAccept\":1\,\"notificationType\":\"IN_SESSION\"\,\"supportsReinvitation\":true\,\"sessionReplayEnabled\":true\,\"measures\":[{\"surveyId\":\"app_test_1\"\,\"surveyStyle\":\"modern\"\,\"daysSinceFirstLaunch\":1\,\"launchCount\":0\,\"significantEventThresholds\":{\"app_test_1\":1}}]\,\"invite\":{\"logo\":\"invite_logo_qa\"\,\"header\":\"custom_header\"\,\"baseColor\":[255\,159\,234]}\,\"feedback\":{\"feedbackSurveys\":[{\"name\":\"prod1\"\,\"feedbackId\":\"40egY2o9Jt\"}]\,\"surveyCompletionPageDelay\":10}}'
}

function brokenArgument 
{
  # adb shell am start -n com.verint.xm.sdk.internal/.MainActivity --es "EXP_config_raw" '{\"customerKey\":4453888\,\"measures\":[{\"surveyId\":\"app_test_1\"\,\"surveyStyle\":\"modern\"}]\,\"customerId\":\"Ij6P1lfZHchO/co10lQ4BQ==\"\,\"notificationType\":\"CONTACT\"\,\"invite\":{\"logo\":\"invite_logo_qa\"\,\"header\":\"custom_header\"\,\"baseColor\":[255\,159\,234]}\,\"replay\":{\"recordingRate\":100\,\"enabled\":false}}'
  adb shell am start -n com.verint.xm.tracker.testApp/.MainActivity --es "EXP_config_raw" '{\"customerKey\":4453888\,\"measures\":[{\"surveyId\":\"app_test_1\"\,\"surveyStyle\":\"modern\"}]\,\"customerId\":\"Ij6P1lfZHchO/co10lQ4BQ==\"\,\"notificationType\":\"CONTACT\"\,\"invite\":{\"logo\":\"invite_logo_qa\"\,\"header\":\"custom_header\"\,\"baseColor\":[255\,159\,234]}\,\"replay\":{\"recordingRate\":100\,\"enabled\":true}\,\"feedback\":{\"feedbackSurveys\":[{\"name\":\"prod1\"\,\"feedbackId\":\"40egY2o9Jt\"}]\,\"surveyCompletionPageDelay\":10}}'
  # {\"customerKey\":4453888,\"measures\":[{\"surveyId\":\"app_test_1\",\"surveyStyle\":\"modern\"}],\"customerId\":\"Ij6P1lfZHchO/co10lQ4BQ==\",\"notificationType\":\"CONTACT\",\"invite\":{\"logo\":\"invite_logo_qa\",\"header\":\"custom_header\",\"baseColor\":[255,159,234]},\"replay\":{\"recordingRate\":100,\"enabled\":true}}
}

function wipArgument
{
  adb shell am start -n com.verint.xm.sdk.internal/.MainActivity --es "EXP_config_raw" '{\"customerKey\":4453888\,\"measures\":[{\"surveyId\":\"app_test_1\"\,\"surveyStyle\":\"modern\"}]\,\"customerId\":\"Ij6P1lfZHchO/co10lQ4BQ==\"\,\"notificationType\":\"CONTACT\"\,\"invite\":{\"logo\":\"invite_logo_qa\"\,\"header\":\"custom_header\"\,\"baseColor\":[255\,159\,234]}\,\"dba\":{\"recordingRate\":0\,\"enabled\":true}\,\"feedback\":{\"feedbackSurveys\":[{\"name\":\"prod1\"\,\"feedbackId\":\"40egY2o9Jt\"}]\,\"surveyCompletionPageDelay\":10}}'
}

function bsArgument
{
# adb shell am start -n com.verint.xm.tracker.testApp/.MainActivity --es 'EXP_config_raw' '{"customerKey":4453888,"measures":[{"surveyId":"app_test_1","surveyStyle":"modern"}],"customerId":"Ij6P1lfZHchO/co10lQ4BQ==","notificationType":"IN_SESSION","replay":{"recordingRate":100,"enabled":true}}' --es 'EXP_environment' 'Production'
  adb shell am start -n com.verint.xm.tracker.testApp/.MainActivity --es 'EXP_config_raw' '{\"customerKey\":4453888\,\"measures\":[{\"surveyId\":\"app_test_1\"\,\"surveyStyle\":\"modern\"}]\,\"customerId\":\"Ij6P1lfZHchO/co10lQ4BQ==\"\,\"notificationType\":\"IN_SESSION\"\,\"replay\":{\"recordingRate\":100\,\"enabled\":true}\,\"invite\":{\"logo\":\"invite_logo_qa\"\,\"header\":\"custom_header\"\,\"baseColor\":[255\,159\,234]}}' --es 'EXP_environment' 'Production'
}

function resetAndInstallRemoteCordovaPlugin
{
  git clean -dfx
  npm install
  cordova platform add android
  cordova plugin add https://github.com/foreseecode/foresee-sdk-cordova-plugin.git
  cordova run android
}

function nukeGradleCache
{
  rm -rf ~/.m2
  rm -rf ~/.gradle/caches/
}

function react_cleanAndPackSdk
{
  branch=$1
  result="failed"

  cd ~/Documents/DEV/verint-xm-react-native-sdk
  git clean -dfx
  git reset --hard
  git fetch 
  git checkout develop
  git checkout $branch && git pull && npm install && cd ios && pod update && cd .. && npm pack && result="succeeded"
  
  say "clean and pack SDK $result"
}

function react_buildInSessionSample
{
  branch=$1
  result="failed"

  cd ~/Documents/DEV/verint-xm-react-native-sample-apps/InSessionSample
  git clean -dfx
  git reset --hard
  git fetch 
  git checkout $branch && git pull && npm uninstall react-native-verint-xm-sdk && npm install ../../verint-xm-react-native-sdk/react-native-verint-xm-sdk-3.0.1.tgz && cd ios && pod update && cd .. && npm pack && result="succeeded"
  
  say "build sample $result"
}
function react_buildInSessionSample
{
  branch=$1
  platform=$2
  result="failed"

  if [ -z "$branch" ]
  then
    branch="develop"
  fi
  if [ -z "$platform" ]
  then
    platform="ios"
  fi

  cd ~/Documents/DEV/verint-xm-react-native-sample-apps/InSessionSample
  git clean -dfx
  git reset --hard
  git fetch 
  git checkout $branch && git pull && npm uninstall react-native-verint-xm-sdk && npm install ../../verint-xm-react-native-sdk/react-native-verint-xm-sdk-3.0.1.tgz && cd ios && pod update && cd .. && npx react-native run-$platform && result="succeeded"
  
  say "building sample $result"
}

function react_buildQaTestApp
{
  branch=$1
  platform=$2
  result="failed"

  if [ -z "$platform" ]
  then
    platform="ios"
  fi

  cd ~/Documents/DEV/verint-xm-react-native-qa-test-app
  git clean -dfx
  git reset --hard
  git fetch 
  git checkout develop
  git checkout $branch ; git pull && npm uninstall react-native-verint-xm-sdk && npm install ../verint-xm-react-native-sdk/react-native-verint-xm-sdk-3.0.1.tgz && npm install && cd ios && pod update && cd .. && npx react-native run-$platform && result="succeeded"
  
  say "building sample $result"
}

function cordova_buildQaTestApp
{
  branch=$1
  platform=$2
  result="failed"

  export NODE_OPTIONS=--openssl-legacy-provider

  if [ -z "$branch" ]
  then
    branch="develop"
  fi
  if [ -z "$platform" ]
  then
    platform="ios"
  fi

  # Plugin
  cd ~/Documents/DEV/verint-xm-cordova-plugin
  git clean -dfx
  git reset --hard
  git fetch 
  git checkout $branch || git checkout develop 
  git pull

  # Test app
  cd ~/Documents/DEV/verint-xm-cordova-test-app-qa
  git clean -dfx
  git reset --hard
  git fetch 
  git checkout $branch && git pull && ionic cordova plugin remove cordova-plugin-verint-xm
  ionic cordova plugin remove cordova-plugin-foresee
  ionic cordova plugin add ../verint-xm-cordova-plugin && npm install

  if [[ $platform -eq "ios" ]]
  then
    echo "Running iOS tasks"
    ionic cordova platform add ios
  fi

  ionic cordova run $platform && result="succeeded"
  
  export NODE_OPTIONS=""

  say "Building Cordova Test App $result"
}

function cordova_buildSample
{
  branch=$1
  platform=$2
  result="failed"

  if [ -z "$platform" ]
  then
    platform="ios"
  fi

  # Plugin
  cd ~/Documents/DEV/verint-xm-cordova-plugin
  git clean -dfx
  git reset --hard
  git fetch 
  git checkout $branch && git pull 

  # Test app
  cd ~/Documents/DEV/verint-xm-cordova-sample/SampleApp
  git clean -dfx
  git reset --hard
  git fetch 
  git checkout $branch && git pull 
  cordova plugin remove cordova-plugin-verint-xm
  cordova plugin remove cordova-plugin-foresee
  cordova plugin add ../../verint-xm-cordova-plugin && npm install && cordova platform add $platform && cordova prepare $platform && cordova run -d $platform && result="succeeded"
  
  say "Building Cordova Test App $result"
}

function promptQuitWithMessage
{
  message=$1

  echo -e $blueText$message". Would you like to continue? (y/n)"$normalText
  read  "confirm?"

  if [[ "$confirm" =~ ^[Yy]$ ]]
  then 
    echo "OK, continuing..."
    return 0
  else
    echo "OK, exiting..."
    return 1
  fi    
}

function console
{
  sudo /System/Applications/Utilities/Console.app/Contents/MacOS/Console
}

function fixTrello
{
  rm -rf ~/Library/Containers/com.atlassian.trello/Data 
  cp -r -P ~/Library/Containers/com.atlassian.trello/LatestData ~/Library/Containers/com.atlassian.trello/Data
}

function backupTrello 
{
  rm -rf ~/Library/Containers/com.atlassian.trello/LatestData 
  cp -r -P ~/Library/Containers/com.atlassian.trello/Data ~/Library/Containers/com.atlassian.trello/LatestData
}