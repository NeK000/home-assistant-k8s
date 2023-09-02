#!/bin/bash

isKubectlPresent(){
    version=$(kubectl version)
    status=$?
    [ $status -eq 0 ] && debugMessage "Kubectl is present \n $version" || errorMessage "Kubectl is not configured. Check https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/ for installation"
}