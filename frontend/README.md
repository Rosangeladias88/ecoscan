# EcoScan · app Android em Flutter

**Um app só** para quem descarta e para quem coleta. No cadastro, a pessoa escolhe o perfil, e cada perfil tem as suas funções.
Equipe: Rosangela Dias · Yago Martins · Diego Prestes · Thalia Leite.

## Os três perfis

| Perfil (escolhido no cadastro) | Cadastro pede | O que a pessoa usa |
|---|---|---|
| **Usuário** (quem descarta) | nome, e-mail, senha | Foto → material → orientação · mini mapa de pontos de descarte · pedir coleta e acompanhar · histórico · Hall da Fama · perfil |
| **Coletador** (pessoa que faz a coleta) | nome, CPF, telefone, e-mail, senha, **veículo**, materiais que recolhe, selo de ressocialização | Pedidos (novos / aceitos / concluídos) · mapa dos pedidos · rota e ligação · **aviso quando o pedido não cabe no veículo** · perfil |
| **Empresa** (cooperativa ou empresa de coleta) | tipo, nome, CNPJ, telefone, e-mail, senha, materiais, selo de ressocialização | Tudo do coletador + aba **Equipe** · ao aceitar, **escolhe quem da equipe vai buscar** |

Cada perfil só recebe pedidos dos **materiais que escolheu** no cadastro.

### Contas de demonstração
Na tela de login há atalhos para entrar em cada perfil com um toque (senha `123456`):

| Perfil | E-mail |
|---|---|
| Usuário | usuario@ecoscan.app |
| Coletador | coletador@ecoscan.app |
| Empresa | empresa@ecoscan.app |

### Demonstração do fluxo completo (num celular só)
1. Entre como **Usuário**, faça uma consulta e toque em **Solicitar coleta → Enviar**.
2. Na tela do pedido, toque em **"Demonstração: entrar como coletador para aceitar"**.
3. Como **Coletador**, o pedido aparece em **Novos**. Toque em **Aceitar**.
4. Saia (Perfil → Sair) e entre de novo como **Usuário**: o pedido está como **Coleta aceita**, com o nome de quem vai buscar.
5. Para ver a **Empresa**: entre com a conta da empresa, aceite um pedido e escolha alguém da equipe.

**Escopo: só frontend.** Não há servidor. As contas e os pedidos ficam na memória do app enquanto ele está aberto. Ao fechar o app, tudo volta aos dados de demonstração.

## Estrutura do código

```
lib/
├── main.dart
├── core/       → identidade visual, componentes, materiais e orientações, mapa, links externos
├── state/
│   ├── sessao.dart        → contas, login e o PAPEL de cada conta
│   ├── app_state.dart     → dados do usuário (consultas, pedidos, histórico)
│   └── coleta_state.dart  → dados de coletador e empresa (pedidos, veículo, equipe)
├── acesso/     → abertura, como funciona, login, cadastro (escolha do papel)
├── usuario/    → telas do usuário
├── coleta/     → telas do coletador e da empresa (a aba Equipe só aparece para empresa)
└── data/       → pontos de descarte e Hall da Fama (dados de exemplo)
```

O roteamento por papel fica em `lib/acesso/rotas.dart`: depois do login ou do cadastro, **Usuário** vai para o Início e **Coletador/Empresa** vão para Pedidos.

### Plugins
| Plugin | Para quê |
|---|---|
| `camera` + `permission_handler` | câmera ao vivo e pedido de permissão (usuário) |
| `image_picker` | galeria e foto de perfil |
| `flutter_map` + `latlong2` | mapas OpenStreetMap (gratuito, sem chave; precisa de internet) |
| `url_launcher` | "Como chegar" (Google Maps) e "Ligar" |
| `google_fonts` | fonte Plus Jakarta Sans |

Os pontos de descarte do mapa são **exemplos** com nomes genéricos e localização aproximada em Belém (`lib/data/pontos.dart`).

## Onde conectar cada API

Hoje o app é **só frontend**: os dados ficam na memória. Para ligar ao backend (NestJS + PostgreSQL, **5 APIs em GraphQL**, como nos slides), **as telas não mudam**. Só o "miolo" dos métodos em `lib/state/` troca a lógica local por chamadas à API.

Cada ponto de conexão está marcado no código com um comentário **`[API ...]`**. No VS Code, use **Ctrl+Shift+F** e busque `[API` para ver todos.

### 1. API de acesso (login e cadastro)
| Onde | Método | Chamada sugerida |
|---|---|---|
| `lib/state/sessao.dart` | `entrar(email, senha)` | `mutation login(email, senha)` → token + conta **com o papel** (usuario, coletador ou empresa) |
| `lib/state/sessao.dart` | `cadastrar(conta)` | `mutation cadastrarConta(input)` → cria a conta no papel escolhido |
| `lib/state/coleta_state.dart` | `registrar(perfil)` | parte do `cadastrarConta`: CPF/CNPJ, veículo, materiais, ressocialização |
| `lib/state/coleta_state.dart` | `atualizar(...)` | `mutation atualizarPerfilColeta(input)`: veículo, materiais, bairros, equipe |
| `lib/state/app_state.dart` | `atualizarDados(...)` | `mutation atualizarUsuario(input)` |
| `lib/state/sessao.dart` | `sair()` | apagar o token salvo no aparelho |

### 2. API de fotos
| Onde | Método | Chamada sugerida |
|---|---|---|
| `lib/state/app_state.dart` | `definirFoto(bytes)` | upload da foto do resíduo → devolve `fotoId` (usado na consulta e no pedido) |
| `lib/state/app_state.dart` | `definirFotoPerfil(bytes)` | upload da foto de perfil → URL salva na conta |

