#!/bin/bash
if [ -e vsr-models.sh ]
then
    source vsr-models.sh
else
    exit 1
fi

vsr-models-run-scripts sh -c "$@"
