#!/bin/sh

#
# Uses debsecan to list CVEs for installed packages in a Debian Docker image.
#
# Usage: ./debsecan.sh docker_image [debsecan_args...]
#
# Examples:
# ./debsecan.sh debian:jessie --format detail
# ./debsecan.sh debian:jessie --suite jessie --only-fixed
#

# Exit immediately if a command exits with a non-zero status:
set -e

# Removes the temporary docker container:
cleanup() {
  docker rm -vf debsecan_target > /dev/null
}

if [ $# -eq 0 ]; then
  echo 'Usage: ./debsecan.sh docker_image [debsecan_args...]' >&2
	exit 1
fi

# Create a temporary docker container to expose the dpkg directory:
docker run --entrypoint true -v /var/lib/dpkg --name debsecan_target "$1"

# Run the cleanup function on SIGINT or SIGTERM:
trap 'cleanup' INT TERM

# Remove the docker_image from the arguments list:
shift

# Run debsecan with the given arguments:
docker run --rm --volumes-from=debsecan_target qipp/debsecan "$@"

cleanup