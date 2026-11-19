# Status do desenvolvimento - EcoScan

**Última atualização:** 18/11/2026

Este documento representa o acompanhamento atual do projeto. As situações abaixo distinguem funcionalidades implementadas, integrações já testadas e validações ainda necessárias.

## 1. Backend

| Componente | Situação | Observações |
|---|---|---|
| Access Service | Implementado e testado | Cadastro, login e autenticação JWT |
| Photos Service | Implementado | Upload, listagem, consulta e recuperação de arquivos |
| Materials API | Implementado e testado | Operações de materiais e orientações |
| History API | Integrado ao Gateway | Criação e consulta de histórico |
| API Gateway | Integrado | Encaminhamento de autenticação, materiais, fotos e histórico |
| GraphQL Service | Implementado e testado | Consulta de nomes dos materiais |

## 2. Frontend

O aplicativo Flutter está em desenvolvimento e em processo de integração com o backend.

Ainda é necessário validar o funcionamento completo das operações utilizando dados reais.

| Área | Situação |
|---|---|
| Configuração do projeto Flutter | Realizada |
| Dependências Flutter | Instaladas |
| Integração de autenticação | Em validação |
| Integração de materiais | Em validação |
| Integração de fotografias | Pendente de validação ponta a ponta |
| Integração de histórico | Pendente de validação ponta a ponta |

## 3. Segurança

Funcionalidades identificadas na implementação:

- Autenticação por JWT.
- Proteção de rotas de fotografias.
- Verificação de propriedade das fotografias.
- Validação do tamanho dos arquivos enviados.
- Encaminhamento do token pelo Gateway para os serviços que exigem autenticação.

## 4. Infraestrutura

| Item | Situação |
|---|---|
| PostgreSQL | Configurado |
| Docker Compose | Configurado para o banco |
| Persistência por volume Docker | Configurada |
| Serviços NestJS | Executados individualmente |
| Configuração de ambiente | Arquivos `.env` existentes nos serviços que precisam deles |

## 5. Próximas atividades

1. Concluir a integração do Flutter com o API Gateway.
2. Validar cadastro, login e manutenção da sessão no aplicativo.
3. Validar a consulta de materiais com dados reais.
4. Validar o envio e a recuperação de fotografias.
5. Validar a criação e a listagem do histórico com dados reais.
6. Executar testes integrados do fluxo completo do usuário.
7. Revisar os testes automatizados e registrar eventuais falhas.
8. Atualizar este documento após cada etapa relevante.

## 6. Funcionalidades futuras

As seguintes possibilidades não devem ser consideradas concluídas na versão atual:

- Identificação automática de resíduos por inteligência artificial.
- Uso de GPS para localização de pontos de coleta.
- Expansão de recursos de geolocalização.

## 7. Critério de conclusão

Uma funcionalidade somente deve ser marcada como concluída quando sua implementação e seus testes correspondentes forem confirmados.

A integração do histórico pelo Gateway já foi realizada e não deve ser listada novamente como pendência.
