
import {
  Injectable,
  BadGatewayException,
} from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class PhotosService {
  constructor(private readonly httpService: HttpService) {}

  async listar() {
    try {
      const resposta = await firstValueFrom(
        this.httpService.get('http://localhost:3001/photos', {
          timeout: 5000,
        }),
      );

      return resposta.data;
    } catch {
      throw new BadGatewayException(
        'Não foi possível acessar a API Photos.',
      );
    }
  }
}
