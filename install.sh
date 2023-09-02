#!/bin/bash
set -e
set -o pipefail

source ./Utilities/logging.sh
source ./Utilities/validation.sh
source ./Utilities/action.sh
deploymentName="ha-deployment"
deploymentNamePretty ="Home Assitant"
loggingFile="installation-log-$(date +'%d-%m-%Y').txt"
{

    scriptStartMessage "Starting installation of $deploymentNamePretty towards Kubernetes Cluster"
    deploymentDirectory="$(date +'%d-%m-%Y')-$deploymentName"
    isKubectlPresent
    createTempDirectory "$deploymentDirectory"
    copyDeploymentsDirectoryToTemp "$deploymentDirectory"
    infoMessage "Preparing distribution based on configuration.yaml ===> "
    filePrint "$(<configuration.yaml)"

    namespaceYaml=$deploymentDirectory/namespace.yaml
    pvcLonghornYaml=$deploymentDirectory/persistance-volume-longhorn.yaml
    pvcNfsYaml=$deploymentDirectory/persistance-volume-nfs.yaml
    deploymentYaml=$deploymentDirectory/deployment.yaml
    serviceYaml=$deploymentDirectory/service.yaml
    ingressRouteYaml=$deploymentDirectory/ingress-route.yaml
    infoMessage "Preparing deployment file"
    IMAGE_NAME=$(yq .deployment.image.name configuration.yaml):$(yq .deployment.image.tag configuration.yaml)    yq -i '.spec.template.spec.containers[0].image = strenv(IMAGE_NAME)'  $deploymentYaml
    HOMEKIT_ENABLED=$(yq .deployment.homekit.enabled configuration.yaml)
    
    if [ "$HOMEKIT_ENABLED" = true ] ; then
        yq -i '.spec.template.spec.hostNetwork = true'  $deploymentYaml
    fi

    infoMessage "Preparing persistance volume files"
    STORAGE_TYPE=$(yq .storage.type configuration.yaml)
    if [ "$STORAGE_TYPE" = "longhorn" ] ; then
        infoMessage "Choosen storage type is longhorn"
        SIZE=$(yq .storage.size configuration.yaml)    yq -i '.spec.resources.requests.storage = strenv(SIZE)' $pvcLonghornYaml
    else
        infoMessage "Choosen storage type is NFS"
        SIZE=$(yq .storage.size configuration.yaml)    yq -i '.spec.resources.requests.storage = strenv(SIZE)' $pvcNfsYaml
        SIZE=$(yq .storage.size configuration.yaml)    yq -i '.spec.capacity.storage = strenv(SIZE)' $pvcNfsYaml
        NFS_PATH=$(yq .storage.nfs.path configuration.yaml)    yq -i '.spec.nfs.path = strenv(NFS_PATH)' $pvcNfsYaml
        NFS_SERVER=$(yq .storage.nfs.server configuration.yaml)    yq -i '.spec.nfs.server = strenv(NFS_SERVER)' $pvcNfsYaml
    fi

    infoMessage "Preparing service files"
    SERVICE_PORT=$(yq .service.port configuration.yaml)    yq -i '.spec.ports[0].port = strenv(SERVICE_PORT)' $serviceYaml
    ROUTE=$(yq .service.ingressHost configuration.yaml)

    SERVICE_INGRESS_ROUTE="Host('$ROUTE')"    yq -i '.spec.routes[0].match = strenv(SERVICE_INGRESS_ROUTE)' $ingressRouteYaml

    namespaceYaml=$deploymentDirectory/namespace.yaml
    pvcLonghornYaml=$deploymentDirectory/persistance-volume-longhorn.yaml
    pvcNfsYaml=$deploymentDirectory/persistance-volume-nfs.yaml
    deploymentYaml=$deploymentDirectory/deployment.yaml
    serviceYaml=$deploymentDirectory/service.yaml
    ingressRouteYaml=$deploymentDirectory/ingress-route.yaml

    infoMessage "Deploying $deploymentNamePretty"
    kubectl apply -f $namespaceYaml
    STORAGE_TYPE=$(yq .storage.type configuration.yaml)
    if [ "$STORAGE_TYPE" = "longhorn" ] ; then
    kubectl apply -f $pvcLonghornYaml
    else
    kubectl apply -f $pvcNfsYaml
    fi
    kubectl apply -f $deploymentYaml
    kubectl apply -f $serviceYaml
    kubectl apply -f $ingressRouteYaml

    removeTempDirectory "$deploymentDirectory"
    scriptEndMessage "Succesfull installation of $deploymentNamePretty !!!"
}