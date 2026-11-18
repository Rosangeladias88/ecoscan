# Arquitetura do EcoScan

## 1. Visão geral

O EcoScan utiliza uma arquitetura organizada em serviços backend independentes, com comunicação HTTP entre os componentes.

O sistema possui um frontend Flutter, um API Gateway, serviços especializados, uma API GraphQL e um banco de dados PostgreSQL.

## 2. Componentes

| Componente | Responsabilidade | Porta padrão |
|---|---|---:|
| Access Service | Cadastro, login e perfil do usuário | 3000 |
| Photos Service | Envio, armazenamento e consulta de fotografias | 3001 |
| Materials API | Gerenciamento de materiais e orientações | 3002 |
| History API | Registro e consulta do histórico | 3003 |
| API Gateway | Encaminhamento das requisições do cliente | 3004 |
| GraphQL Service | Disponibilização de consultas GraphQL | 3005 |
| PostgreSQL | Persistência dos dados | 5432 |

## 3. Organização do backend

### Access Service

Responsável pela autenticação e pelo gerenciamento de acesso dos usuários.

Principais funcionalidades:
- Cadastro de usuários.
- Login.
- Emissão e validação de JWT.
- Consulta do perfil autenticado.

### Photos Service

Responsável pelo armazenamento e pela recuperação das fotografias.

Principais funcionalidades:
- Recebimento de imagens.
- Listagem das fotografias do usuário autenticado.
- Consulta de metadados.
- Recuperação do arquivo armazenado.
- Verificação de propriedade da fotografia.

### Materials API

Responsável pelo gerenciamento dos materiais recicláveis.

Principais funcionalidades:
- Listagem e consulta de materiais.
- Cadastro e atualização.
- Desativação de materiais.
- Cadastro e atualização de orientações de descarte.

### History API

Responsável pelo histórico de consultas realizadas pelos usuários.

Principais funcionalidades:
- Criação de registros.
- Listagem do histórico do usuário autenticado.
- Consulta individual de registros.
- Associação entre usuário, material e fotografia.

### API Gateway

O Gateway centraliza as rotas utilizadas pelo cliente e encaminha as requisições aos serviços correspondentes.

Atualmente, possui módulos de:
- Autenticação.
- Materiais.
- Fotografias.
- Histórico.

O Gateway encaminha o cabeçalho Authorization quando necessário, permitindo que os serviços responsáveis validem o token JWT.

### GraphQL Service

Disponibiliza uma interface GraphQL para consultas de materiais.

A consulta `materiais` realiza uma requisição HTTP para a Materials API e retorna somente os nomes dos materiais.

## 4. Comunicação entre os componentes

```text
                  FRONTEND FLUTTER
                         |
                         v
                   API GATEWAY
                    Porta 3004
                         |
       +-----------------+------------------+
       |                 |                  |
       v                 v                  v
  ACCESS SERVICE    MATERIALS API      PHOTOS SERVICE
     :3000              :3002               :3001
       |
       |
       +-------------------+
                           |
                           v
                      HISTORY API
                         :3003


                  GRAPHQL SERVICE
                       :3005
                         |
                         v
                    MATERIALS API
                       :3002


              SERVIÇOS E POSTGRESQL
                       :5432
```

O diagrama apresenta os principais caminhos de comunicação. Cada serviço utiliza sua configuração própria de conexão com o banco de dados.

## 5. Autenticação e segurança

A autenticação utiliza JSON Web Token (JWT).

O cliente envia o token no cabeçalho:

```http
Authorization: Bearer TOKEN
```

Os serviços que exigem autenticação validam o token antes de executar operações protegidas.

No serviço de fotografias, também existe verificação de propriedade para impedir que um usuário consulte arquivos pertencentes a outro usuário.

O envio de fotografias utiliza multipart/form-data, com limite de 5 MB.

## 6. Banco de dados

O PostgreSQL é iniciado pelo Docker Compose localizado na raiz do repositório.

O container utiliza:
- Imagem: `postgres:17-alpine`
- Nome: `ecoscan-postgres`
- Porta: `5432`
- Volume persistente: `ecoscan_postgres_data`

O volume mantém os dados do banco entre reinicializações do container.

As configurações de conexão são definidas nos arquivos de ambiente de cada serviço.

## 7. Frontend

O frontend é desenvolvido com Flutter e Dart.

Entre as dependências utilizadas estão:
- http
- image_picker
- camera
- permission_handler
- flutter_map
- geolocator
- url_launcher

A aplicação se comunica com o backend por meio do API Gateway e dos serviços disponibilizados.

## 8. Observações arquiteturais

- O Docker Compose da raiz inicia o banco de dados, não todos os serviços NestJS.
- O Gateway utiliza endereços HTTP locais para encaminhar as requisições.
- O GraphQL consulta a Materials API diretamente.
- A configuração atual do GraphQL disponibiliza GraphiQL e não habilita o Playground.
- A integração completa do frontend deve ser considerada concluída somente após os testes ponta a ponta.
