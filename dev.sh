#!/bin/bash


if [ ! -f config.conf ]; then
    echo "No config with credentials present"
    exit
else
    source config.conf
fi

IMAGE=rjupyter-container:latest
RUNARGS=" -v $PWD:/mywork -v $PWD/source/util:/util"
RUNPORTS=" -p 8787:8787 -p 4040:4040"


# Build the image.
function build {
  $SUDO docker build --no-cache -t ${IMAGE} .
}

function build-with-cache {
  $SUDO docker build -t ${IMAGE} .
}

function run {
    $SUDO docker run --rm \
                ${RUNARGS} \
                -e AWS_ACCESS_KEY_ID \
                -e AWS_SECRET_ACCESS_KEY \
                -it "${IMAGE}"  "$@"

}

function runWports {
    $SUDO docker run --rm \
                ${RUNARGS} \
                ${RUNPORTS} \
                -e AWS_ACCESS_KEY_ID \
                -e AWS_SECRET_ACCESS_KEY \
                -it "${IMAGE}"  "$@"

}

function terminal {
	run bash
}


function rstudio {

    if [ ! -f rstudio-server-1.1.383-amd64.deb ]; then
        wget https://download2.rstudio.org/rstudio-server-1.1.383-amd64.deb
    fi

    cmd="cd /mywork \
         && echo 'y' | gdebi rstudio-server-1.1.383-amd64.deb  \
         && cd /home/rstudio  \
         && ln -s /mywork work  \
         && bash"

    runWports sh -c "$cmd"

}

function notebook {

    cmd="jupyter notebook --ip 0.0.0.0 --no-browser --allow-root --port=8787 && bash"
	runWports sh -c "$cmd"

}

