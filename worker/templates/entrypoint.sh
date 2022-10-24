#!/bin/bash


# Variaveis de ambiente de download do S3
: ${MOUNTPOINT:='/mnt/artifacts'}


# Função que verifica se um elemento está num array
containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

# Se os argumentos contém a opção --not-lambda, NAO QUEREMOS EXECUTAR A API LAMBDA
if containsElement "--not-lambda" "${@}"; then
  USAR_LAMBDA=false
  for arg do
    shift
    [ "$arg" = "--not-lambda" ] && continue
    set -- "$@" "$arg"
  done
else
  USAR_LAMBDA=true
fi

# Se estamos usando o LAMBDA RIC, inicializamos a LAMBDA-API
if ${USAR_LAMBDA}
then
#  echo "Executando o AWS LAMBDA RIC"
  cd "/var/task"
  /lambda-entrypoint.sh "app.handler" "${@}"
else
#  echo "Executando comandos diretamente"
  exec "${@}"
fi
