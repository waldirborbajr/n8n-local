# Projeto Integrado com n8n, Postgres, Evolution API, Ngrok, Redis, Adminer e Ollama

Este projeto orquestra vários serviços utilizando Docker Compose para criar um ambiente de desenvolvimento completo para automação, gerenciamento de dados, comunicação e IA.

## Serviços

Os seguintes serviços são definidos no `docker-compose.yml`:

- **n8n:** Plataforma de automação de workflows.
- **Postgres:** Banco de dados PostgreSQL com extensão pgvector para funcionalidades vetoriais.
- **Evolution API:** API para integração com plataformas de mensagens.
- **WAHA API:** API para integração com plataformas de mensagens. (alternativa ao Evolution)
- **Ngrok:** Cria túneis seguros para expor o n8n para a internet (útil para webhooks).
- **Redis:** Banco de dados em memória para cache, utilizado pela Evolution API.
- **Adminer:** Interface web para administração do banco de dados Postgres.
- **Ollama:** Ferramenta para executar e gerenciar modelos de linguagem grandes (LLMs) localmente.

## Pré-requisitos

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

## Configuração

1.  **Clone o repositório:**

    ```bash
    git clone <URL_DO_REPOSITÓRIO>
    cd <NOME_DO_REPOSITÓRIO>
    ```

2.  **Crie um arquivo `.env`:**

    Copie o conteúdo de `.env.example` para um novo arquivo chamado `.env`.
    Preencha as variáveis de ambiente com os valores apropriados. **Importante:** Defina senhas seguras para o Postgres e o n8n.

    ```bash
    cp .env.example .env
    nano .env
    ```

3.  **Variáveis de Ambiente:**

    Para simplificar, procure dentro do arquivo `.env` pela palavra **MUDE_AQUI** e deixe as demais variaveis como estão, ou altere conforme abaixo no item `4`.

    Para gerar a chave de API, procure no Google por `api key generator` ou vá direto no site https://generate-random.org/api-key-generator e gere uma chave para ser utilizada quando solicitado.

    Para gerar um domínio no NGRok, acesso o https://ngrok.com/ e entre com sua senha e vá no menu `Domains` e depois clique no botão `New Domain` siga os passos e crie o dominio para vincular nas váriaveis:
    - `WEBHOOK_URL`
    - `N8N_HOST=MUDE_AQUI`

