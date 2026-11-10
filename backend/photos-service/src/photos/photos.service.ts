
import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { randomUUID } from 'node:crypto';

export interface Foto {
  id: string;
  nomeArquivo: string;
  url: string;
  criadoEm: Date;
}

@Injectable()
export class PhotosService {
  private readonly fotos: Foto[] = [];

  criar(nomeArquivo: string): Foto {
    const foto: Foto = {
      id: randomUUID(),
      nomeArquivo,
      url: `/uploads/${nomeArquivo}`,
      criadoEm: new Date(),
    };

    this.fotos.push(foto);
    return foto;
  }

  listar(): Foto[] {
    return this.fotos;
  }

  buscarPorId(id: string): Foto {
    const foto = this.fotos.find(
      (item) => item.id === id,
    );

    if (!foto) {
      throw new NotFoundException(
        'Fotografia não encontrada.',
      );
    }

    return foto;
  }
}