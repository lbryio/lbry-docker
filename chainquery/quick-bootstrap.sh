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

## Add ways to get into and out of a bind here.
case $1 in
  getdata )
    ## Get DB Checkpoint data.
    echo Asked to get the latest checkpoint data from
    docker run -v $(pwd)/:/download --rm leopere/axel-docker http://chainquery-data.s3.amazonaws.com/chainquery-data.zip -o ./chainquery.zip
    ;;
  extract )
    ## Unpack the data again if need be.
    echo Asked to unpack chainquery.zip if downloaded.
    # TODO: add some magic here which will check for the presence of chainquery.zip and notify if its already gone.
    docker run -v $(pwd)/:/data --rm leopere/unzip-docker ./chainquery.zip
    ;;
  cleanup )
    ## Remove any junk here.
    echo Asked to clean up leftover chainquery.zip to save on disk space.
    rm chainquery.zip
    ;;
  reset )
    ## Give up on everything and try again.
    ## TODO: Make it very obvious with a nice little Y/N prompt that you're about to trash your settings and start over.
    docker-compose kill
    docker-compose rm -f
    rm -Rf ./data
    rm -f ./chainquery.zip
    ## TODO: Consider moving this somewhere as a function.
    # docker-compose up -d mysql
    # sleep 30
    # docker-compose up -d chainquery
    ;;
  start )
    ## Unsupported start command to start containers.
    ## You can use this if you want to start this thing gracefully.
    ## Ideally you would not use this in production.
    echo "Asked to start chainquery gracefully for you."
    docker-compose up -d mysql
    echo "giving mysql some time to establish schema, crypto, users, permissions, and tables"
    sleep 30
    echo "Starting Chainquery"
    docker-compose up -d chainquery
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
