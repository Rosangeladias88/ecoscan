
import { Body, Controller, Post } from '@nestjs/common';

@Controller('auth')
export class AuthController {
  @Post('register')
  register(@Body() dados: { nome: string; email: string; senha: string }) {
    return {
      mensagem: 'Rota de cadastro do EcoScan funcionando!',
      nome: dados.nome,
      email: dados.email,
    };
  }
}
