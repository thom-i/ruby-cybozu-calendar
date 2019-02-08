#!/bin/bash
export PATH="/usr/local/bin:$PATH"

DIR=`dirname $0`
cd $DIR

bundle exec ruby ./$1