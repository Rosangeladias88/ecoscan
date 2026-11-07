
import { Injectable } from '@nestjs/common';

@Injectable()
export class AuthService {
  register(dados: { nome: string; email: string; senha: string }) {
    return {
      mensagem: 'Rota de cadastro do EcoScan funcionando!',
      nome: dados.nome,
      email: dados.email,
    };
  }
}
