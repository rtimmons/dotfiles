#!/usr/bin/env bash

set -eou pipefail

if [ -d build ]; then
    echo "Existing build directory $PWD/build. Nothing to do"
    exit 0
fi

set -x
    mkdir -p build
    mv WorkloadOutput build
    pushd build/WorkloadOutput
        rm reports
        ln -s ./reports* ./reports
    popd
set +x


