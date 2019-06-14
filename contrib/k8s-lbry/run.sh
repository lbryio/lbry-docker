#!/bin/bash
BASEDIR=$(cd $(dirname "$0"); pwd)
BASENAME=$(basename "$0")

## RELEASE - The name for the helm release.
RELEASE=${RELEASE:-k8s-lbry}

## NAMESPACE - The Kubernetes namespace for the release
NAMESPACE=${NAMESPACE:-k8s-lbry}

## CHART - The helm chart location (local path, or from repository)
### Use the stable chart from the HELM_REPO repository:
CHART=${CHART:-lbry/k8s-lbry}
### Use the chart from the current directory:
#CHART=${CHART:-$BASEDIR}

## VALUES - The path to your configured helm values.yaml:
VALUES=${VALUES:-$BASEDIR/values-dev.yaml}
DEFAULT_VALUES_URL=${DEFAULT_VALUES_URL:-https://raw.githubusercontent.com/EnigmaCurry/lbry-docker/k8s-lbry/contrib/k8s-lbry/values.yaml}

## HELM_REPO - The stable helm chart repository for this chart:
HELM_REPO=${HELM_REPO:-https://k8s-lbry.sfo2.digitaloceanspaces.com}

## TILLER_HOST - The host that runs tiller
TILLER_HOST=${TILLER_HOST:-localhost}

## CERTMANAGER_NAMESPACE - The namespace cert-manager runs in
CERTMANAGER_NAMESPACE=${CERTMANAGER_NAMESPACE:-cert-manager}
CERTMANAGER_VERSION=v0.7.1

## NGINX_ENABLE_HTTPS - This needs to be set false until DNS is setup.
NGINX_ENABLE_HTTPS=${NGINX_ENABLE_HTTPS:-false}

## Mysql Database snapshot download url:
CHAINQUERY_SNAPSHOT_URL=${CHAINQUERY_SNAPSHOT_URL:-https://lbry-chainquery-mysql-dump.sfo2.digitaloceanspaces.com/chainquery_height_560900.mysql-backup.tar.gz}

## lbrycrd snapshot download url:
LBRYCRD_SNAPSHOT_URL=${LBRYCRD_SNAPSHOT_URL:-https://lbry-chainquery-mysql-dump.sfo2.digitaloceanspaces.com/lbrycrd-566588-snapshot.tar.gz}

LBRYCRD_RPC_USER=${LBRYCRD_RPC_USER:-lbry}
LBRYCRD_RPC_PASSWORD=${LBRYCRD_RPC_PASSWORD:-lbry}

## Bash alias name for run.sh
## defaults to $NAMESPACE (k8s-lbry)
RUN_ALIAS=${RUN_ALIAS:-$NAMESPACE}

## Package bucket (ignore this, only used by developer of this package)
PACKAGE_BUCKET=${PACKAGE_BUCKET:-"s3://k8s-lbry"}

exe() { ( echo "## $*"; $*; ) }

setup() {
    ### Check for external dependencies:
    if ! which helm > /dev/null; then
        echo "Error: You must install helm"
        echo "On Ubuntu you can run: sudo snap install --classic helm"
        echo "For other platforms, see https://github.com/helm/helm/releases/latest"
        exit 1
    fi
    if ! which kubectl > /dev/null; then
        echo "Error: You must install kubectl"
        echo "On Ubuntu you can run: sudo snap install --classic kubectl"
        echo "For other platforms, see https://kubernetes.io/docs/tasks/tools/install-kubectl/"
        exit 1
    fi
    if ! which git > /dev/null; then
        echo "Error: You must install git"
        echo "On Ubuntu you can run: sudo apt install -y git"
        echo "For other platforms, see https://git-scm.com/downloads"
        exit 1
    fi

    ### Initialize helm locally, but do not install tiller to the cluster:
    HELM=$(which helm)
    if [ ! -f "$HOME"/.helm/repository/repositories.yaml ]; then
        exe "$HELM" init --client-only
    fi

    ### Add the stable helm chart repository:
    if [ "$CHART" != "$BASEDIR" ]; then
        exe "$HELM" repo add lbry "$HELM_REPO"
        exe "$HELM" repo update
    fi

    ### Install helm-tiller plugin, so that no tiller needs to be installed to the cluster:
    exe "$HELM" plugin install https://github.com/rimusz/helm-tiller || true

    ### Setup the values.yaml for the chart, using the VALUES environment variable or script default
    ### If no values file exists, interactively ask if a default config should be created in its place.
    if [ ! -f "$VALUES" ]; then
        echo ""
        echo "Values file does not exist: $VALUES"
        read -p "Would you like to create a default config file here? (y/N)" choice
        echo ""
        case "$choice" in
            y|Y ) curl "$DEFAULT_VALUES_URL" -Lo "$VALUES"
                  echo "Default configuration created: $VALUES"
                  ;;
            * ) echo "You must create your own values file: $VALUES (using values.yaml as a template.)"
                echo "Or set VALUES=/path/to/values.yaml before subsequent commands."
                exit 1
                ;;
        esac
    else
        echo "Configuration found: $VALUES"
    fi
    echo "Edit this config file to suit your own environment before install/upgrade"

}

helm() {
    ## Redefine all helm commands to run through local tiller instance
    ## https://rimusz.net/tillerless-helm
    HELM=$(which helm)
    exe "$HELM" tiller run "$NAMESPACE" -- helm "$*"
}

kubectl() {
    ## kubectl wrapper that defaults to k8s-lbry namespace, so you don't have to
    ## type as much, but still passes all the provided arguments on to kubectl.
    ## So you can still specify a different namespace, because the client args
    ## are applied last.
    KUBECTL=$(which kubectl)
    exe "$KUBECTL" --namespace "$NAMESPACE" "$*"
}

install-nginx-ingress() {
    ### Install nginx-ingress from stable helm repository
    ### See https://github.com/helm/charts/tree/master/stable/nginx-ingress
    helm install stable/nginx-ingress --namespace "$NAMESPACE" --name nginx-ingress --set nginx-ingress.controller.service.enableHttps="$NGINX_ENABLE_HTTPS" --set tcp.9246="$NAMESPACE/lbrycrd:9246"
}

upgrade-nginx-ingress() {
    ### Upgrade nginx-ingress
    helm upgrade nginx-ingress stable/nginx-ingress --namespace "$NAMESPACE" --set nginx-ingress.controller.service.enableHttps="$NGINX_ENABLE_HTTPS"  --set tcp.9246="$NAMESPACE/lbrycrd:9246"
}

install-cert-manager() {
    ### Install cert-manager from jetstack helm repository
    ### See https://docs.cert-manager.io/en/latest/index.html
    kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.7/deploy/manifests/00-crds.yaml

    helm repo add jetstack https://charts.jetstack.io
    helm repo update

    helm install --name cert-manager --namespace "$CERTMANAGER_NAMESPACE" jetstack/cert-manager --version $CERTMANAGER_VERSION

    kubectl label namespace "$CERTMANAGER_NAMESPACE" certmanager.k8s.io/disable-validation="true"
}

upgrade-cert-manager() {
    ### Upgrade cert-manager
    helm upgrade cert-manager jetstack/cert-manager --namespace "$CERTMANAGER_NAMESPACE" --version $CERTMANAGER_VERSION
}

install() {
    ### Install the k8s-lbry helm chart
    if [ ! -f "$VALUES" ]; then
        echo "Could not find chart values file: $VALUES"
        exit 1
    fi
    helm install "$CHART" --name "$RELEASE" --namespace="$NAMESPACE" -f "$VALUES"
}

upgrade() {
    ### Upgrade the k8s-lbry helm chart
    if [ ! -f "$VALUES" ]; then
        echo "Could not find chart values file: $VALUES"
        exit 1
    fi
    helm upgrade "$RELEASE" "$CHART" --namespace="$NAMESPACE" -f "$VALUES"
}

shell() {
    ### Execute a shell in the running container with helm app name provided by first argument
    (
        if [ "$#" -eq 1 ]; then
            KUBECTL=$(which kubectl)
            POD=$($KUBECTL get --namespace "$NAMESPACE" pod -l app="$1" -o name | sed s+pod/++)
            exe kubectl exec -it "$POD" /bin/bash
        else
            echo "Required arg: helm app name of pod to shell into"
        fi
    )
}

shell-pvc() {
    ### Start a utility container shell with an attached Persistent Volume Claim.
    (
        # From https://gist.github.com/yuanying/3aa7d59dcce65470804ab43def646ab6

        IMAGE="ubuntu:18.04"
        COMMAND="/bin/bash"
        SUFFIX=$(date +%s | shasum | base64 | fold -w 10 | head -1 | tr '[:upper:]' '[:lower:]')

        usage_exit() {
            echo "Usage: $0 [-c command] [-i image] PVC ..." 1>&2
            exit 1
        }

        if [ "$#" -ne 1 ]; then
            usage_exit
        fi

        while getopts i:h OPT
        do
            case $OPT in
                i)  IMAGE=$OPTARG
                    ;;
                c)  COMMAND=$OPTARG
                    ;;
                h)  usage_exit
                    ;;
                \?) usage_exit
                    ;;
            esac
        done
        shift $(($OPTIND - 1))

        VOL_MOUNTS=""
        VOLS=""
        COMMA=""

        for i in $@
        do
            VOL_MOUNTS="${VOL_MOUNTS}${COMMA}{\"name\": \"${i}\",\"mountPath\": \"/pvcs/${i}\"}"
            VOLS="${VOLS}${COMMA}{\"name\": \"${i}\",\"persistentVolumeClaim\": {\"claimName\": \"${i}\"}}"
            COMMA=","
        done

        $(which kubectl) --namespace "$NAMESPACE" run -it --rm --restart=Never --image="${IMAGE}" pvc-mounter-"${SUFFIX}" --overrides "
{
  \"spec\": {
    \"hostNetwork\": true,
    \"containers\":[
      {
        \"args\": [\"${COMMAND}\"],
        \"stdin\": true,
        \"tty\": true,
        \"name\": \"pvc\",
        \"image\": \"${IMAGE}\",
        \"volumeMounts\": [
          ${VOL_MOUNTS}
        ]
      }
    ],
    \"volumes\": [
      ${VOLS}
    ]
  }
}
" -- "${COMMAND}"

    )
}

