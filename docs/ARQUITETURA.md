
# Arquitetura do EcoScan

## 1. Visão geral

O EcoScan é uma aplicação voltada à educação ambiental e à orientação sobre o descarte correto de resíduos.

O sistema permite que usuários enviem fotografias, selecionem manualmente o tipo de material e consultem orientações sobre preparo, reciclagem e destino adequado.

O projeto utiliza uma arquitetura baseada em microsserviços, separando as funcionalidades em serviços com responsabilidades específicas.

## 2. Tecnologias

| Tecnologia | Finalidade |
|---|---|
| Flutter e Dart | Aplicativo móvel |
| React e TypeScript | Painel administrativo |
| NestJS e TypeScript | Backend e API Gateway |
| PostgreSQL | Armazenamento de dados |
| Prisma ORM | Acesso ao banco de dados |
| REST | Comunicação por endpoints HTTP |
| GraphQL | Consultas combinadas |
| JWT | Autenticação e autorização |
| Git e GitHub | Versionamento e colaboração |
| Docker Compose | Organização do ambiente local |

## 3. Organização dos microsserviços

### API de Acesso
Responsável pelo cadastro, login e autenticação dos usuários.

Rotas previstas:
- POST /auth/register
- POST /auth/login

### API de Fotografias
Responsável pelo recebimento e armazenamento das fotografias enviadas pelos usuários.

Rotas previstas:
- POST /photos
- GET /photos/:id

### API de Materiais
Responsável pelo catálogo de materiais e pelas orientações sobre descarte.

Rotas previstas:
- GET /materials
- POST /materials

### API de Histórico
Responsável pelo registro e pela consulta das atividades de cada usuário.

Rotas previstas:
- POST /history
- GET /history?limit=10

### API GraphQL
Responsável por combinar informações das APIs de Materiais, Histórico e Fotografias.

Endpoint previsto:
- POST /graphql

## 4. API Gateway

O API Gateway funciona como ponto central de entrada das requisições.

Sua responsabilidade é encaminhar as solicitações dos clientes aos serviços apropriados.

O Gateway não é considerado uma sexta API de negócio.

## 5. Banco de dados

A arquitetura prevê quatro bancos lógicos:

- acesso_db
- fotos_db
- materiais_db
- historico_db

Cada serviço é responsável por seus próprios dados.

A API GraphQL não possui banco próprio e consulta informações dos demais serviços por HTTP.

## 6. Segurança

A arquitetura prevê:

- Armazenamento de senhas com hash.
- Autenticação por JWT.
- Proteção das rotas privadas.
- Histórico acessível somente ao usuário proprietário.
- Operações administrativas restritas a usuários autorizados.
- Validação dos arquivos enviados.

## 7. Fluxo principal

1. O usuário realiza cadastro ou login.
2. Envia uma fotografia do resíduo.
3. Seleciona manualmente o material.
4. Consulta as orientações de preparo e descarte.
5. Salva a consulta no histórico.
6. Pode consultar seus registros posteriormente.

## 8. Limitações e evolução

O MVP utiliza seleção manual do material.

Reconhecimento automático por inteligência artificial, geolocalização e integração com serviços de coleta são possibilidades futuras, não funcionalidades confirmadas na versão inicial.

## 9. Estado da implementação

A arquitetura descrita representa a estrutura planejada do sistema.

O estado de implementação de cada API, suas integrações e seus testes deve ser registrado separadamente e validado com o código do repositório.
