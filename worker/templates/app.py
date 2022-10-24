# -*- coding: UTF-8 -*-

"""entrypoint_app.py
"""


import os
import sys
import json
import shlex
import importlib
import subprocess

import base64
import boto3

def recuperar_secrets(secrets_map:dict):
    quantity = 0
    if len(secrets_map) == 0: return quantity
    client = boto3.client('secretsmanager')
    for secret_id, env_var_aliases in secrets_map.items():
        env_var_aliases = env_var_aliases if isinstance(env_var_aliases, list) else [env_var_aliases]
        response = client.get_secret_value(SecretId=secret_id)
        response = response['SecretString']
        for varname in env_var_aliases:
            varname = varname.strip()
            if varname.lower().startswith('file://tmp/'):
                with open(varname[6:], 'w') as fout:
                    fout.write(response)
            else:
                os.environ[varname] = response
        quantity += 1
    return quantity


def executar_comando(comando: str, event:dict, context, timeout: int) -> dict:

    output_dir = os.environ.get('LAMBDA_OUTPUT', '/tmp/lambda_output')
    my_env = os.environ.copy()
    # my_env["LAMBDA_EVENT"] = json.dumps(event)
    quottedCmd = shlex.quote(comando)
    processo = subprocess.Popen(shlex.split(comando), stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=my_env)
    stdout, stderr = processo.communicate(timeout=timeout)

    if stdout is None: stdout = b''
    if stderr is None: stderr = b''
    status_OK = int(processo.returncode) == 0
    for encoding in ['utf-8', 'latin-1', None]:

        try:
            if status_OK:
                result = {'STDOUT': stdout.decode(encoding=encoding), 'status': 'OK'}
            else:
                result = {'STDOUT': stdout.decode(encoding=encoding),
                          'STDERR': stderr.decode(encoding=encoding),
                          'status': 'ERROR', 'returncode': processo.returncode}
            break
        except UnicodeDecodeError as exp:
            pass

    # Check for every file in the output dir, adding it to the result
    if os.path.exists(output_dir):
        if os.path.isfile(output_dir):
            with open(output_dir, 'rb') as fin:
                result['OUTPUT'] = base64.b64encode(fin.read()).decode('utf-8')
        else:
            for output_file in os.listdir(output_dir):
                if 'OUTPUT' not in result: result['OUTPUT'] = {}
                with open(os.path.join(output_dir, output_file), 'rb') as fin:
                    result['OUTPUT'][output_file] = base64.b64encode(fin.read()).decode('utf-8')

    # Return the result
    return result


def handler(event: dict, context):

    try:
        # Recuperamos os SECRETS do AWS SECRETS MANAGER
        if 'secrets' in event:
            recuperar_secrets(event['secrets'])

        # Preparamos as variaveis de ambiente
        if 'environment' in event:  # NUNCA PASSE SENHAS POR AQUI!
            for chave, valor in event['environment'].items():
                os.environ[chave] = valor

        # Calculamos o TIMEOUT para o comando
        TIMEOUT = max([600, int(0.95*context.get_remaining_time_in_millis()/1000)])

        if 'comando' in event:
            comando = event['comando']
            print('event', event)
            # print(f'MODO DE OPERACAO COMANDO {comando}')
            return executar_comando(comando, event, context, TIMEOUT)

        # Ultima alternativa: importamos o modulo e rodamos o metodo descrito na variavel de ambiente "LAMBDA_HANDLER"
        # O formato dessa variavel deve ser uma string com: /caminho/ate/o/modulo.py:metodo
        # O metodo deve receber apenas dois argumentos: event e context, exatamente como um lambda comum
        else:
            return {'STDOUT': '', 'STDERR': 'MODO DE OPERACAO DESCONHECIDO: {}'.format(sorted(list(event.keys()))), 'status': 'ERROR'}
    except Exception as e:
        print(str(e))
        return {'STDOUT': '', 'STDERR': 'MODO DE OPERACAO DESCONHECIDO: {}'.format(sorted(list(event.keys()))), 'status': 'ERROR'}
