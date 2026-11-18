import {
  BadGatewayException,
  HttpException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { isAxiosError } from 'axios';
import FormData = require('form-data');
import { firstValueFrom } from 'rxjs';

@Injectable()
export class PhotosService {
  private readonly photosApiUrl = 'http://localhost:3001/photos';

  constructor(private readonly httpService: HttpService) {}

  private validarToken(authorization?: string): string {
    if (!authorization?.startsWith('Bearer ')) {
      throw new UnauthorizedException(
        'Token JWT não informado.',
      );
    }

    return authorization;
  }

  async enviar(
    arquivo: Express.Multer.File,
    authorization?: string,
  ) {
    const token = this.validarToken(authorization);
    const formulario = new FormData();

    formulario.append('file', arquivo.buffer, {
      filename: arquivo.originalname,
      contentType: arquivo.mimetype,
    });

    try {
      const resposta = await firstValueFrom(
        this.httpService.post(
          this.photosApiUrl,
          formulario,
          {
            headers: {
              ...formulario.getHeaders(),
              Authorization: token,
            },
            timeout: 15000,
            maxBodyLength: 6 * 1024 * 1024,
          },
        ),
      );

      return resposta.data;
    } catch (error) {
      this.tratarErro(error);
    }
  }

  async listar(authorization?: string) {
    const token = this.validarToken(authorization);

    try {
      const resposta = await firstValueFrom(
        this.httpService.get(this.photosApiUrl, {
          headers: {
            Authorization: token,
          },
          timeout: 5000,
        }),
      );

      return resposta.data;
    } catch (error) {
      this.tratarErro(error);
    }
  }

  async buscarPorId(
    id: number,
    authorization?: string,
  ) {
    const token = this.validarToken(authorization);

    try {
      const resposta = await firstValueFrom(
        this.httpService.get(
          `${this.photosApiUrl}/${id}`,
          {
            headers: {
              Authorization: token,
            },
            timeout: 5000,
          },
        ),
      );

      return resposta.data;
    } catch (error) {
      this.tratarErro(error);
    }
  }

  async buscarArquivo(
    id: number,
    authorization?: string,
  ) {
    const token = this.validarToken(authorization);

    try {
      const resposta = await firstValueFrom(
        this.httpService.get(
          `${this.photosApiUrl}/${id}/file`,
          {
            headers: {
              Authorization: token,
            },
            responseType: 'arraybuffer',
            timeout: 10000,
          },
        ),
      );

      return {
        buffer: Buffer.from(resposta.data),
        nomeArquivo: `fotografia-${id}`,
        contentType:
          resposta.headers['content-type'] ??
          'application/octet-stream',
      };
    } catch (error) {
      this.tratarErro(error);
    }
  }

  private tratarErro(error: unknown): never {
    if (isAxiosError(error) && error.response) {
      throw new HttpException(
        error.response.data,
        error.response.status,
      );
    }

    throw new BadGatewayException(
      'Não foi possível acessar a API Photos.',
    );
  }
}