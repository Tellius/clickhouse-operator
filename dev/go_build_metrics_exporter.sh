#!/bin/bash

# Build metrics-exporter
# Do not forget to update version

# Source configuration
CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "${CUR_DIR}/go_build_config.sh"

# Build clickhouse-operator install .yaml manifest
"${MANIFESTS_ROOT}/operator/build-clickhouse-operator-install-yaml.sh"

# Prepare modules
GO111MODULE=on go mod tidy
GO111MODULE=on go mod "${MODULES_DIR}"

#CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o ${CUR_DIR}/clickhouse-operator ${SRC_ROOT}/cmd/clickhouse-operator
if CGO_ENABLED=0 GO111MODULE=on go build \
    -mod="${MODULES_DIR}" \
    -a \
    -ldflags "-X ${REPO}/pkg/version.Version=${VERSION} -X ${REPO}/pkg/version.GitSHA=${GIT_SHA}" \
    -o "${METRICS_EXPORTER_BIN}" \
    "${SRC_ROOT}/cmd/metrics_exporter/main.go"
then
    echo "Build OK"
else
    echo "WARNING! BUILD FAILED!"
    echo "Check logs for details"
fi

exit $?
