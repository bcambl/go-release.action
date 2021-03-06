#!/bin/sh

set -eux

GOMODFILE="$GITHUB_WORKSPACE/go.mod"
if [[ -f "$GOMODFILE" ]]; then
    export GO111MODULE=on
fi

PROJECT_ROOT="/go/src/github.com/${GITHUB_REPOSITORY}"
PROJECT_NAME=$(basename $GITHUB_REPOSITORY)

EXT=''
if [ $GOOS == 'windows' ]; then
  EXT='.exe'
fi

mkdir -p $PROJECT_ROOT
rmdir $PROJECT_ROOT
ln -s $GITHUB_WORKSPACE $PROJECT_ROOT
cd $PROJECT_ROOT
go get -v ./...
go build -v -ldflags "-w -s -extldflags '-static'" -o $PROJECT_NAME$EXT .
upx -9 $PROJECT_NAME$EXT
