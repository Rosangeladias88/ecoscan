# EcoScan — Relatório de desenvolvimento e pendências

**Projeto:** EcoScan  
**Última atualização:** 16 de novembro de 2026  
**Situação geral:** MVP em desenvolvimento, com interface Android funcional e integração completa ainda pendente.

## 1. Objetivo do projeto

O EcoScan é uma aplicação voltada à orientação sobre descarte correto de resíduos. O objetivo é permitir que usuários fotografem materiais, consultem informações de descarte, encontrem pontos de coleta e acompanhem seu histórico.

A proposta também contempla perfis de usuários, coletores e empresas, possibilitando futuras interações relacionadas à coleta de resíduos.

## 2. Tecnologias utilizadas

| Tecnologia | Finalidade |
|---|---|
| Flutter e Dart | Desenvolvimento do aplicativo Android |
| NestJS e TypeScript | Desenvolvimento das APIs do backend |
| PostgreSQL | Armazenamento dos dados |
| Prisma ORM | Acesso e gerenciamento do banco de dados |
| JWT e bcrypt | Autenticação e proteção de credenciais |
| REST | Comunicação entre serviços |
| GraphQL | Consultas estruturadas de dados |
| API Gateway | Centralização das requisições aos serviços |
| Git e GitHub | Versionamento e colaboração |
| Docker / Docker Compose | Configuração e execução dos serviços em contêineres |
| React | Tecnologia prevista para o painel administrativo; conclusão não verificada |

## 3. Funcionalidades e componentes desenvolvidos

### 3.1 Aplicativo Flutter

O aplicativo foi compilado e instalado em um dispositivo Android para testes.

As seguintes interfaces foram verificadas visualmente:

- Tela de apresentação e início.
- Escolha de perfil: usuário, coletador e empresa.
- Formulário de cadastro.
- Página inicial do usuário.
- Histórico com filtros de consultas e coletas.
- Visualização de detalhes de solicitações de coleta.
- Orientações de descarte para materiais.
- Navegação entre as telas principais.

**Observação:** a navegação foi testada, mas isso não comprova que os registros apresentados sejam provenientes do backend.

### 3.2 API de autenticação — Access Service

Foram implementadas e testadas funcionalidades de cadastro e login no backend, incluindo:

- Registro de usuários.
- Validação de credenciais.
- Hash de senhas.
- Emissão de token JWT.
- Comunicação com PostgreSQL por meio do Prisma.

Os testes realizados anteriormente demonstraram o funcionamento do login e o retorno dos dados de autenticação.

### 3.3 API de fotografias — Photos Service

Foi desenvolvido um serviço com rotas para cadastro e consulta de fotografias.

As rotas foram verificadas durante os testes do backend. A integração completa entre captura de imagens no Flutter, armazenamento e consulta pela API ainda precisa ser validada.

### 3.4 API de materiais — Materials API

O serviço de materiais foi desenvolvido utilizando NestJS, Prisma e PostgreSQL.

Foram observadas rotas para listar, consultar, cadastrar e atualizar materiais, entre outras operações.

O serviço foi executado na porta 3002 e utilizado com sucesso em uma consulta GraphQL.

### 3.5 API de histórico — History API

O serviço de histórico foi desenvolvido para registrar e consultar operações relacionadas aos resíduos, utilizando autenticação JWT e PostgreSQL.

Foram realizados testes de criação e listagem de registros.

Também foi identificada uma regra de conflito para impedir o cadastro duplicado de uma consulta associada à mesma fotografia, com retorno HTTP 409.

### 3.6 API Gateway

O API Gateway foi implementado em NestJS e executado na porta 3004.

Foram identificadas e executadas rotas de autenticação, fotografias, materiais e histórico.

O acesso ao Gateway foi testado diretamente no navegador de um celular conectado à mesma rede Wi-Fi, utilizando o endereço local do notebook. O servidor respondeu corretamente.

Isso confirma a acessibilidade do Gateway na rede local, mas não a integração completa de todos os serviços.

