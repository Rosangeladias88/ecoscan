
import {
  Controller,
  Get,
  Post,
  Param,
  UploadedFile,
  UseInterceptors,
  BadRequestException,
} from '@nestjs/common';

import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'node:path';
import { randomUUID } from 'node:crypto';
import { PhotosService } from './photos.service';

@Controller('photos')
export class PhotosController {
  constructor(
    private readonly photosService: PhotosService,
  ) {}

  @Post()
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads',
        filename: (_req, file, callback) => {
          const nome = randomUUID() + extname(file.originalname);
          callback(null, nome);
        },
      }),
      limits: {
        fileSize: 5 * 1024 * 1024,
      },
      fileFilter: (_req, file, callback) => {
        const permitidos = [
          'image/jpeg',
          'image/png',
          'image/webp',
        ];

        if (!permitidos.includes(file.mimetype)) {
          return callback(
            new BadRequestException(
              'Envie uma imagem JPG, PNG ou WEBP.',
            ),
            false,
          );
        }

        callback(null, true);
      },
    }),
  )
  upload(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException(
        'Nenhuma fotografia enviada.',
      );
    }

    return this.photosService.criar(file.filename);
  }

  @Get()
  listar() {
    return this.photosService.listar();
  }

  @Get(':id')
  buscarPorId(@Param('id') id: string) {
    return this.photosService.buscarPorId(id);
  }
}
