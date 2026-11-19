// Testes da lógica do EcoScan (rodam com: flutter test)
import 'package:ecoscan/core/core.dart';
import 'package:ecoscan/state/app_state.dart';
import 'package:ecoscan/state/coleta_state.dart';
import 'package:ecoscan/state/sessao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Login', () {
    test('cada conta de demonstração entra no seu perfil', () {
      expect(sessao.entrar('usuario@ecoscan.app', '123456')?.papel, Papel.usuario);
      expect(sessao.entrar('coletador@ecoscan.app', '123456')?.papel, Papel.coletador);
      expect(sessao.entrar('empresa@ecoscan.app', '123456')?.papel, Papel.empresa);
    });

    test('senha errada não entra', () {
      expect(sessao.entrar('usuario@ecoscan.app', 'errada'), isNull);
    });

    test('cadastro novo entra no papel escolhido', () {
      sessao.cadastrar(Conta(nome: 'Maria Teste', email: 'maria@teste.com', senha: 'abcdef', papel: Papel.usuario));
      expect(sessao.atual?.papel, Papel.usuario);
      expect(app.nome, 'Maria Teste');
    });
  });

  group('Coleta', () {
    test('coletador de triciclo é avisado que sofá não cabe; empresa não', () {
      final sofa = coleta.porId('ECO-2475')!;
      sessao.entrar('coletador@ecoscan.app', '123456');
      expect(coleta.perfil.veiculo, Veiculo.triciclo);
      expect(coleta.cabeNoVeiculo(sofa), isFalse);
      sessao.entrar('empresa@ecoscan.app', '123456');
      expect(coleta.cabeNoVeiculo(sofa), isTrue);
    });

    test('coletador só vê pedidos dos materiais que recolhe', () {
      sessao.entrar('coletador@ecoscan.app', '123456');
      for (final p in coleta.novos) {
        if (p.residuo != null) expect(coleta.perfil.materiais.contains(p.residuo!.categoria), isTrue);
      }
    });

    test('pedido do usuário chega para o coletador e o aceite volta para o usuário', () {
      sessao.entrar('usuario@ecoscan.app', '123456');
      final pedido = app.criarPedido(
        residuo: residuoPorId('oleo'),
        quantidade: '2 garrafas',
        endereco: 'Rua das Mangueiras, 120 · Nazaré',
        data: 'Amanhã',
        periodo: 'Manhã',
      );
      expect(pedido.status, StatusPedido.enviado);

      sessao.entrar('coletador@ecoscan.app', '123456');
      final doColetador = coleta.porId(pedido.id);
      expect(doColetador, isNotNull);
      expect(coleta.novos.contains(doColetador), isTrue);

      coleta.aceitar(doColetador!);
      expect(app.pedidoPorId(pedido.id)!.status, StatusPedido.aceito);
      expect(app.pedidoPorId(pedido.id)!.prestador, 'João Batista');
    });

    test('recusar tira o pedido só da lista de quem recusou', () {
      sessao.entrar('coletador@ecoscan.app', '123456');
      final p = coleta.novos.first;
      coleta.recusar(p);
      expect(coleta.novos.contains(p), isFalse);
      sessao.entrar('empresa@ecoscan.app', '123456');
      expect(coleta.novos.contains(p), isTrue);
    });
  });
}