restart() {
    ### Restart the pod given by a helm app name
    (
        if [ "$#" -eq 1 ]; then
            KUBECTL=$(which kubectl)
            POD=$($KUBECTL get --namespace "$NAMESPACE" pod -l app="$1" -o name | sed s+pod/++)
            exe kubectl delete pod "$POD"
        else
            echo "Required arg: helm app name of pod to restart"
        fi
    )
}


package() {
    ### Create a packaged helm release and upload to the S3 repository
    (
        cd $BASEDIR
        set -e
        if [ "$#" -eq 1 ]; then
            if ! grep "version: $1" Chart.yaml; then
                echo "Chart.yaml version does not match intended package version ($1)."
                exit 1
            fi
        else
            echo "required argument: package version"
            exit 1
        fi

        PACKAGE="k8s-lbry-$1.tgz"

        ## Build Helm package repository and upload to s3
        if which s3cmd > /dev/null; then
            if s3cmd info $PACKAGE_BUCKET > /dev/null; then
                # Download all remote releases, to re-include in new index.yaml
                exe s3cmd sync $PACKAGE_BUCKET .

                # Check if release already exists
                s3_url="$PACKAGE_BUCKET/$PACKAGE"
                if s3cmd info "$s3_url"; then
                    echo "$s3_url already exists. Aborting."
                    exit 1
                fi

                # Package release and rebuild repository
                exe helm dependency update
                exe helm package .
                exe helm repo index .

                # Publish packages to s3
                exe s3cmd put --acl-public index.yaml "$PACKAGE" $PACKAGE_BUCKET
                exe s3cmd put --acl-public charts/*.tgz $PACKAGE_BUCKET/charts/
            else
                echo "s3cmd is not setup, run s3cmd --configure"
                exit 1
            fi
        else
            echo "s3cmd is not installed"
            exit 1
        fi
    )
}

chainquery-mysql-client() {
    ### Access the mysql shell for chainquery
    KUBECTL=$(which kubectl)
    POD=$($KUBECTL -n "$NAMESPACE" get pod -l app=chainquery-mysql -o name | sed s+pod/++)
    if [ ${#POD} -gt 0 ]; then
        kubectl exec -it "$POD" -- mysql -u chainquery -pchainquery
    else
        echo "chainquery-mysql pod not found"
    fi
}

speech-mysql-client() {
    ### Access the mysql shell for speech
    KUBECTL=$(which kubectl)
    POD=$($KUBECTL -n "$NAMESPACE" get pod -l app=speech-mysql -o name | sed s+pod/++)
    if [ ${#POD} -gt 0 ]; then
        kubectl exec -it "$POD" -- mysql -u speech -pspeech
    else
        echo "speech-mysql pod not found"
    fi
}

chainquery-override-snapshot() {
    ### Delete the existing chainquery database and download a snapshot to restore
    read -p "Would you like to DESTROY the existing chainquery database,
and restore from a fresh snapshot? (y/N)  " destroy_chainquery
    case "$destroy_chainquery" in
        y|Y )
            kubectl delete deployments chainquery chainquery-mysql || true
            echo "Please wait.."
            IMAGE="ubuntu:18.04"
            SUFFIX=$(date +%s | shasum | base64 | fold -w 10 | head -1 | tr '[:upper:]' '[:lower:]')
            VOL_MOUNTS="{\"name\": \"chainquery-mysql\",\"mountPath\": \"/pvcs/chainquery-mysql\"}"
            VOLS="{\"name\": \"chainquery-mysql\",\"persistentVolumeClaim\": {\"claimName\": \"chainquery-mysql\"}}"
            COMMAND="rm -rf /pvcs/chainquery-mysql/* && apt-get update && apt-get install -y curl && curl -s ${CHAINQUERY_SNAPSHOT_URL} | tar xvz -C /pvcs/chainquery-mysql/"
            $(which kubectl) --namespace "$NAMESPACE" run -it --rm --restart=Never --image=${IMAGE} pvc-mounter-"${SUFFIX}" --overrides "
{
  \"spec\": {
    \"hostNetwork\": true,
    \"containers\":[
      {
        \"args\": [\"bin/bash\", \"-c\", \"${COMMAND}\"],
        \"stdin\": true,
        \"tty\": true,
        \"name\": \"pvc\",
        \"image\": \"${IMAGE}\",
        \"volumeMounts\": [
          ${VOL_MOUNTS}
        ]
      }
    ],
    \"volumes\": [
      ${VOLS}
    ]
  }
}
"
            echo "Extraction complete"
            ;;
        * ) echo "Aborted."
            ;;
    esac
}

lbrycrd-override-snapshot() {
    ### Delete the existing lbrycrd data and download a snapshot to restore
    read -p "Would you like to DESTROY the existing lbrycrd data,
and restore from a fresh snapshot? (y/N)  " destroy_lbrycrd
    case "$destroy_lbrycrd" in
        y|Y )
            kubectl delete deployments lbrycrd || true
            echo "Please wait.."
            IMAGE="ubuntu:18.04"
            SUFFIX=$(date +%s | shasum | base64 | fold -w 10 | head -1 | tr '[:upper:]' '[:lower:]')
            VOL_MOUNTS="{\"name\": \"lbrycrd\",\"mountPath\": \"/pvcs/lbrycrd\"}"
            VOLS="{\"name\": \"lbrycrd\",\"persistentVolumeClaim\": {\"claimName\": \"lbrycrd\"}}"
            COMMAND="rm -rf /pvcs/lbrycrd/* && apt-get update && apt-get install -y curl && curl -s ${LBRYCRD_SNAPSHOT_URL} | tar xvz -C /pvcs/lbrycrd/"
            $(which kubectl) --namespace "$NAMESPACE" run -it --rm --restart=Never --image=${IMAGE} pvc-mounter-"${SUFFIX}" --overrides "
{
  \"spec\": {
    \"hostNetwork\": true,
    \"containers\":[
      {
        \"args\": [\"bin/bash\", \"-c\", \"${COMMAND}\"],
        \"stdin\": true,
        \"tty\": true,
        \"name\": \"pvc\",
        \"image\": \"${IMAGE}\",
        \"volumeMounts\": [
          ${VOL_MOUNTS}
        ]
      }
    ],
    \"volumes\": [
      ${VOLS}
    ]
  }
}
"
            echo "Extraction complete"
            ;;
        * ) echo "Aborted."
            ;;
    esac
}

logs() {
    ### Watch the logs of a pod by helm app name
    (
        set -e
        if [ "$#" -eq 1 ]; then
            kubectl logs -l app="$1" -f
        elif [ "$#" -eq 2 ]; then
            KUBECTL=$(which kubectl)
            POD=$($KUBECTL get --namespace "$NAMESPACE" pod -l app="$1" -o name | sed s+pod/++)
            kubectl logs "$POD" "$2" -f
        else
            echo "Required arg: app_name"
        fi
    )
}

lbrynet-copy-wallet() {
    ### Copy the lbrynet wallet to a local path for backup
    (
        set -e
        if [ "$#" -eq 1 ]; then
            WALLET=/home/lbrynet/.local/share/lbry/lbryum/wallets/default_wallet
            KUBECTL=$(which kubectl)
            POD=$($KUBECTL -n "$NAMESPACE" get pod -l app=lbrynet -o name | sed s+pod/++)
            kubectl cp "$POD":$WALLET "$1"
            chmod 600 "$1"
            echo "lbrynet wallet copied to $1"
        else
            echo "Required arg: path of backup location for wallet"
        fi
    )
}

speech-lbrynet-copy-wallet() {
    ### Copy the speech-lbrynet wallet to a local path for backup
    (
        set -e
        if [ "$#" -eq 1 ]; then
            WALLET=/home/lbrynet/.local/share/lbry/lbryum/wallets/default_wallet
            KUBECTL=$(which kubectl)
            POD=$($KUBECTL -n "$NAMESPACE" get pod -l app=speech -o name | sed s+pod/++)
            kubectl cp "$POD":$WALLET "$1" -c speech-lbrynet
            chmod 600 "$1"
            echo "lbrynet wallet copied to $1"
        else
            echo "Required arg: path of backup location for wallet"
        fi
    )
}

lbrycrd-cli() {
    ## Run lbrycrd-cli client from inside the running pod outputting to your local terminal
    KUBECTL=$(which kubectl)
    POD=$($KUBECTL -n "$NAMESPACE" get pod -l app=lbrycrd -o name | sed s+pod/++)
    if [ ${#POD} -gt 0 ]; then
        kubectl exec "$POD" -- lbrycrd-cli -rpcuser="$LBRYCRD_RPC_USER" -rpcpassword="$LBRYCRD_RPC_PASSWORD" "$*"
    else
        echo "lbrycrd pod not found"
    fi
}

lbrynet() {
    ## Run lbrynet client from inside the running pod outputting to your local terminal
    KUBECTL=$(which kubectl)
    POD=$($KUBECTL -n "$NAMESPACE" get pod -l app=lbrynet -o name | sed s+pod/++)
    if [ ${#POD} -gt 0 ]; then
        kubectl exec "$POD" -- lbrynet "$*"
    else
        echo "lbrynet pod not found"
    fi
}

speech-lbrynet() {
    ## Run lbrynet client from inside the running pod outputting to your local terminal
    KUBECTL=$(which kubectl)
    POD=$($KUBECTL -n "$NAMESPACE" get pod -l app=speech -o name | sed s+pod/++)
    if [ ${#POD} -gt 0 ]; then
        kubectl exec "$POD" -c speech-lbrynet -- lbrynet "$*"
    else
        echo "lbrynet pod not found"
    fi
}

SUBCOMMANDS_NO_ARGS=(setup install install-nginx-ingress install-cert-manager upgrade
                     upgrade-nginx-ingress upgrade-cert-manager chainquery-mysql-client
                     speech-mysql-client chainquery-override-snapshot lbrycrd-override-snapshot
                     setup-alias)

SUBCOMMANDS_PASS_ARGS=(helm kubectl shell shell-pvc restart package logs lbrynet-copy-wallet lbrynet speech-lbrynet-copy-wallet speech-lbrynet lbrycrd-cli completion)

completion() {
    if [ "$#" -eq 1 ] && [ "$1" == "bash" ]; then
        cat <<EOF
__delegate_k8s_lbry() {
    alias kubectl="kubectl --namespace=$NAMESPACE"
    local cur subs
    cur="\${COMP_WORDS[COMP_CWORD]}" # partial word, if any
    subs="${SUBCOMMANDS_NO_ARGS[*]} ${SUBCOMMANDS_PASS_ARGS[*]}"
    if [[ \${COMP_CWORD} -gt 1 ]]; then
        # complete subcommands
        _command \${@: -1}
    else
        # complete with the list of subcommands
        COMPREPLY=( \$(compgen -W "\${subs}" -- \${cur}) )
    fi
}
if [[ $(type -t compopt) = "builtin" ]]; then
    complete -o default -F __delegate_k8s_lbry $RUN_ALIAS
else
    complete -o default -o nospace -F __delegate_k8s_lbry $RUN_ALIAS
fi
EOF
    else
        echo "## I only know how to do completion for the bash shell."
        echo "## Try '$0 completion bash' instead."
    fi
}

setup-alias() {
    if [[ $SHELL != */bash ]]; then
        echo "It looks like you are currently running $SHELL";
        echo "This tool only supports bash."
        echo ""
        echo "You will need to setup an alias in your own shell called \"$RUN_ALIAS\" for $BASEDIR/run.sh"
        echo ""
        read -p "Would you like to setup the alias for bash anyway? (Y/n)" choice
        case "$choice" in
            y|Y )
                echo "Note: You will need to run bash as a subshell before running $RUN_ALIAS"
                ;;
            * ) echo "Aborting" && exit 1
                ;;
        esac
        echo ""
    fi
    $(which kubectl) completion bash > "$BASEDIR"/completion.bash.inc
    $(which helm) completion bash >> "$BASEDIR"/completion.bash.inc
    completion bash >> "$BASEDIR"/completion.bash.inc

    if [[ -z $K8S_LBRY_HOME ]] && ! grep "K8S_LBRY_HOME" "$HOME"/.bashrc > /dev/null; then
        echo "K8S_LBRY_HOME not set."
        read -p "Would you this script to edit $HOME/.bashrc to add tab completion support? (y/N) " choice
        case "$choice" in
            y|Y )
                cat <<EOF >> "$HOME"/.bashrc

