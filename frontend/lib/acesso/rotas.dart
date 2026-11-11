import 'package:flutter/material.dart';

import '../coleta/shell.dart';
import '../state/sessao.dart';
import '../usuario/home_shell.dart';

/// Tela inicial de cada papel depois do login ou do cadastro.
Widget inicioDoPapel(Papel p) => p == Papel.usuario ? const HomeShell() : const ShellColeta();
