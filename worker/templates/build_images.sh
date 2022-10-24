#!/bin/bash

set -e
AWS_PROFILE=${1:-"default"}
PUSH=${2:-"Nope"}

# Lemos o diretório de variaveis de ambiente
source '.env'

# Preparamos um diretório de contexto de builds
rm -rf docker_build_context
mkdir docker_build_context

cp *.yml "docker_build_context" || true
cp *.dockerfile "docker_build_context" || true
cp *.txt "docker_build_context" || true
cp *.sh "docker_build_context" || true
cp *.py "docker_build_context" || true

# Saimos e voltamos do diretorio atual por segurança (QUIRK DO DOCKER)
cd ; cd -
if [ ${PUSH} != "Nope" ] ; then
  aws configure set aws_access_key_id "${AWS_ACCESS_KEY_ID}" --profile "${AWS_PROFILE}"
  aws configure set aws_secret_access_key "${AWS_SECRET_ACCESS_KEY}" --profile "${AWS_PROFILE}"
  aws configure set aws_session_token "${AWS_SESSION_TOKEN}" --profile "${AWS_PROFILE}"
  aws configure set aws_ca_bundle "${AWS_CA_BUNDLE}" --profile "${AWS_PROFILE}"

  # Recuperamos a chave de repositório
  aws ecr get-login-password --profile "${AWS_PROFILE}" | docker login --username AWS --password-stdin "${DOCKER_REPOSITORY}" \

fi
# # Realizamos o pull da imagem (podem ser várias) para o repositório local
# env "DOCKER_REPOSITORY=${DOCKER_REPOSITORY}" docker-compose pull
# echo "All images pulled from AWS ECR"

# Executamos o build da imagem (podem ser várias)
env "DOCKER_REPOSITORY=${DOCKER_REPOSITORY}" \
    docker-compose build \
      --build-arg "docker_repository=${DOCKER_REPOSITORY}" \
      "${@:3}"
echo "All images built"

if [ ${PUSH} == "--push" ] ; then

  # Realizamos o push da imagem (podem ser várias) para o repositório
  env "DOCKER_REPOSITORY=${DOCKER_REPOSITORY}" docker-compose push
  echo "All images pushed to AWS ECR"

fi

# Removemos o diretório temporário de BUILDS
rm -rf docker_build_context