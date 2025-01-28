#!/bin/bash
IFS=$'\n'

folders=()
function getFolders()
{
  root=$1
  if [[ $root -eq "" ]]
  then
    root="./"
  fi

  unset folders
  for d in ReplayTestApp/*/ ; do
    folders+=("$d")
  done
}

function findFiles
{
  currentFolderList=()
  getFolders

  currentFolderList=("${folders[@]}")
  for folder in ${currentFolderList[@]}; do
    echo ".."
    realFolder=$($folder | sed 's/\///g')
    getFolders folder
    echo $folders
  done

}