
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
    description: 'Cadastra um usuário com seu respectivo perfil.',
  })
  @ApiCreatedResponse({
    description: 'Usuário cadastrado com sucesso.',
  })
  @ApiBadRequestResponse({
    description: 'Dados inválidos.',
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
    @Req()
    request: Request & {
      user: {
        sub: number;
        email: string;
      };
    },
  ) {
    return this.authService.getProfile(request.user.sub);
  }
}
