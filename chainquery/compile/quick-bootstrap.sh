#!/usr/bin/env bash

## TODO: Be Polite and ask for confirmation.
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
## TODO: Add dependency checker.
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
  docker
  docker-compose
)

## TODO: Check for docker and docker-compose
function check_deps() {
for i in "${!DEPENDENCIES[@]}"; do
  echo ${DEPENDENCIES[$i]}"_KEY"
  ## Indirect references http://tldp.org/LDP/abs/html/ivr.html
  eval TESTDEP=\$"${DEPENDENCIES[$i]}"
  test_for_deps $TESTDEP
done
}

function get_checkpoint() {
  ## Get DB Checkpoint data.
  echo Asked to get the latest checkpoint data, downloading latest checkpoint.
  echo This data is fairly large so this saves you a few days of parsing the LBRY blockchain.
  docker run -v $(pwd)/:/download --rm leopere/axel-docker http://chainquery-data.s3.amazonaws.com/chainquery-data.zip -o ./chainquery.zip
}

#################################
## The real action begins here ##
#################################
## TODO: Add ways to get into and out of a bind here.
case $1 in
  getdata )
    if [[ -f ./chainquery.zip ]]; then
      echo "Found a copy of ./chainquery.zip already in your system."
      echo "We recommend that you delete this data before proceeding and grab a fresh copy."
      QandA "rm -f ./chainquery.zip"
      get_checkpoint
    else
      get_checkpoint
    fi
    ;;
  extract )
    ## Unpack the data again if need be.
    echo Asked to unpack chainquery.zip if downloaded.
    if [[ -f ./chainquery.zip ]]; then
      docker run -v $(pwd)/:/data --rm leopere/unzip-docker ./chainquery.zip
    else
      echo "Could not extractas chainquery.zip did not exist."
      echo "Feel free to execute './quick-bootstrap.sh getdata' first next time."
    fi
    ;;
  cleanup )
    ## Remove any junk here.
    echo Asked to clean up leftover chainquery.zip to save on disk space.
    rm chainquery.zip
    ;;
  reset )
    ## Give up on everything and try again.
    ## TODO: Make it very obvious with a nice little Y/N prompt that you're about to trash your settings and start over.
    echo "Agressively Killing all chainquery and dependency containers."
    echo "executing: docker-compose kill"
    docker-compose kill
    echo "Cleaning up stopped containers."
    echo "executing: docker-compose rm -f"
    docker-compose rm -f
    rm -Rf ./data
    rm -f ./chainquery.zip
    ;;
  start )
    ## Unsupported start command to start containers.
    ## You can use this if you want to start this thing gracefully.
    ## Ideally you would not use this in production.
    echo "Asked to start chainquery gracefully for you."
    echo "executing: docker-compose up -d mysql"
    docker-compose up -d mysql
    echo "giving mysql some time to establish schema, crypto, users, permissions, and tables"
    sleep 30
    echo "Starting Chainquery"
    echo "executing: docker-compose up -d chainquery"
    docker-compose up -d chainquery
    ## TODO: verify chainquery instance is up and healthy, this requires a functional HEALTHCHECK
    echo "This should have chainquery up and running, currently theres no checks in this function to verify this however."
    echo "Do feel free to execute 'docker-compose ps' to verify if its running and not restarting or exited."
    echo "Final Note: You should try to use the docker-compose commands in the tutorial at https://github.com/lbryio/lbry-docker/blob/master/chainquery/README.md"
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
    echo "./quick-boostrap.sh {Parameter}"
    echo "Example: ./quick-bootstrap.sh getdata # Downloads the latest Chainquery checkpoint data from a LBRYio official aws instance."
    echo ""
    echo ""
    echo "=================================================="
    echo "Usage example and available parameters"
    echo "=================================================="
    echo ""
    echo "getdata # This function grabs the latest Chainquery checkpoint data."
    echo "extract # Unpacks the chainquery data into the correct directory. ./data/"
    echo "cleanup # Removes chainquery.zip"
    echo "reset   # Reset the state of these containers entirely, use if all else fails."
    echo ""
    echo ""
    echo "=================================================="
    echo "=================================================="
    echo "Any other functions that are not documented here are not intended for public use."
    echo "    These functions are included in this repository to keep things in one place."
    ;;
esac
