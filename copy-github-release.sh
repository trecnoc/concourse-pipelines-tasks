#!/usr/bin/env bash

set -e
set -o pipefail

RELEASE_INPUT=release-input
ARTIFACTS_OUTPUT=artifacts
RELEASE_NOTES=release.md

VERSION=$(cat ${RELEASE_INPUT}/version)
OUTPUT=${ARTIFACTS_OUTPUT}/${VERSION}

if [[ -z "${SKIP_VERSION_SUBDIR}" ]]; then
  printf "Creating version subdirectory: %s\n" ${VERSION}
  mkdir -p ${OUTPUT}
else
  OUTPUT=${ARTIFACTS_OUTPUT}
  RELEASE_NOTES="${RELEASE_NOTE_PREFIX}-${VERSION}-release.md"
  printf "Not creating version subdirectory and overriding release notes filename to: %s\n" ${RELEASE_NOTES}
fi

printf "\nCopying artifact(s)\n"
find ${RELEASE_INPUT} \
  -type f \
  ! -name "body" \
  ! -name "commit_sha" \
  ! -name "tag" \
  ! -name "url" \
  ! -name "version" \
  ! -name "source.tar.gz" \
  ! -name "source.zip" \
  -exec cp -v {} ${OUTPUT} \;

if [[ ! -z "${UNCOMPRESS_ARTIFACTS}" ]]; then
  printf "\nUncompressing .tgz and .zip artifacts\n"

  pushd artifacts > /dev/null

  find . -name '*.tgz' | while read file; do
    printf "Extracting '%s'\n" ${file}
    pushd $(dirname ${file}) > /dev/null
    tar -xzf $(basename ${file})
    rm $(basename ${file})
    popd > /dev/null
  done

  find . -name '*.zip' | while read file; do
    printf "Extracting '%s'\n" ${file}
    pushd $(dirname ${file}) > /dev/null
    unzip -q $(basename ${file})
    rm $(basename ${file})
    popd > /dev/null
  done

  popd > /dev/null
fi

if [[ -f ${RELEASE_INPUT}/body ]]; then
  printf "\nAdding release notes\n"
  cp ${RELEASE_INPUT}/body ${OUTPUT}/${RELEASE_NOTES}
fi