4. **Ajuste fino das variáveis**

    - **Postgres:**
      - `POSTGRES_USER`: Nome de usuário do Postgres.
      - `POSTGRES_PASSWORD`: Senha do usuário Postgres.
      - `POSTGRES_DB`: Nome do banco de dados.
    - **n8n:**
      - `N8N_BASIC_AUTH_ACTIVE`: Ativar autenticação básica ( `true` ou `false`).
      - `N8N_BASIC_AUTH_USER`: Nome de usuário para autenticação no n8n.
      - `N8N_BASIC_AUTH_PASSWORD`: Senha para autenticação no n8n.
      - `DB_TYPE`: Tipo de banco de dados (deve ser `postgresdb`).
      - `DB_POSTGRESDB_HOST`: Host do banco de dados Postgres (deve ser `postgres`).
      - `DB_POSTGRESDB_PORT`: Porta do Postgres (geralmente 5432).
      - `DB_POSTGRESDB_USER`, `DB_POSTGRESDB_PASSWORD`, `DB_POSTGRESDB_DATABASE`: Valores correspondentes do Postgres.
      - `WEBHOOK_URL`: URL base para webhooks do n8n (geralmente o endereço do ngrok).
    - **Evolution API:**
      - `AUTHENTICATION_API_KEY`: Chave de API para autenticação na Evolution API.
      - `DATABASE_ENABLED`: Habilita a conexão com o banco de dados ( `true` ou `false`).
      - `DATABASE_PROVIDER`: Provedor do banco de dados (deve ser `postgresql`).
      - `DATABASE_CONNECTION_URI`: String de conexão com o banco de dados Postgres.
      - `DATABASE_CONNECTION_CLIENT_NAME`: Nome do cliente de conexão do banco de dados.
      - `DATABASE_SAVE_DATA_INSTANCE`: Salvar dados da instância no banco de dados ( `true` ou `false`).
      - `DATABASE_SAVE_DATA_NEW_MESSAGE`: Salvar novas mensagens no banco de dados ( `true` ou `false`).
      - `DATABASE_SAVE_MESSAGE_UPDATE`: Salvar atualizações de mensagens no banco de dados ( `true` ou `false`).
      - `DATABASE_SAVE_DATA_CONTACTS`: Salvar dados de contatos no banco de dados ( `true` ou `false`).
      - `DATABASE_SAVE_DATA_CHATS`: Salvar dados de chats no banco de dados ( `true` ou `false`).
      - `DATABASE_SAVE_DATA_LABELS`: Salvar dados de labels no banco de dados ( `true` ou `false`).
      - `DATABASE_SAVE_DATA_HISTORIC`: Salvar dados históricos no banco de dados ( `true` ou `false`).
    - **Redis (Evolution API):**
      - `CACHE_REDIS_ENABLED`: Habilita o cache Redis ( `true` ou `false`).
      - `CACHE_REDIS_URI`: URI de conexão com o Redis.
      - `CACHE_REDIS_PREFIX_KEY`: Prefixo para as chaves do cache Redis.
      - `CACHE_REDIS_SAVE_INSTANCES`: Salvar instâncias no cache Redis ( `true` ou `false`).
    - **Ngrok:**
      - `NGROK_PROTOCOL`: Protocolo a ser utilizado (geralmente `http`).
      - `NGROK_PORT`: Porta do serviço a ser exposto (deve ser `n8n:5678`).
      - `NGROK_AUTHTOKEN`: Seu token de autenticação do Ngrok (necessário para usar domínios personalizados).

5.  **Inicialize os serviços:**

    ```bash
    docker-compose up -d
    ```

    Isso irá baixar as imagens necessárias, criar os contêineres e iniciar todos os serviços em modo "detached" (em segundo plano).

## Acesso aos Serviços

- **n8n:** Acesse a interface web em `http://localhost:5678`. Use as credenciais definidas em `.env` ( `N8N_BASIC_AUTH_USER` e `N8N_BASIC_AUTH_PASSWORD`).
- **Postgres:** O banco de dados estará disponível na porta 5432. Você pode usar o Adminer para gerenciá-lo.
- **Adminer:** Acesse em `http://localhost:8081`. Conecte-se ao Postgres usando as credenciais definidas no `.env`.
- **Evolution API:** Acesse a API em `http://localhost:8080`.
- **Ngrok:** A interface web do ngrok estará disponível em `http://localhost:4040`. A URL pública gerada pelo ngrok (ex: `https://viable-proud-tomcat.ngrok-free.app`) deve ser definida na variável `WEBHOOK_URL` no arquivo `.env`.
- **Ollama:** Acesse a API na porta 11434. Consulte a documentação do Ollama para instruções sobre como usar a API.
- **Redis:** O redis estará disponível na porta 6380.

## Notas

- **Ngrok:** Para usar um domínio personalizado com o Ngrok, você precisa de uma conta paga e configurar o `NGROK_AUTHTOKEN` no arquivo `.env`.
- **Volumes:** Os dados do n8n e do Postgres são armazenados em volumes Docker (`n8n_data` e `postgres_data`), para que não sejam perdidos ao reiniciar os contêineres.
- **Rede:** Todos os contêineres estão na mesma rede Docker (`minha_rede`), o que permite que eles se comuniquem entre si usando seus nomes de serviço (ex: `postgres`, `n8n`).

## Próximos Passos

- Explore a documentação de cada serviço para aprender mais sobre como usá-los.
- Comece a criar workflows no n8n para automatizar suas tarefas.
- Integre a Evolution API com seus fluxos de trabalho para enviar e receber mensagens.
- Utilize o Ollama para adicionar funcionalidades de IA aos seus projetos.
