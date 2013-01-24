#!/usr/bin/env bash

for t in $(ls test_*.py)
do
    echo ">> Running '${t}'..."
    ./${t}
done

