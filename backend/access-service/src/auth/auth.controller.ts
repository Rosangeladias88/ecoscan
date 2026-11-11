
import {
  Body,
  Controller,
  Get,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiCreatedResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';

import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { JwtAuthGuard } from './jwt-auth.guard';
import type { Request } from 'express';

@ApiTags('Autenticação')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @ApiOperation({
    summary: 'Cadastrar usuário',
    description: 'Valida os dados e cadastra um usuário no PostgreSQL.',
  })
  @ApiCreatedResponse({
    description: 'Usuário cadastrado com sucesso no banco de dados.',
    schema: {
     
example: {
  message: 'Usuário cadastrado com sucesso!',
  usuario: {
    id: 1,
    nome: 'Maria Silva',
    email: 'maria@example.com',
    criadoEm: '2026-11-10T12:00:00.000Z',
  },
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

  @UseGuards(JwtAuthGuard)
  @Get('me')
  getProfile(
    @Req() request: Request & {
      user: { sub: number; email: string };
    },
  ) {
    return {
      message: 'Usuário autenticado com sucesso!',
      usuario: {
        id: request.user.sub,
        email: request.user.email,
      },
    };
  }

}

