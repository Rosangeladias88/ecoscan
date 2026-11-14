
# EcoScan — Status do Desenvolvimento

**Última atualização:** 13/11/2026

## 1. Objetivo

Registrar o andamento das APIs, integrações, testes e pendências do projeto EcoScan.

Os estados apresentados são baseados no histórico de desenvolvimento da equipe e precisam ser validados no repositório atualizado.

## 2. APIs

| Serviço | Último estado conhecido |
|---|---|
| API de Acesso | Implementação e testes relatados |
| API de Fotografias | Implementação e testes relatados |
| API de Materiais | Implementação relatada pela equipe |
| API de Histórico | Verificação pendente |
| API GraphQL | Consulta com dados simulados testada |
| API Gateway | Integração parcial relatada |

## 3. Funcionalidades trabalhadas

### API de Acesso
- Cadastro de usuários.
- Autenticação com JWT.
- Proteção de rotas privadas.
- Testes de autenticação.

### API de Fotografias
- Upload de imagens.
- Validação de formato e tamanho.
- Geração de identificadores UUID.
- Consulta de fotografias.

### API GraphQL
- Criação do serviço.
- Implementação de consulta de materiais com dados simulados.
- Teste de execução da consulta.
- Integração com APIs REST ainda a validar.

## 4. Integrações pendentes de verificação

- GraphQL com API de Materiais.
- GraphQL com API de Histórico.
- GraphQL com API de Fotografias.
- API Gateway com GraphQL.
- Comunicação do aplicativo Flutter com o backend.
- Integração do painel React com os serviços.

## 5. Testes

Testes funcionais relatados:
- Cadastro e login.
- Autenticação com JWT.
- Upload de fotografias.
- Consultas de fotografias.
- Consulta GraphQL com dados simulados.

Pendente:
- Consolidar evidências dos testes.
- Confirmar os resultados no código atual.
- Registrar testes integrados.
- Documentar testes de desempenho.

## 6. Próximas atividades

1. Revisar os serviços implementados.
2. Confirmar as integrações existentes.
3. Executar testes de ponta a ponta.
4. Corrigir falhas identificadas.
5. Atualizar a documentação técnica.
6. Preparar a demonstração final.

## 7. Observações

Este documento é um registro preliminar.

A conclusão de uma API não significa que sua integração com os demais serviços esteja finalizada.

Nenhuma funcionalidade deve ser considerada validada sem a correspondente verificação técnica.
