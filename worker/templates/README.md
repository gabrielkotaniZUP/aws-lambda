
## App.py
Esse é o ponto de entrada ao Lambda, é o primeiro script a ser executado. Nosso app, está pronto para ser chamado, ou receber eventos.

**Payload**
+ `secrets`  (dict): Nome de um secret salvo no AWS Secrets Manager, e salvo como variavel de ambiente. e.g. {"meu_segredo" : "variavel_de_ambiente"}
+ `environment` (dict): Passar uma chave e valor diretamente para o ambiente. e.g. {"chave" : "valor"}
+ `comando` (str) : Comando a ser invocado via cli. 