### 3.7 GraphQL

O serviço GraphQL foi compilado e executado com sucesso.

Uma consulta ao campo `materiais` retornou o item **Garrafa PET**, demonstrando comunicação funcional entre o serviço GraphQL e a API de materiais.

A integração de consultas combinadas de fotografias e histórico ainda não foi comprovada nos testes disponíveis.

## 4. Integração Flutter e backend

Durante a análise do código Flutter, foi identificado que o cadastro utilizava uma lista local de contas.

Para iniciar a integração real, foram realizadas as seguintes atividades:

1. Instalação da dependência `http` no Flutter.
2. Criação da pasta `lib/services`.
3. Criação do arquivo `auth_service.dart`.
4. Implementação de uma requisição HTTP de cadastro para `/auth/register`.
5. Alteração da função `_criar()` para execução assíncrona.
6. Inclusão do serviço de autenticação no formulário de cadastro.
7. Configuração do endereço local do API Gateway para os testes.
8. Execução da análise estática do código Flutter.

**Resultado:** a análise do arquivo de cadastro não apresentou erros de compilação, apenas um aviso de API descontinuada relacionado à propriedade `activeColor`.

**Limitação:** o cadastro integrado ainda não foi validado em uma nova versão do aplicativo Android. A instalação existente corresponde a uma compilação anterior.

## 5. Pendências identificadas

| Prioridade | Pendência | Situação |
|---|---|---|
| Alta | Testar cadastro Flutter conectado ao backend | Pendente |
| Alta | Integrar e validar login com token JWT | Pendente |
| Alta | Verificar permissão de internet e tráfego HTTP no Android | Pendente |
| Alta | Testar o fluxo completo de fotografia, material e orientação | Pendente |
| Alta | Validar persistência e recuperação do histórico real | Pendente |
| Média | Confirmar integração das demais operações do GraphQL | Não verificada |
| Média | Revisar o fluxo de solicitação de coleta, atualmente com indicação de demonstração | Pendente |
| Média | Gerar e testar novo APK após as integrações | Pendente |
| Média | Revisar alterações no GitHub e consolidar a documentação | Pendente |
| Conforme o escopo | Verificar o estado do painel administrativo React | Não verificado |

## 6. Testes e evidências

Foram obtidas evidências de:

- Inicialização bem-sucedida dos serviços NestJS.
- Cadastro e autenticação no backend.
- Consultas e registros de histórico.
- Regra de conflito HTTP 409.
- Consulta GraphQL retornando materiais.
- Compilação de APK Android.
- Navegação nas telas do aplicativo.
- Acesso ao API Gateway pelo navegador do celular.
- Instalação da biblioteca HTTP e análise estática do formulário Flutter.

Essas evidências devem ser acompanhadas de capturas de tela e, quando necessário, dos comandos ou requisições executados.

## 7. Próximos passos recomendados

A próxima etapa do desenvolvimento deverá priorizar a integração real do Flutter com o backend.

A ordem sugerida é:

1. Verificar a configuração de rede e as permissões Android.
2. Testar o cadastro real e confirmar o registro no PostgreSQL.
3. Integrar o login e o gerenciamento do token.
4. Validar o fluxo de fotografias, materiais e histórico.
5. Realizar um teste completo do MVP.
6. Atualizar o APK e a documentação de entrega.

## 8. Conclusão

O EcoScan já possui uma interface Android navegável, serviços de backend implementados e testes bem-sucedidos de autenticação, histórico e consulta GraphQL de materiais.

O avanço mais recente foi a preparação da integração de cadastro entre Flutter e API Gateway.

Entretanto, a comunicação completa do aplicativo com os microsserviços ainda não foi validada. Portanto, o projeto deve ser apresentado como um **MVP em fase de integração**, destacando as funcionalidades implementadas, as evidências obtidas e as pendências técnicas.

O desenvolvimento será retomado a partir dos testes de integração, sem necessidade de reconstruir as telas já implementadas.