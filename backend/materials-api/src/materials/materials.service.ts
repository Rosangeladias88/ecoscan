
import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateMaterialDto } from './dto/create-material.dto';
import { UpdateMaterialDto } from './dto/update-material.dto';
import { CreateOrientationDto } from './dto/create-orientation.dto';

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

  async create(data: CreateMaterialDto) {
    return this.prisma.material.create({
      data,
    });
  }

  async update(id: number, data: UpdateMaterialDto) {
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

  async createOrientation(id: number, data: CreateOrientationDto) {
    await this.findOne(id);

    const existingOrientation = await this.prisma.orientacao.findUnique({
      where: { materialId: id },
    });

    if (existingOrientation) {
      throw new ConflictException(
        'Este material já possui uma orientação cadastrada.',
      );
    }

    return this.prisma.orientacao.create({
      data: {
        materialId: id,
        preparo: data.preparo,
        destino: data.destino,
      },
    });
  }

  async updateOrientation(id: number, data: CreateOrientationDto) {
    await this.findOne(id);

    const existingOrientation = await this.prisma.orientacao.findUnique({
      where: { materialId: id },
    });

    if (!existingOrientation) {
      throw new NotFoundException(
        'Orientação não encontrada para este material.',
      );
    }

    return this.prisma.orientacao.update({
      where: { materialId: id },
      data: {
        preparo: data.preparo,
        destino: data.destino,
      },
    });
  }
}