As fotos já chegam prontas para envio (`Uint8List`) da câmera (`lib/usuario/foto.dart`) e da galeria.

### 3. API de materiais
| Onde | O quê | Chamada sugerida |
|---|---|---|
| `lib/core/data/residuos.dart` | lista `residuos` (15 resíduos com passos, alerta e destino) e `residuoPorId` | `query materiais` → categorias, resíduos e orientações |

É a mesma informação que o **painel administrativo em React** vai editar. Quando o app ler da API, o que o painel mudar aparece no app.

### 4. API de consultas (consultas e pedidos de coleta)
| Onde | Método | Chamada sugerida |
|---|---|---|
| `lib/state/app_state.dart` | `salvarConsulta()` | `mutation registrarConsulta(residuoId, fotoId)` |
| `lib/state/app_state.dart` | `criarPedido(...)` | `mutation solicitarColeta(input)` → pedido com status `enviado` |
| `lib/state/app_state.dart` | `atualizarPedidoDoUsuario(...)` | `query pedido(id)` ou `subscription statusDoPedido(id)` para o usuário ver o aceite |
| `lib/state/coleta_state.dart` | `novos` | `query pedidosDisponiveis(materiais, bairros)`, filtrado no servidor |
| `lib/state/coleta_state.dart` | `aceitar(pedido, responsavel)` | `mutation aceitarPedido(pedidoId, responsavel)`, e o servidor avisa o usuário |
| `lib/state/coleta_state.dart` | `recusar(pedido)` | `mutation recusarPedido(pedidoId)` |
| `lib/state/coleta_state.dart` | `concluir(pedido)` | `mutation concluirPedido(pedidoId)` |
| `lib/state/coleta_state.dart` | `receberDoUsuario(pedido)` | **some** com o backend: os pedidos chegam pela `pedidosDisponiveis` |

### 5. API de histórico
| Onde | Método | Chamada sugerida |
|---|---|---|
| `lib/state/app_state.dart` | `historico` | `query historico(usuarioId)` → consultas + coletas |
| `lib/state/coleta_state.dart` | `concluidos` | `query coletasConcluidas(perfilId)` |

### Fora das 5 APIs (hoje são dados de exemplo)
| O quê | Arquivo | Sugestão |
|---|---|---|
| Pontos de descarte do mapa | `lib/data/pontos.dart` | pode vir da API de materiais (cada ponto diz quais resíduos aceita) |
| Hall da Fama | `lib/data/ranking.dart` | pode ser calculado pela API de histórico |

### Como fazer a troca (passo a passo para a integração)
1. Adicione os pacotes: `flutter pub add graphql_flutter flutter_secure_storage`. O segundo guarda o token do login.
2. Crie a pasta `lib/api/` com um arquivo por API: `acesso_api.dart`, `fotos_api.dart`, `materiais_api.dart`, `consultas_api.dart` e `historico_api.dart`. Coloque o endereço do servidor num lugar só (ex.: `lib/api/config.dart`).
3. Em cada método marcado com `[API ...]`, troque a lógica local pela chamada da API. Os métodos que chamam o servidor passam a ser `async` (retornam `Future`). Nas telas, só é preciso colocar `await` nessas chamadas.
4. Rode `flutter test`. Os testes em `test/widget_test.dart` mostram o comportamento esperado de cada fluxo e ajudam a conferir se nada quebrou.

## Rodar no computador (VS Code)

1. Abra a pasta `ecoscan` no VS Code.
2. No terminal, só na primeira vez:
   ```
   flutter create . --project-name ecoscan --org br.unama.ecoscan --platforms android,web
   dart run tool/preparar_android.dart . "EcoScan" --camera
   flutter pub get
   dart run flutter_launcher_icons
   ```
3. Aperte **F5** → "EcoScan (Android)" (celular ou emulador) ou "EcoScan (Chrome, teste rápido)".
4. Testes automáticos da lógica (login por perfil, veículo, pedido do usuário chegando ao coletador): `flutter test`.

## Distribuir por QR Code (sem cabo)

O GitHub gera o APK na nuvem toda vez que o código é enviado e publica sempre no **mesmo link**:
```
https://github.com/SEU-USUARIO/ecoscan/releases/latest/download/ecoscan.apk
```

1. Crie um repositório **público** chamado `ecoscan` em github.com.
2. Envie o conteúdo da pasta `ecoscan`, incluindo a pasta oculta `.github`. O mais fácil é o **GitHub Desktop**: **File → Add local repository** → pasta `ecoscan` → **Publish repository** (desmarque "Keep this code private").
3. Na aba **Actions**, espere "Gerar APK" ficar ✅ verde (~8 min). O APK aparece em **Releases**. Se ficar ❌ vermelho, copie o erro e mande para o Claude.
4. Abra `qrcode/gerar_qrcode.html` no navegador, digite seu usuário do GitHub e imprima o cartaz. A página funciona sem internet.

**No celular:** aponta a câmera para o QR → baixa o `ecoscan.apk` → abre e permite **instalar apps desta fonte** → se o Play Protect avisar, **Mais detalhes → Instalar mesmo assim** → abre o EcoScan, cria a conta e escolhe o perfil.

## Para trocar dados de exemplo
| O quê | Arquivo |
|---|---|
| Materiais e orientações | `lib/core/data/residuos.dart` |
| Cores e fontes | `lib/core/theme.dart` |
| Contas de demonstração | `lib/state/sessao.dart` |
| Pedidos, equipe e veículo de demonstração | `lib/state/coleta_state.dart` |
| Pontos de descarte | `lib/data/pontos.dart` |
| Hall da Fama | `lib/data/ranking.dart` |
