
import {
  BadGatewayException,
  HttpException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import axios from 'axios';
import { firstValueFrom } from 'rxjs';
import { AxiosError } from 'axios';

@Injectable()
export class HistoryService {
  constructor(private readonly httpService: HttpService) {}

  async listar(authorization?: string) {
    if (!authorization?.startsWith('Bearer ')) {
      throw new UnauthorizedException('Token JWT não informado.');
    }

    try {
      const resposta = await firstValueFrom(
        this.httpService.get('http://localhost:3003/history', {
          headers: { Authorization: authorization },
          timeout: 5000,
        }),
      );

      return resposta.data;
    

} catch (erro) {
  if (axios.isAxiosError(erro) && erro.response) {
    throw new HttpException(
      erro.response.data,
      erro.response.status,
    );
  }


  throw new BadGatewayException(
    'Não foi possível acessar a API de histórico.',
  );
}

}

async criar(
  dados: {
    materialId: number;
    fotografiaId: number;
  },
  authorization?: string,
) {
  if (!authorization?.startsWith('Bearer ')) {
    throw new UnauthorizedException('Token JWT não informado.');
  }

  try {
    const resposta = await firstValueFrom(
      this.httpService.post(
        'http://localhost:3003/history',
        dados,
        {
          headers: { Authorization: authorization },
          timeout: 5000,
        },
      ),
    );

    return resposta.data;
  } catch (erro) {
    console.error('HISTORY GATEWAY:', {
  code: axios.isAxiosError(erro) ? erro.code : undefined,
  status: axios.isAxiosError(erro) ? erro.response?.status : undefined,
  message: erro instanceof Error ? erro.message : String(erro),
});
    if (axios.isAxiosError(erro) && erro.response) {
      throw new HttpException(
        erro.response.data,
        erro.response.status,
      );
    }

    throw new BadGatewayException(
      'Não foi possível acessar a API de histórico.',
    );
  }
}
}
