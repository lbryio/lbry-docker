#!/usr/bin/env bash

## Be Polite and ask for permission.
function QandA() {
  read -r -p "Continue with $1 [y/N] " response
  response=${response,,}    # tolower
  if [[ "$response" =~ ^(yes|y)$ ]]; then
    echo "Continuing with this."
    eval $1
  else
    echo "Skipping the $1."
  fi
}

## Check your $PATH for required dependencies.
## Stop and complain for now, later automagically install them.
function test_for_deps() {
  ## Test for Command
  if ! [ -x "$(command -v $1)" ]; then
    echo "Error: $1 is not installed." >&2
    echo "You must have $1 installed."
  else
    echo "Info: $1 is installed."
  fi
}

## Declare Linux app dependencies to check for.
DEPENDENCIES=(
  wget
  unzip
  docker
)
## Recommended.
BONUS_DEPENDENCIES=(
  docker-compose
)

function check_deps() {
for i in "${!DEPENDENCIES[@]}"; do
  echo ${DEPENDENCIES[$i]}"_KEY"
  ## Indirect references http://tldp.org/LDP/abs/html/ivr.html
  eval TESTDEP=\$"${DEPENDENCIES[$i]}"
  test_for_deps $TESTDEP
done
}

## Add ways to get into and out of a bind here.
case $1 in
  getdata )
    ## Get DB Checkpoint data.
    axel -a -n 6 http://chainquery-data.s3.amazonaws.com/chainquery-data.zip -o ./chainquery.zip
    ;;
  extract )
    ## Unpack the data again if need be.
    unzip ./chainquery.zip
    ;;
  cleanup )
    ## Remove any junk here.
    rm chainquery.zip
    ;;
  reset )
    ## Give up on everything and try again.
    # rm -Rf ./data
    # rm -f ./chainquery.zip
    ;;
  compress-latest-checkpoint-data )
    ## This is not intended for public use.
    docker-compose stop chainquery
    docker-compose stop mysql
    sudo zip -r chainquery-data.zip data
    docker-compose up -d mysql
    sleep 30
    docker-compose up -d chainquery
    ;;
  upload-latest-checkpoint-data )
    ## This is not intended for public use.
    aws s3 cp ./chainquery-data.zip s3://chainquery-data/chainquery-data.new
    aws s3 rm s3://chainquery-data/chainquery-data.zip
    aws s3 mv s3://chainquery-data/chainquery-data.new s3://chainquery-data/chainquery-data.zip
    ;;
  * )
    echo "=================================================="
    echo "You look like you need usage examples let me help."
    echo "=================================================="
    echo "Add documentation on script params HERE"
    ;;
esac
