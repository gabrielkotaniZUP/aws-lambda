#!/bin/bash

set -e

# Lemos o diretório de variaveis de ambiente
source '.env'

# Variavel de ambiente especificando a TAG que testamos
WORKER_TAG=nilo_eng
# Executamos o comando DOCKER do airflow_worker_std, apontando diretamente para os diretorios locais
BD="$(dirname $(dirname $(pwd)))"
docker run -it --rm --name nilo_worker_lambda \
           --mount type=bind,source="$BD/credentials",target="/dev_only/credentials",readonly \
           --mount type=bind,source="$BD",target="/mnt/artifacts" \
           --mount type=bind,source="$BD/workers",target="/opt/workers" \
           --mount type=bind,source="lambda_output",target="/tmp/lambda_output" \
           -p 9000:8080 \
           "${DOCKER_REPOSITORY}:${WORKER_TAG}" ${FLAGS} "${@}"

# Envie requisicoes para o container, EM MODO LAMBDA, com HTTP POST como no formato:
# curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"comando":"ls -al"}'
# docker run --rm -it --mount type=bind,source="$(dirname $(dirname $(pwd)))/workers",target="/opt/workers" --mount type=bind,source="$(dirname $(dirname $(pwd)))/libs",target="/opt/libs"  939634059218.dkr.ecr.us-east-1.amazonaws.com/nilo_worker:nilo_ml  