## Enable bash completion
if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

## k8s-lbry alias and tab completion
K8S_LBRY_HOME=$BASEDIR
alias $RUN_ALIAS=\$K8S_LBRY_HOME/run.sh
if [ -f \$K8S_LBRY_HOME/completion.bash.inc ]; then
   source \$K8S_LBRY_HOME/completion.bash.inc
fi
EOF
                echo "Created new alias: $RUN_ALIAS"
                echo "To use the new alias, run \"source ~/.bashrc\" or just close your terminal session and restart it."
                ;;
            * ) echo "Aborting" && exit 1;;
        esac
    else
        echo "K8S_LBRY_HOME environment already setup. Nothing left to do."
    fi
}

if printf '%s\n' ${SUBCOMMANDS_NO_ARGS[@]} | grep -q -P "^$1$"; then
    ## Subcommands that take no arguments:
    (
        set -e
        if [ "$#" -eq 1 ]; then
            $*
        else
            echo "$1 does not take any additional arguments"
        fi
    )
elif printf '%s\n' ${SUBCOMMANDS_PASS_ARGS[@]} | grep -q -P "^$1$"; then
    ## Subcommands that pass all arguments:
    (
        set -e
        $*
    )
else
    if [[ $# -gt 0 ]]; then
        echo "## Invalid command: $1"
    else
        echo "## Must specify a command:"
    fi
    echo ""
    echo "##   $0 setup"
    echo "##     - Setup dependencies"
    echo ""
    echo "##   $0 install-nginx-ingress"
    echo "##     - Deploy nginx-ingress chart"
    echo ""
    echo "##   $0 install-cert-manager"
    echo "##     - Deploy cert-manager chart"
    echo ""
    echo "##   $0 install"
    echo "##     - Deploy main k8s-lbry chart"
    echo ""
    echo "##   $0 upgrade"
    echo "##     - Upgrade an existing release"
    echo ""
    echo "##   $0 shell <app>"
    echo "##     - execute shell into running helm application pod"
    echo ""
    echo "##   $0 shell-pvc [-c command] [-i image] PVC"
    echo "##     - run a utility shell with the named PVC mounted in /pvcs"
    echo ""
    echo "##   $0 helm <cmd> [...] "
    echo "##     - run any helm command (through helm-tiller wrapper)"
    echo ""
    echo "##   $0 kubectl <cmd> [...]"
    echo "##     - run any kubectl command (defaulting to configured namespace)"
    echo ""
    echo "##   $0 chainquery-mysql-client"
    echo "##     - run mysql shell for chainquery database"
    echo ""
    echo "##   $0 speech-mysql-client"
    echo "##     - run mysql shell for speech database"
    echo ""
    echo "##   $0 chainquery-override-snapshot"
    echo "##     - Restore chainquery database from snapshot"
    echo ""
    echo "##   $0 lbrycrd-override-snapshot"
    echo "##     - Restore lbrycrd database from snapshot"
    echo ""
    echo "##   $0 logs <app> [container]"
    echo "##     - Stream the logs for the pod running the helm app name provided"
    echo "##       (specify which container if the pod has more than one.)"
    echo ""
    echo "##   $0 lbrynet-copy-wallet <local-path>"
    echo "##     - Backup the lbrynet wallet file to a local path"
    echo ""
    echo "##   $0 lbrynet <args ... >"
    echo "##     - Run lbrynet client inside running lbrynet pod"
    echo ""
    echo "##   $0 speech-lbrynet-copy-wallet <local-path>"
    echo "##     - Backup the speech-lbrynet wallet file to a local path"
    echo ""
    echo "##   $0 speech-lbrynet <args ... >"
    echo "##     - Run speech-lbrynet client inside running speech pod"
    echo ""
    echo "##   $0 setup-alias"
    echo "##     - Setup bash alias and tab completion for run.sh"
    echo ""
    exit 1
fi
