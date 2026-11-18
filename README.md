# EcoScan

Aplicativo de orientação para descarte sustentável de resíduos recicláveis.

O EcoScan permite consultar materiais, visualizar orientações de descarte, registrar consultas e armazenar fotografias relacionadas aos resíduos.

## Tecnologias

### Backend
- Node.js
- NestJS
- TypeScript
- PostgreSQL
- Prisma
- Docker
- GraphQL

### Frontend
- Flutter
- Dart

## Estrutura do projeto

```text
ecoscan/
├── backend/
│   ├── access-service/
│   ├── photos-service/
│   ├── materials-api/
│   ├── history-api/
│   ├── api-gateway/
│   └── graphql-service/
├── frontend/
├── docs/
├── docker-compose.yml
└── README.md
```

## Arquitetura

O backend é organizado em serviços independentes:

| Serviço | Responsabilidade | Porta padrão |
|---|---|---:|
| Access | Cadastro, login e autenticação | 3000 |
| Photos | Armazenamento e consulta de fotografias | 3001 |
| Materials | Cadastro e consulta de materiais | 3002 |
| History | Registro e consulta do histórico | 3003 |
| API Gateway | Ponto de entrada das APIs | 3004 |
| GraphQL | Consultas GraphQL | 3005 |

O PostgreSQL é executado pelo Docker Compose na porta 5432.

## Como iniciar o ambiente

### 1. Configurar o banco de dados

Na raiz do projeto, crie o arquivo `.env` a partir do `.env.example`.

Configure as variáveis necessárias:

- `POSTGRES_USER`
- `POSTGRES_PASSWORD`

Inicie o PostgreSQL:

```bash
docker compose up -d postgres
```

Confira o estado do container:

```bash
docker compose ps
```

### 2. Iniciar os serviços backend

Cada serviço possui seu próprio diretório e deve ser iniciado separadamente.

Entre no diretório do serviço, instale as dependências e execute:

```bash
npm install
npm run start:dev
```

Portas padrão:

- Access: 3000
- Photos: 3001
- Materials: 3002
- History: 3003
- Gateway: 3004
- GraphQL: 3005

Consulte o README de cada serviço para suas variáveis de ambiente e particularidades.

### 3. Iniciar o Flutter

Entre na pasta do frontend:

```bash
cd frontend
```

Instale as dependências:

```bash
flutter pub get
```

Execute no Chrome:

```bash
flutter run -d chrome
```

## Documentação

A documentação técnica está em `docs/`.

- [Arquitetura](docs/ARQUITETURA.md)
- [Documentação das APIs](docs/API.md)
- [Status do desenvolvimento](docs/STATUS.md)
- [Índice da documentação](docs/README.md)

## Observações

- O Docker Compose da raiz inicia o PostgreSQL; os serviços NestJS são executados separadamente.
- Não compartilhe arquivos `.env`, senhas ou segredos JWT.
- As portas apresentadas são os valores padrão definidos no código e podem ser alteradas por variáveis de ambiente quando disponíveis.
- A identificação automática de resíduos por inteligência artificial e recursos de geolocalização fazem parte de possibilidades futuras, não devendo ser considerados funcionalidades concluídas da versão atual.
