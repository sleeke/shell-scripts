# ██████╗ ██╗████████╗██████╗ ██╗███████╗███████╗
# ██╔══██╗██║╚══██╔══╝██╔══██╗██║██╔════╝██╔════╝
# ██████╔╝██║   ██║   ██████╔╝██║███████╗█████╗
# ██╔══██╗██║   ██║   ██╔══██╗██║╚════██║██╔══╝
# ██████╔╝██║   ██║   ██║  ██║██║███████║███████╗
# ╚═════╝ ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝

#####################################
# Android SDK Environment Variables #
#####################################

export APPCENTER_OWNER_NAME="ForeSee-Mobile"
export APPCENTER_DESTINATIONS="*"

#################################
# iOS SDK Environment Variables #
#################################

export APPCENTER_API_TOKEN="ce157c8443cc6fbc78ca6ce26eab04c72ec17efc"
export APPCENTER_DESTINATIONS="*"
export APPCENTER_TRIGGER_TEST_APP_NAME="Test-App-iOS-Trigger"
export APPCENTER_REPLAY_TEST_APP_NAME="Test-App-iOS-Replay"

########################################
# Daksha Environment Variables/secrets #
########################################

# Daksha app keystore credentials

export VERINT_UPLOAD_KESTORE_PATH="upload-keystore"
export VERINT_UPLOAD_KESTORE_PASS="neighbor-NOUN-fresh-16"
export VERINT_UPLOAD_KEY_PASS="neighbor-NOUN-fresh-16"
export VERINT_UPLOAD_KEY_ALIAS="upload"

#####################
# General functions #
#####################

DEV_HOME="/Users/selwyn.leeke/Documents/DEV"
                                               
bitriseDaksha () {
  FLOW=$1
  REPO_PATH="$DEV_HOME/mobile-monitor-ci"
  cd "$REPO_PATH"
  bitrise run $FLOW -c ./bitrise/bitrise.yml -i ../EX-REPO-DATA/bitrise.secrets-daksha.yml
}

bitriseAndroidSDK () {
  FLOW=$1
  if [[ "$FLOW" == "" ]]
  then
    FLOW="Build-QA"
  fi
  REPO_PATH="$DEV_HOME/foresee-sdk-android"
  cd "$REPO_PATH"
  bitrise run $FLOW -c ./bitrise.yml -i ../EX-REPO-DATA/bitrise.secrets-sdk.yml
}

bitriseIosSDK () {
  FLOW=$1
  REPO_PATH="$DEV_HOME/foresee-sdk-ios"
  cd "$REPO_PATH"
  bitrise run $FLOW -c ./bitrise.yml -i ../EX-REPO-DATA/bitrise.secrets-sdk.yml
}

bitriseCordovaQaApp () {
  FLOW=$1
  REPO_PATH="$DEV_HOME/foresee-cordova-test-app-qa"
  cd "$REPO_PATH"
  bitrise run $FLOW -c ./bitrise.yml -i ../EX-REPO-DATA/bitrise.secrets-sdk.yml
}

