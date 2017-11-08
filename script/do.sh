#!/bin/bash
cd "$(dirname "$0")/.." || exit 111
source ./script/bootstrap || exit 111


REPO_NAME=${1}
UUID=${2}
BOOK_TITLE=${3}
LICENSE=${4}
ROOT='.'
TEMP_DIR=${ROOT}/zips

ZIP_FILE=${TEMP_DIR}/${UUID}.zip
JSON_DOWNLOAD_FILE=${TEMP_DIR}/${UUID}.download.json
JSON_BOOK_FILE=${TEMP_DIR}/${UUID}.book.json
UUID_DIR=${TEMP_DIR}/${UUID}
REPO_PATH=../${REPO_NAME}

# By default the license is CC-BY
if [[ -z ${LICENSE} ]]; then
  LICENSE='CC-BY'
fi

# Check that the book repo is checked out.
[[ -d "${REPO_PATH}" ]] || die "ERROR: ${REPO_PATH} was not found. you need to check out the book first by doing 'git clone https://github.com/philschatz/${REPO_NAME}.git' or making a fork and then cloning it."


mkdir -p ${TEMP_DIR}

if [[ "${NO_DOWNLOAD}" != "true" ]]; then
  OLD_VERSION_NUMBER=""
  if [ -f "${JSON_BOOK_FILE}" ]; then
    OLD_VERSION_NUMBER=$(cat ${JSON_BOOK_FILE} | jq --raw-output '.version')
  fi

  echo "Find the latest version of ${1}"
  curl --progress-bar --location http://archive.cnx.org/extras/${UUID} > ${JSON_DOWNLOAD_FILE}
  curl --progress-bar --location http://archive.cnx.org/contents/${UUID} > ${JSON_BOOK_FILE}

  # echo "Find the version number"
  VERSION_NUMBER=$(cat ${JSON_BOOK_FILE} | jq --raw-output '.version')
  echo "Version number is ${VERSION_NUMBER}"

  if [ "${VERSION_NUMBER}" = "" ]; then
    echo "Skipping because there was a problem downloading the JSON file"
    exit 0
  fi

  if [ "${OLD_VERSION_NUMBER}" = "${VERSION_NUMBER}" ]; then
    echo "Skipping because version numbers are the same ${VERSION_NUMBER}"
    exit 0
  else
    echo "Generating because version numbers are different. Previous: '${OLD_VERSION_NUMBER}' new: '${VERSION_NUMBER}'"
  fi

  # echo "Find the URL for the latest version of the ZIP"
  ZIP_URL=$(cat ${JSON_DOWNLOAD_FILE} | jq --raw-output '.downloads | map(select(.format == "Offline ZIP")) | .[0].path')
  ZIP_URL="http://cnx.org${ZIP_URL}"


  echo "Follow redirects and download the zip file at ${ZIP_URL}"
  curl --progress-bar --location ${ZIP_URL} > ${ZIP_FILE}

  echo "Clear the dir before unzipping (so it does not prompt)"
  rm -rf ${UUID_DIR}

  echo "Pull Remote changes"
  FOO=$(cd ${REPO_PATH} && git pull)

  echo "Unzip the file"
  unzip -o ${ZIP_FILE} -d ${UUID_DIR} > /dev/null
fi

echo "The unzipped files are all in a dir named col_*_complete"
COMPLETE_DIR=$(find ${UUID_DIR}/* | head -1)

if [[ -z ${COMPLETE_DIR} ]]; then
  die "Error downloading the zip. Skipping ${REPO_PATH}"
fi

do_progress_quiet "Converting collection" \
  ${ROOT}/script/convert-collection.sh ${COMPLETE_DIR} ${REPO_PATH} ${VERSION_NUMBER}
# test $? != 0 && (die "converting book to markdown. Exiting")

echo "
# Dependencies
markdown:         kramdown

# Permalinks
#permalink:        pretty

# Setup
title:            '${BOOK_TITLE}'
tagline:          'from http://cnx.org/contents/${UUID}@${VERSION_NUMBER} (${LICENSE})'
url:              https://github.com/philschatz/${REPO_NAME}
origin:           http://cnx.org/contents/${UUID}@${VERSION_NUMBER}

author:
  name:           'Openstax'
  url:            https://github.com/openstax

paginate:         5

# Custom vars
version:          ${VERSION_NUMBER}

bookviewer:       http://philschatz.com/book-viewer
" > ${REPO_PATH}/_config.yml


if [[ -n "${COMMIT_MESSAGE}" ]]; then
  COMMIT_MESSAGE_THIS_REPO="${COMMIT_MESSAGE}"
else
  COMMIT_MESSAGE_THIS_REPO="update to ${VERSION_NUMBER}"
fi

# echo "Commit the results"
# FOO=$(cd ${REPO_PATH} && git add --all . && git commit -m "${COMMIT_MESSAGE_THIS_REPO}")
# echo ${FOO}
#
# if [[ "${AUTO_PUSH}" -eq "true" ]]; then
#   echo "==> Pushing to GitHub"
#   FOO=$(cd ${REPO_PATH} && git push || exit 1)
#   echo ${FOO}
# fi

echo "==> Completed ${REPO_NAME}"
