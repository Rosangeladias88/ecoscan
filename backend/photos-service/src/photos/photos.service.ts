import {
  Injectable,
  InternalServerErrorException,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import {
  mkdir,
  writeFile,
  unlink,
  readFile,
} from 'node:fs/promises';
import { extname, join } from 'node:path';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class PhotosService {
  private readonly pastaUploads = join(process.cwd(), 'uploads');

  constructor(private readonly prisma: PrismaService) {}

  private identificarFormato(buffer: Buffer): {
    mime: string;
    extensao: string;
  } {
    if (
      buffer.length >= 3 &&
      buffer[0] === 0xff &&
      buffer[1] === 0xd8 &&
      buffer[2] === 0xff
    ) {
      return {
        mime: 'image/jpeg',
        extensao: '.jpg',
      };
    }

    if (
      buffer.length >= 8 &&
      buffer.subarray(0, 8).equals(
        Buffer.from([
          0x89, 0x50, 0x4e, 0x47,
          0x0d, 0x0a, 0x1a, 0x0a,
        ]),
      )
    ) {
      return {
        mime: 'image/png',
        extensao: '.png',
      };
    }

    if (
      buffer.length >= 12 &&
      buffer.toString('ascii', 0, 4) === 'RIFF' &&
      buffer.toString('ascii', 8, 12) === 'WEBP'
    ) {
      return {
        mime: 'image/webp',
        extensao: '.webp',
      };
    }

    throw new BadRequestException(
      'Arquivo inválido. Envie uma imagem JPEG, PNG ou WEBP.',
    );
  }

  async enviar(
    arquivo: Express.Multer.File,
    usuarioId: number,
  ) {
    const formato = this.identificarFormato(arquivo.buffer);

    if (arquivo.mimetype !== formato.mime) {
      throw new BadRequestException(
        'O conteúdo da imagem não corresponde ao formato informado.',
      );
    }

    const nomeArquivo = `${randomUUID()}${formato.extensao}`;
    const caminhoArquivo = join(
      this.pastaUploads,
      nomeArquivo,
    );

    let fotografiaId: number | null = null;

    try {
      await mkdir(this.pastaUploads, { recursive: true });

      await writeFile(caminhoArquivo, arquivo.buffer, {
        flag: 'wx',
      });

      const fotografia = await this.prisma.foto.create({
        data: {
          nomeArquivo,
          url: '',
          usuarioId,
        },
      });

      fotografiaId = fotografia.id;

      return await this.prisma.foto.update({
        where: {
          id: fotografia.id,
        },
        data: {
          url: `/photos/${fotografia.id}/file`,
        },
      });
    } catch {
      if (fotografiaId !== null) {
        await this.prisma.foto.deleteMany({
          where: {
            id: fotografiaId,
            usuarioId,
          },
        }).catch(() => undefined);
      }

      await unlink(caminhoArquivo).catch(() => undefined);

      throw new InternalServerErrorException(
        'Não foi possível salvar a fotografia.',
      );
    }
  }

  async listar(usuarioId: number) {
    return this.prisma.foto.findMany({
      where: {
        usuarioId,
      },
      orderBy: {
        criadoEm: 'desc',
      },
    });
  }

  async buscarPorId(id: number, usuarioId: number) {
    const fotografia = await this.prisma.foto.findFirst({
      where: {
        id,
        usuarioId,
      },
    });

    if (!fotografia) {
      throw new NotFoundException(
        'Fotografia não encontrada.',
      );
    }

    return fotografia;
  }

  async buscarArquivo(id: number, usuarioId: number) {
    const fotografia = await this.buscarPorId(
      id,
      usuarioId,
    );

    const caminhoArquivo = join(
      this.pastaUploads,
      fotografia.nomeArquivo,
    );

    try {
      const buffer = await readFile(caminhoArquivo);
      const extensao = extname(fotografia.nomeArquivo);

      const tipos: Record<string, string> = {
        '.jpg': 'image/jpeg',
        '.png': 'image/png',
        '.webp': 'image/webp',
      };

      return {
        buffer,
        nomeArquivo: fotografia.nomeArquivo,
        contentType: tipos[extensao] ?? 'application/octet-stream',
      };
    } catch {
      throw new NotFoundException(
        'Arquivo da fotografia não encontrado.',
      );
    }
  }
}