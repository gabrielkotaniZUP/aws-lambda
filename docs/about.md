# About aws-lambda stack

Comece facilmente a utilizar uma instância do `AWS Lambda` localmente e comece a rodar alguns jobs.
Use `Python` para facilitar seus testes, e deixar seu ambiente organizado.


## Estrutura da Stack
A **aws-lambda** foi desenvolvida seguindo todas boas práticas de arquitetura de software:
+ Clean Architecture
+ Componenentes desacoplados

A Stack possui uma estrutura básica, onde o template cria estrutura de arquivos, e baixa as bibliotecas necessárias, subindo um serviço do AWS Lambda localmente e disponibilizando uma porta de entrada para chamadas `REST`. 