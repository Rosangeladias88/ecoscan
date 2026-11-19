
import { BadGatewayException, Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class MaterialsService {
  constructor(private readonly httpService: HttpService) {}

  async listar() {
    try {
      const resposta = await firstValueFrom(
        this.httpService.get('http://localhost:3002/materials', {
          timeout: 5000,
        }),
      );

      return resposta.data;
    } catch {
      throw new BadGatewayException(
        'Não foi possível acessar a API de materiais.',
      );
    }
  }
}
