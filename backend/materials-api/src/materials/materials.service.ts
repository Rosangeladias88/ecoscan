
import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class MaterialsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.material.findMany({
      where: { ativo: true },
      include: { orientacao: true },
      orderBy: { nome: 'asc' },
    });
  }

  async findOne(id: number) {
    const material = await this.prisma.material.findUnique({
      where: { id },
      include: { orientacao: true },
    });

    if (!material || !material.ativo) {
      throw new NotFoundException('Material não encontrado.');
    }

    return material;
  }

  async create(data: {
    nome: string;
    categoria: string;
    reciclavel: boolean;
  }) {
    return this.prisma.material.create({
      data,
    });
  }

  async update(
    id: number,
    data: {
      nome?: string;
      categoria?: string;
      reciclavel?: boolean;
    },
  ) {
    await this.findOne(id);

    return this.prisma.material.update({
      where: { id },
      data,
    });
  }

  async deactivate(id: number) {
    await this.findOne(id);

    return this.prisma.material.update({
      where: { id },
      data: { ativo: false },
    });
  }
}
