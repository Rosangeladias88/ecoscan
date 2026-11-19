# EcoScan

Aplicativo de orientação para descarte sustentável de resíduos recicláveis.

O EcoScan permite consultar materiais, visualizar orientações de descarte, registrar consultas e armazenar fotografias relacionadas aos resíduos.

## Tecnologias

- **Backend:** Node.js, NestJS, TypeScript, PostgreSQL, Prisma e GraphQL.
- **Frontend:** Flutter e Dart.
- **Infraestrutura:** Docker e Docker Compose.

## Estrutura

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

## Arquitetura e portas

| Serviço | Responsabilidade | Porta |
|---|---|---:|
| Access | Cadastro, login e autenticação | 3000 |
| Photos | Armazenamento e consulta de fotografias | 3001 |
| Materials | Consulta de materiais e orientações | 3002 |
| History | Registro e consulta do histórico | 3003 |
| API Gateway | Ponto de entrada das APIs | 3004 |
| GraphQL | Consultas GraphQL | 3005 |
| PostgreSQL | Banco de dados | 5432 |

O aplicativo Flutter utiliza o API Gateway como ponto de entrada.

## Pré-requisitos

Instale antes de iniciar:

- Git
- Node.js e npm
- Docker Desktop
- Flutter SDK
- Google Chrome

Confira as instalações:

```powershell
git --version
node --version
npm --version
docker --version
flutter --version
```

## 1. Clonar o repositório

```powershell
git clone -b integracao-ecoscan https://github.com/Rosangeladias88/ecoscan.git
cd ecoscan
```

## 2. Configurar as variáveis de ambiente

Os arquivos `.env.example` são modelos. Crie os arquivos `.env` correspondentes antes de iniciar os serviços.

Na raiz:

```powershell
Copy-Item .env.example .env
```

Nos serviços:

```powershell
Copy-Item backend/access-service/.env.example backend/access-service/.env
Copy-Item backend/photos-service/.env.example backend/photos-service/.env
Copy-Item backend/materials-api/.env.example backend/materials-api/.env
Copy-Item backend/history-api/.env.example backend/history-api/.env
Copy-Item backend/api-gateway/.env.example backend/api-gateway/.env
Copy-Item backend/graphql-service/.env.example backend/graphql-service/.env
```

Edite os arquivos `.env` e configure:

- A senha do PostgreSQL no `.env` da raiz.
- A mesma senha nas URLs `DATABASE_URL` e `SHADOW_DATABASE_URL` dos serviços que as utilizam.
- O mesmo valor de `JWT_SECRET` nos serviços Access, Photos, Materials e History.

Use uma senha local de desenvolvimento e uma chave JWT forte. Se a senha do banco possuir caracteres especiais, codifique-os corretamente nas URLs de conexão.

**Importante:** nunca envie os arquivos `.env` reais para o GitHub.

## 3. Iniciar o PostgreSQL

Com o Docker Desktop aberto, execute na raiz:

```powershell
docker compose up -d postgres
```

Confira o container:

```powershell
docker compose ps
```

Aguarde o PostgreSQL ficar saudável antes de continuar.

## 4. Criar os bancos de dados

O Docker Compose inicia o PostgreSQL, mas os bancos utilizados pelos serviços precisam ser criados.

Execute no PowerShell:

```powershell
$bancos = @(
    "acesso_db",
    "fotos_db",
    "fotos_db_shadow",
    "materiais_db",
    "historico_db",
    "historico_db_shadow"
)

foreach ($banco in $bancos) {
    $existe = docker exec ecoscan-postgres psql -U ecoscan_admin -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$banco'"

    if ($existe.Trim() -ne "1") {
        docker exec ecoscan-postgres psql -U ecoscan_admin -d postgres -c "CREATE DATABASE $banco;"
    }
}
```

Esse procedimento cria somente os bancos que ainda não existem.

## 5. Instalar as dependências e preparar os bancos

Execute os comandos abaixo na raiz do projeto:

```powershell
$servicos = @(
    "access-service",
    "photos-service",
    "materials-api",
    "history-api",
    "api-gateway",
    "graphql-service"
)

foreach ($servico in $servicos) {
    Push-Location "backend\$servico"
    npm install
    Pop-Location
}
```

Gere os clientes Prisma e aplique as migrações:

```powershell
$servicosPrisma = @(
    "access-service",
    "photos-service",
    "materials-api",
    "history-api"
)

foreach ($servico in $servicosPrisma) {
    Push-Location "backend\$servico"
    npx prisma generate
    npx prisma migrate deploy
    Pop-Location
}
```

## 6. Iniciar o backend

Cada serviço deve ser iniciado em um terminal separado, mantendo os processos em execução.

Na raiz do projeto, execute os comandos individualmente:

```powershell
cd backend/access-service
npm run start:dev
```

```powershell
cd backend/photos-service
npm run start:dev
```

```powershell
cd backend/materials-api
npm run start:dev
```

```powershell
cd backend/history-api
npm run start:dev
```

```powershell
cd backend/api-gateway
npm run start:dev
```

```powershell
cd backend/graphql-service
npm run start:dev
```

## 7. Iniciar o aplicativo Flutter

Em outro terminal:

```powershell
cd frontend
flutter pub get
flutter run -d chrome
```

O aplicativo utiliza o endereço local do API Gateway (`http://localhost:3004`).

Para executar em um dispositivo físico, será necessário configurar um endereço de rede acessível pelo celular, em vez de utilizar `localhost`.

## 8. Verificar o ambiente

Confira se os serviços estão em execução nas portas esperadas:

- Access: `3000`
- Photos: `3001`
- Materials: `3002`
- History: `3003`
- API Gateway: `3004`
- GraphQL: `3005`

O PostgreSQL deve estar disponível na porta `5432`.

## Observações

- O primeiro início exige instalação das dependências e configuração dos bancos.
- Os serviços backend devem permanecer em execução enquanto o aplicativo é utilizado.
- O API Gateway encaminha as requisições para os serviços correspondentes.
- Os arquivos `.env` contêm configurações locais e não devem ser versionados.
