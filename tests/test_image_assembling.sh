#!/usr/bin/env bash
# Copyright (c) 2020 Foundries.io
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail

# Examples
# Container build's assemble-system-image use-case: ./tests/test_image_assembling.sh $FACTORY $OSF_TOKEN $OUT_IMAGE_DIR $BUILD_NUMB
# API/fioctl use-cases:
# all apps: sudo ./tests/test_image_assembling.sh $FACTORY $OSF_TOKEN $PWD/out-image/ "" intel-corei7-64-lmp-1161 "" "restorable" $PWD/work-dir
# apps shortlisting: sudo ./tests/test_image_assembling.sh $FACTORY $OSF_TOKEN $PWD/out-image/ "" intel-corei7-64-lmp-1161 "app-05" "compose" $PWD/work-dir

# Input params
FACTORY=$1
OSF_TOKEN=$2
OUT_IMAGE_DIR=$3
TARGET_VERSION=$4
TARGETS=${5-""}
APP_SHORTLIST=${6-""}
COMPOSE_APP_TYPE=${7=""}
WORK_DIR="${8-$(mktemp -d -t asseble-image-XXXXXXXXXX)}"
echo ">> Work dir: ${WORK_DIR}"

SECRETS=$WORK_DIR/secrets # directory to store secrets,
#    - /secrets/osftok - file containing OSF_TOKEN
if [[ ! -d ${SECRETS} ]]; then
  mkdir "${SECRETS}"
fi
echo -n "${OSF_TOKEN}" > "${WORK_DIR}/secrets/osftok"

FETCH_DIR="${WORK_DIR}/fetch-dir"
if [[ ! -d ${FETCH_DIR} ]]; then
  mkdir "${FETCH_DIR}"
fi

CMD=./assemble-system-image.sh

docker run -v -it --rm --privileged \
  -e FACTORY="$FACTORY" \
  -e HOME=/home/test \
  -e FETCH_DIR=/fetch-dir \
  -e OUT_IMAGE_DIR=/out-image-dir \
  -e TARGET_VERSION="${TARGET_VERSION}" \
  -e TARGETS="${TARGETS}" \
  -e APP_SHORTLIST="${APP_SHORTLIST}" \
  -e COMPOSE_APP_TYPE="${COMPOSE_APP_TYPE}" \
  -v "$PWD":/ci-scripts \
  -v "$SECRETS":/secrets \
  -v "$OUT_IMAGE_DIR":/out-image-dir \
  -v "$FETCH_DIR":/fetch-dir \
  -w /ci-scripts \
  -u "$(id -u ${USER})":"$(id -g ${USER})" \
  foundries/lmp-image-tools "${CMD}"
