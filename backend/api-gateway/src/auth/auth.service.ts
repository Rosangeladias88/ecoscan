
import {
  Injectable,
  BadGatewayException,
  HttpException,
} from '@nestjs/common';

import { HttpService } from '@nestjs/axios';
import { isAxiosError } from 'axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class AuthService {
  constructor(
    private readonly httpService: HttpService,
  ) {}

  private tratarErro(erro: unknown): never {
    if (isAxiosError(erro) && erro.response) {
      throw new HttpException(
        erro.response.data,
        erro.response.status,
      );
    }

    throw new BadGatewayException(
      'Não foi possível acessar a API Access.',
    );
  }

  private async encaminhar(
    rota: 'register' | 'login',
    dados: Record<string, string>,
  ) {
    try {
      const resposta = await firstValueFrom(
        this.httpService.post(
          `http://localhost:3000/auth/${rota}`,
          dados,
          { timeout: 5000 },
        ),
      );

      return resposta.data;
    } catch (erro) {
      this.tratarErro(erro);
    }
  }

  cadastrar(dados: {
    nome: string;
    email: string;
    senha: string;
    papel?: 'usuario' | 'coletador' | 'empresa';
  }) {
    return this.encaminhar('register', dados);
  }

  login(dados: { email: string; senha: string }) {
    return this.encaminhar('login', dados);
  }

  async perfil(authorization?: string) {
    try {
      const resposta = await firstValueFrom(
        this.httpService.get(
          'http://localhost:3000/auth/me',
          {
            headers: {
              Authorization: authorization,
            },
            timeout: 5000,
          },
        ),
      );

      return resposta.data;
    } catch (erro) {
      this.tratarErro(erro);
    }
  }
}
