
import { Body, Controller, Post } from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiCreatedResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';

import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';

@ApiTags('Autenticação')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @ApiOperation({
    summary: 'Cadastrar usuário',
    description: 'Valida os dados e simula o cadastro de um usuário.',
  })
  @ApiCreatedResponse({
    description: 'Dados aceitos. Cadastro simulado com sucesso.',
    schema: {
      example: {
        mensagem: 'Rota de cadastro do EcoScan funcionando!',
        nome: 'Maria Silva',
        email: 'maria@exemplo.com',
      },
    },
  })
  @ApiBadRequestResponse({
    description: 'Dados inválidos: nome, e-mail ou senha.',
  })
  register(@Body() dados: RegisterDto) {
    return this.authService.register(dados);
  }
  @Post('login')
@ApiOperation({
  summary: 'Realizar login do usuário',
})
login(@Body() dados: { email: string; senha: string }) {
  return this.authService.login(dados);
}
}

