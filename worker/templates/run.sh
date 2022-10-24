#!/bin/bash

set -e

# Lemos o diretório de variaveis de ambiente
source '.env'

# Variavel de ambiente especificando a TAG que testamos
WORKER_TAG=base
# Executamos o comando DOCKER do airflow_worker_std, apontando diretamente para os diretorios locais
BD="$(pwd)"
docker run -it --rm --name woker \
           --mount type=bind,source="$BD/workers",target="/opt/workers" \
           --mount type=bind,source="$BD/lambda_output",target="/tmp/lambda_output" \
           -p 9000:8080 \
           "${DOCKER_REPOSITORY}:${WORKER_TAG}" ${FLAGS} "${@}"

# Envie requisicoes para o container, EM MODO LAMBDA, com HTTP POST como no formato:
# curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"comando":"ls -al"}'