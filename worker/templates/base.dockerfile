# ZUP IT INNOVATION - 2021 - DATA & ANALYTICS
#
# =======================================
# DOCKERFILE PARA O WORKER AIRFLOW (BASE)
# =======================================

# IMAGEM-FONTE
FROM public.ecr.aws/lambda/python:3.8

# Instalamos as dependencias de sistema operacional
RUN yum -y update \
 && yum install -y gcc g++ curl git awscli \
 && yum -y autoremove && rm -rf /var/lib/apt/lists/*

# Instalamos os REQUIREMENTS
COPY requirements.txt /home/requirements.txt

RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org --no-cache-dir --upgrade pip awscli \
 && pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org --no-cache-dir -r /home/requirements.txt

# Criamos os diretórios e links simbolicos que serao preenchidos DINAMICAMENTE, e a variavel de PATH Python
RUN mkdir -p  /mnt/artifacts/workers \
 && cd /opt && ln -s /mnt/artifacts/workers . && cd /home
ENV PYTHONPATH "/mnt/artifacts:/opt/workers:/usr/local/lib/python3.8:/root/.local/bin"

# Preparamos o PONTO DE ENTRADA DA IMAGEM
COPY app.py /var/task/app.py
COPY entrypoint.sh /home/entrypoint.sh
RUN chmod +x /home/entrypoint.sh
ENTRYPOINT ["/home/entrypoint.sh"]
