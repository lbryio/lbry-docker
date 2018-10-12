#!/usr/bin/env bash
source ./db-seed.sha
echo "Checking if seeding is needed"
if [[ -d !./data/db/chainquery ]]; then
  echo "It appears as though you don't currently have the db created."
  echo "Downloading the Chainquery DB checkpoint data."
  wget -O data.zip https://s3bucketURL/here.zip
  if [[ -f !./data.zip ]]; then
    echo "It seems that downloading the checkpoint data failed."
  else
    echo "Checkpoint data received verifying download integrity."
    if ! echo "$CHECKSUM data.zip" | sha256sum -c -; then
      echo "Checksum failed, somehow the checkpoint data doesn't match what it's supposed to." >&2
      exit 1
    else
      echo "clearing ./data directory in case it contains something strange."
      echo "Uncompressing chainquery checkpoint data."
      rm -Rf ./data
      unzip ./data.zip
      if [[ -d !./data/db/chainquery ]]; then
        echo "Something went wrong with uncompressing checkpoint data."
        exit 1
      else
        echo "Checkpoint data has been successfully obtained you can now run the Chainquery appliance."
      fi
    fi
  fi
fi
