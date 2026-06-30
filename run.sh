#!/usr/bin/env bash

if [[ $1 == "build" ]]; then
    docker buildx create --use
    git clone https://github.com/xuemian168/kuno.git
    pushd kuno
    docker buildx build --platform linux/arm64 -t ictrun/kuno:arm64 --load .
    popd
    exit 0
fi

source .env
ensure_network() {
    local net=$1
    if ! docker network inspect "$net" >/dev/null 2>&1; then
        echo "Creating network: $net"
        docker network create "$net"
    fi
}

ensure_network kuno_internal_net

export COMPOSE_FILE="docker-compose.yml"
docker compose $@
unset COMPOSE_FILE