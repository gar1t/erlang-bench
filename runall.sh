#!/usr/bin/env sh
for f in ./*.escript; do echo ""; echo "$f"; "$f"; done
