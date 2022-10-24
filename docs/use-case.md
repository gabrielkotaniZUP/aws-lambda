# Use case

## Visão Geral:
Comece facilmente a utilizar uma instância do `AWS Lambda` localmente e comece a rodar alguns jobs.

## Pré-requisitos:
+ STK CLI
+ Python 3.6+
+ pip
+ Docker Compose

## Inputs
Os inputs necessários para utilizar o template são:
| Campo | Valor | Descrição |
| Project name | Texto | Nome do projeto |

## Serviços:
+ `Lambda` : Construído em cima da imagem *public.ecr.aws/lambda/python:3.8*.

## Portas:
+ `Lambda` : porta: 9000

## Quick-start:


### REST
Envie `POST` para http://localhost:9000/2015-03-31/functions/function/invocations

### Body do POST
**Payload**
+ `secrets`  (dict): Nome de um secret salvo no AWS Secrets Manager, e salvo como variavel de ambiente. e.g. {"meu_segredo" : "variavel_de_ambiente"}
+ `environment` (dict): Passar uma chave e valor diretamente para o ambiente. e.g. {"chave" : "valor"}
+ `comando` (str) : Comando a ser invocado via cli. 

```json
{
    "comando": "python3 -u /opt/workers/example.py",
    "environment" : {
        "KEY" : "VALUE"
    },
    "secrets" : {
        "SECRET_NAME" : "VARIABLE_NAME"
    }
}
```

### App.py
Esse é o ponto de entrada ao Lambda, é o primeiro script a ser executado. Nosso app, está pronto para ser chamado, ou receber eventos.
