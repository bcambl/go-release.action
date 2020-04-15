#!/bin/sh

set -eu

/build.sh

EVENT_DATA=$(cat $GITHUB_EVENT_PATH)
#echo $EVENT_DATA | jq .
UPLOAD_URL=$(echo $EVENT_DATA | jq -r .release.upload_url)
UPLOAD_URL=${UPLOAD_URL/\{?name,label\}/}
RELEASE_NAME=$(echo $EVENT_DATA | jq -r .release.tag_name)
PROJECT_NAME=$(basename $GITHUB_REPOSITORY)
NAME="${PROJECT_NAME}_${RELEASE_NAME}_${GOOS}_${GOARCH}"

BIN_EXT=''
ARCHIVE_CMD='tar cvfz'
ARCHIVE_EXT='.tar.gz'
CONTENT_TYPE='application/gzip'

if [ $GOOS == 'windows' ]; then
  EXT='.exe'
  ARCHIVE_CMD='zip'
  ARCHIVE_EXT='.zip'
  CONTENT_TYPE='application/zip'
fi

${ARCHIVE_CMD} tmp${ARCHIVE_EXT} "${PROJECT_NAME}${BIN_EXT}"
CHECKSUM=$(md5sum tmp${ARCHIVE_EXT} | cut -d ' ' -f 1)

curl \
  -X POST \
  --data-binary @tmp${ARCHIVE_EXT} \
  -H 'Content-Type: ${CONTENT_TYPE}' \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "${UPLOAD_URL}?name=${NAME}${ARCHIVE_EXT}"

curl \
  -X POST \
  --data $CHECKSUM \
  -H 'Content-Type: text/plain' \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "${UPLOAD_URL}?name=${NAME}_checksum.txt"
