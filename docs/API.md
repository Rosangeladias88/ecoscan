
# Documentação das APIs — EcoScan

## 1. Visão geral

O EcoScan utiliza uma arquitetura de microsserviços, composta por quatro APIs REST e uma API GraphQL.

Os serviços possuem responsabilidades específicas e se comunicam por HTTP.

O API Gateway centraliza o acesso dos clientes aos serviços.

**Observação:** os endpoints descritos neste documento foram definidos na proposta de arquitetura. A implementação e os formatos de resposta devem ser conferidos no código-fonte.

## 2. API de Acesso

Responsável pelo cadastro, autenticação e gerenciamento de acesso dos usuários.

### POST /auth/register

Realiza o cadastro de um novo usuário.

Responsabilidades:
- Receber os dados de cadastro.
- Validar as informações.
- Armazenar a senha de maneira segura.
- Registrar o usuário no banco de dados.

### POST /auth/login

Autentica um usuário cadastrado.

Responsabilidades:
- Validar as credenciais.
- Verificar a senha cadastrada.
- Gerar um token JWT após autenticação.

O JWT permite identificar o usuário nas requisições protegidas.

## 3. API de Fotografias

Responsável pelo recebimento e armazenamento das imagens dos resíduos.

### POST /photos

Recebe uma fotografia enviada pelo usuário autenticado.

Responsabilidades:
- Receber o arquivo.
- Validar o tipo e o tamanho da imagem.
- Armazenar a fotografia.
- Gerar um identificador para o arquivo.

### GET /photos/:id

Permite consultar uma fotografia utilizando seu identificador.

O parâmetro `:id` representa o identificador da fotografia.

## 4. API de Materiais

Responsável pelo catálogo de materiais e pelas orientações de descarte.

### GET /materials

Consulta os materiais cadastrados no sistema.

### POST /materials

Permite cadastrar novos materiais.

Na arquitetura proposta, a escrita no catálogo é restrita a usuários administradores.

Informações previstas:
- Nome do material.
- Categoria.
- Reciclabilidade.
- Orientações de preparo.
- Destino recomendado.

## 5. API de Histórico

Responsável por registrar e consultar as atividades dos usuários.

### POST /history

Registra uma consulta realizada pelo usuário.

### GET /history?limit=10

Consulta o histórico do usuário autenticado.

O parâmetro `limit` controla a quantidade solicitada de registros.

O histórico deve ser acessível somente ao proprietário dos dados.

## 6. API GraphQL

### POST /graphql

Permite realizar consultas combinadas aos dados de diferentes serviços.

Na arquitetura proposta, o GraphQL consulta as APIs de:

- Materiais.
- Histórico.
- Fotografias.

O serviço GraphQL não possui banco de dados próprio.

Sua responsabilidade é agregar informações recebidas das APIs REST.

## 7. Autenticação e segurança

O sistema prevê:

- Hash de senhas.
- Tokens JWT.
- Proteção das rotas privadas.
- Controle de acesso às informações dos usuários.
- Validação de dados e arquivos.
- Restrições para operações administrativas.

## 8. Comunicação entre serviços

Fluxo arquitetural previsto:

1. O aplicativo envia uma requisição.
2. O API Gateway recebe a solicitação.
3. O Gateway encaminha a requisição ao serviço responsável.
4. O serviço processa a operação.
5. A resposta retorna ao cliente.

O GraphQL pode reunir dados de diferentes serviços por HTTP.

## 9. Estado da implementação

Este documento descreve os contratos propostos para o EcoScan.

Antes da entrega final, a equipe deverá conferir:

- Rotas realmente implementadas.
- Métodos HTTP utilizados.
- Campos obrigatórios das requisições.
- Formatos reais das respostas.
- Códigos de status e erros.
- Regras de autenticação.
- Integrações concluídas.
- Testes executados e seus resultados.

Documentar uma rota planejada não significa que ela já esteja implementada.
