import {
  BadGatewayException,
  ConflictException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
  HttpException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateHistoryDto } from './dto/create-history.dto';

@Injectable()
export class HistoryService {
  private readonly photosApiUrl = (
    process.env.PHOTOS_API_URL ?? 'http://localhost:3001/photos'
  ).replace(/\/+$/, '');

  constructor(private readonly prisma: PrismaService) {}

  private async validarPropriedadeFotografia(
    fotografiaId: number,
    authorization?: string,
  ): Promise<void> {
    if (!authorization?.startsWith('Bearer ')) {
      throw new UnauthorizedException('Token JWT não informado.');
    }

    try {
      const resposta = await fetch(
        `${this.photosApiUrl}/${fotografiaId}`,
        {
          method: 'GET',
          headers: {
            Authorization: authorization,
          },
          signal: AbortSignal.timeout(5000),
        },
      );

      if (resposta.status === 404) {
        throw new NotFoundException(
          'Fotografia não encontrada ou não pertence a este usuário.',
        );
      }

      if (resposta.status === 401) {
        throw new UnauthorizedException(
          'Não foi possível autenticar o acesso à fotografia.',
        );
      }

      if (!resposta.ok) {
        throw new BadGatewayException(
          'Não foi possível validar a propriedade da fotografia.',
        );
      }
    } catch (error) {
      if (error instanceof HttpException) {
        throw error;
      }

      throw new BadGatewayException(
        'Não foi possível acessar a API de fotografias.',
      );
    }
  }

  async create(
    data: CreateHistoryDto,
    usuarioId: number,
    authorization?: string,
  ) {
    if (data.fotografiaId != null) {
      await this.validarPropriedadeFotografia(
        data.fotografiaId,
        authorization,
      );
    }

    try {
      return await this.prisma.consulta.create({
        data: {
          usuarioId,
          materialId: data.materialId,
          fotografiaId: data.fotografiaId ?? null,
        },
      });
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002'
      ) {
        throw new ConflictException(
          'Esta fotografia já possui uma consulta registrada.',
        );
      }

      throw error;
    }
  }

  async findAll(usuarioId: number) {
    return this.prisma.consulta.findMany({
      where: { usuarioId },
      orderBy: { criadaEm: 'desc' },
    });
  }

  async findOne(id: number, usuarioId: number) {
    const consulta = await this.prisma.consulta.findFirst({
      where: {
        id,
        usuarioId,
      },
    });

    if (!consulta) {
      throw new NotFoundException(
        'Consulta não encontrada no histórico deste usuário.',
      );
    }

    return consulta;
  }
}