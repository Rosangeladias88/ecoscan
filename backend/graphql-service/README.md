# GraphQL Service

Serviço responsável por disponibilizar consultas GraphQL para o EcoScan.

## Tecnologias

- NestJS
- TypeScript
- GraphQL
- Apollo Server

## Porta padrão

`3005`

## Instalação

```bash
npm install
```

## Execução

```bash
npm run start:dev
```

## Endpoint

`http://localhost:3005/graphql`

## Consulta disponível

### materiais

Retorna os nomes dos materiais cadastrados na Materials API.

Exemplo:

```graphql
query {
  materiais
}
```

Tipo de retorno:

`[String]`

Exemplo ilustrativo:

```json
{
  "data": {
    "materiais": [
      "Garrafa PET"
    ]
  }
}
```

## Comunicação com a Materials API

O resolver realiza uma requisição HTTP para:

`http://localhost:3002/materials`

Em seguida, transforma a resposta em uma lista contendo somente os nomes dos materiais.

## Interface de consulta

A configuração atual:
- Utiliza Apollo Driver.
- Gera o schema automaticamente.
- Mantém o GraphQL Playground desabilitado.
- Habilita o GraphiQL.

## Testes e compilação

```bash
npm run test
npm run build
```

## Observação

A consulta atual disponibiliza apenas os nomes dos materiais. Não documente campos adicionais como se fossem retornados pelo GraphQL.
