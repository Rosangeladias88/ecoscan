
import {
  Body,
  Controller,
  Get,
  Headers,
  Post,
} from '@nestjs/common';

import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
  ) {}

  @Post('register')
  cadastrar(
    @Body()
    dados: {
      nome: string;
      email: string;
      senha: string;
      papel?: 'usuario' | 'coletador' | 'empresa';
    },
  ) {
    return this.authService.cadastrar(dados);
  }

  @Post('login')
  login(
    @Body()
    dados: {
      email: string;
      senha: string;
    },
  ) {
    return this.authService.login(dados);
  }

  @Get('me')
  perfil(
    @Headers('authorization') authorization?: string,
  ) {
    return this.authService.perfil(authorization);
  }
}
