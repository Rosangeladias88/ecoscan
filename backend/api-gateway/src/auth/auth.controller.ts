
import {
  Body,
  Controller,
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
}
