#!/usr/bin/env bash

if [[ $1 == "build" ]]; then
    docker buildx create --use
    git clone https://github.com/xuemian168/kuno.git
    pushd kuno
    docker buildx build --platform linux/arm64 -t ictrun/kuno:arm64 --load .
    popd
fi

source .env
ensure_network() {
    local net=$1
    if ! docker network inspect "$net" >/dev/null 2>&1; then
        echo "Creating network: $net"
        docker network create "$net"
    fi
}
ensure_network caddy_net
ensure_network kuno_internal_net

is_ip() {
  [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

if [ "$MULTIPLE_CADDY_GLOBAL" = "true" ]; then
    echo "Multiple global services enabled → using global Caddyfile"
    export COMPOSE_FILE="docker-compose.yml"
else
    echo "Single global service → using local Caddyfile"
    export COMPOSE_FILE="docker-compose.yml:docker-compose.root-caddy.yml"
    if is_ip "$KUNO_SERVER_ADDRESS"; then
        echo "Detected IP → using internal TLS"
        export TLS_CONFIG='tls internal'
    else
        echo "Detected domain → using Cloudflare TLS"
        export TLS_CONFIG='tls { dns cloudflare {env.CF_API_TOKEN} }'
    fi
fi
docker compose $@
unset COMPOSE_FILE