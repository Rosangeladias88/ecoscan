
import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateHistoryDto } from './dto/create-history.dto';

@Injectable()
export class HistoryService {
  constructor(private readonly prisma: PrismaService) {}

  async create(data: CreateHistoryDto) {
    try {
      return await this.prisma.consulta.create({
        data: {
          usuarioId: data.usuarioId,
          materialId: data.materialId,
          fotografiaId: data.fotografiaId,
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
