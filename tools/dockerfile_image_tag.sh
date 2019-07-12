#!/bin/bash

### Find the latest docker image id and tag it in git
### Usage:
###   ./dockerfile_image_tag.sh DOCKER_ORG DOCKER_REPO DOCKER_TAG
### Example:
###   ./dockerfile_image_tag.sh lbry lbrycrd linux-x86_64-production

exe() { ( echo "## $*"; $*; ) }

SCRIPT_NAME=$0
SCRIPT_PATH="$( cd "$(dirname "$0")" && pwd -P )"
GIT_PATH="$(dirname "$SCRIPT_PATH")"
GIT_REMOTE=${GIT_REMOTE:-origin}

if ! which jq > /dev/null; then
    echo "You need to install jq - https://stedolan.github.io/jq/"
    exit 1
fi

if ! which curl > /dev/null; then
    echo "You need to install curl"
    exit 1
fi

get_docker_tags() {
    # Thank you minamijoyo - https://stackoverflow.com/a/41830007/56560
    if [ "$#" -ne 3 ]; then
        echo "Wrong args: get_docker_tags DOCKER_ORG DOCKER_REPO DOCKER_TAG"
    fi

    ORG=$1
    REPOSITORY=$2
    TARGET_TAG=$3

    echo "Contacting docker hub ..." >&2
    # get authorization token
    TOKEN=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:$ORG/$REPOSITORY:pull" | jq -r .token)

    # find all tags
    ALL_TAGS=$(curl -s -H "Authorization: Bearer $TOKEN" https://index.docker.io/v2/$ORG/$REPOSITORY/tags/list | jq -r .tags[])

    # get image digest for target
    TARGET_DIGEST=$(curl -s -D - -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.docker.distribution.manifest.v2+json" https://index.docker.io/v2/$ORG/$REPOSITORY/manifests/$TARGET_TAG | grep Docker-Content-Digest | cut -d ' ' -f 2)

    # for each tags
    for tag in ${ALL_TAGS[@]}; do
        # get image digest
        digest=$( curl -s -D - -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.docker.distribution.manifest.v2+json" https://index.docker.io/v2/$ORG/$REPOSITORY/manifests/$tag | grep Docker-Content-Digest | cut -d ' ' -f 2)

        # check digest
        if [[ $TARGET_DIGEST = $digest ]]; then
            # Echo to stderr to be helpful to humans:
            echo "$ORG/$REPOSITORY:$tag $digest" >&2
            # Echo to stdout to use as a script:
            echo $digest
        fi
    done
}

check_git_status(){
    # Check if the git stage is clear, on master branch, and up to date with the remote.
    (
        set -e
        echo "Checking git status ..."
        cd $GIT_PATH
        if [[ $(git branch --show-current) != "master" ]]; then
            echo "You are not on the master branch."
            echo "Please change to the master branch before running this."
            exit 1
        fi
        if ! git remote show origin | grep -e "^\W*master .*\(up to date\)" > /dev/null; then
            echo "Your local branch is behind in the history of the remote"
            echo "Please do a git pull before running this."
            exit 1
        fi
        if git status --porcelain | grep -e "^A " > /dev/null; then
            git status
            echo "You have staged files for commit in git: $GIT_PATH"
            echo "Please stash or commit those changes before running this. "
            exit 1
        fi
    )
}

main() {
    if [ "$#" -ne 3 ]; then
        echo "run: $SCRIPT_NAME DOCKER_ORG DOCKER_REPO DOCKER_TAG"
        echo "eg : $SCRIPT_NAME lbry lbrycrd linux-x86_64-production"
        exit 1
    fi
    DOCKER_ORG=$1 DOCKER_REPO=$2; DOCKER_TAG=$3

    # Check if the git stage is clear, error if not:
    check_git_status

    # Get the current Docker tag id and sanity check:
    CURRENT_IMAGE_ID=$(get_docker_tags $DOCKER_ORG $DOCKER_REPO $DOCKER_TAG | cut -d ':' -f 2 | sed 's/\r$//g')
    echo "CURRENT_IMAGE_ID=$CURRENT_IMAGE_ID"
    if ! (echo $CURRENT_IMAGE_ID | grep -e "^[A-Fa-f0-9]\{64\}$" > /dev/null); then
        echo "Bad image id: $CURRENT_IMAGE_ID"
        echo -n $CURRENT_IMAGE_ID | hexdump -C
        exit 1
    fi

    # Tag the current git HEAD with the docker image id:
    GIT_COMMIT=$(git -C $GIT_PATH rev-parse HEAD)
    GIT_TAG=$DOCKER_ORG-$DOCKER_REPO-$DOCKER_TAG-$CURRENT_IMAGE_ID
    echo "GIT_COMMIT=$GIT_COMMIT"
    echo "GIT_TAG=$GIT_TAG"
    git -C $GIT_PATH tag $GIT_TAG $GIT_COMMIT && \
        echo "Pushing tags to $GIT_REMOTE ..." && \
        (git push --tags --dry-run 2>&1 | grep "\[new tag\]") && \
        git -C $GIT_PATH push --tags $GIT_REMOTE
}

main $*

