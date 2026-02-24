FROM public.ecr.aws/lambda/python:3.12

# Copia os arquivos de requisitos
COPY requirements.txt .

# Instala as dependências no diretório de tarefas do Lambda
RUN pip install -r requirements.txt

COPY model.pkl ${LAMBDA_TASK_ROOT}

# Copia o código da aplicação
COPY app.py ${LAMBDA_TASK_ROOT}

# O comando aponta para [arquivo].[objeto_mangum]
CMD [ "app.handler" ] 