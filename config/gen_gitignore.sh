#!/usr/bin/env bash

FILE=".gitignore"
BASE=".gitignore_template"

cp $BASE $FILE

for ENTRY in $(git ls-tree main --name-only --full-name); do
  echo "!$ENTRY" >> $FILE
done
