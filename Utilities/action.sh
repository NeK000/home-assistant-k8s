#!/bin/bash

createTempDirectory(){
    folderName=$1
    temporaryDirectory="$folderName"
    debugMessage "Creating temporary directory $temporaryDirectory"
    removeTempDirectory $folderName
    mkdir -p "$temporaryDirectory" > /dev/null
}

removeTempDirectory(){
    folderName="$1"
    debugMessage "Remove temporary directory $folderName"
    rm -rf "$folderName" > /dev/null
}

copyDeploymentsDirectoryToTemp(){
    folderName="$1"
    debugMessage "Copy Deployment files into $folderName"
    cp -r Deployments/* $folderName/ 
}