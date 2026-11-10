
import {
  Injectable,
  ConflictException,
  BadRequestException,
  UnauthorizedException,
} from '@nestjs/common';

import { JwtService } from '@nestjs/jwt';
import { hash, compare } from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

  // CADASTRO DE USUÁRIOS
  async register(dados: {
    nome: string;
    email: string;
    senha: string;
  }) {
    const nome = dados?.nome?.trim();
    const email = dados?.email?.trim().toLowerCase();
    const senha = dados?.senha;

    if (!nome || !email || !senha) {
      throw new BadRequestException('Preencha todos os campos.');
    }

    if (senha.length < 8) {
      throw new BadRequestException(
        'A senha deve ter pelo menos 8 caracteres.',
      );
    }

    const usuarioExistente = await this.prisma.usuario.findUnique({
      where: { email },
    });

    if (usuarioExistente) {
      throw new ConflictException('E-mail já cadastrado.');
    }

    // Protege a senha antes de armazená-la.
    const senhaHash = await hash(senha, 12);

    try {
      const usuario = await this.prisma.usuario.create({
        data: {
          nome,
          email,
          senhaHash,
        },
        select: {
          id: true,
          nome: true,
          email: true,
          criadoEm: true,
        },
      });

      return {
        message: 'Usuário cadastrado com sucesso!',
        usuario,
      };
    } catch (erro) {
      if (
        typeof erro === 'object' &&
        erro !== null &&
        'code' in erro &&
        erro.code === 'P2002'
      ) {
        throw new ConflictException('E-mail já cadastrado.');
      }

      throw erro;
    }
  }

  // LOGIN E AUTENTICAÇÃO JWT
  async login(dados: { email: string; senha: string }) {
    const email = dados?.email?.trim().toLowerCase();
    const senha = dados?.senha;

    if (!email || !senha) {
      throw new UnauthorizedException('Credenciais inválidas.');
    }

    // Procura o usuário no PostgreSQL.
    const usuario = await this.prisma.usuario.findUnique({
      where: { email },
    });

    if (!usuario) {
      throw new UnauthorizedException('Credenciais inválidas.');
    }

    // Confere a senha informada com o hash armazenado.
    const senhaCorreta = await compare(
      senha,
      usuario.senhaHash,
    );

    if (!senhaCorreta) {
      throw new UnauthorizedException('Credenciais inválidas.');
    }

    // Gera um JWT assinado para o usuário autenticado.
    const accessToken = await this.jwtService.signAsync({
      sub: usuario.id,
      email: usuario.email,
    });

    return {
      message: 'Login realizado com sucesso!',
      access_token: accessToken,
      token_type: 'Bearer',
      usuario: {
        id: usuario.id,
        nome: usuario.nome,
        email: usuario.email,
      },
    };
  }
}
