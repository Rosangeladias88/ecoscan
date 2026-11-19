import {
  BadRequestException,
  Controller,
  Get,
  Headers,
  Param,
  ParseIntPipe,
  Post,
  Res,
  StreamableFile,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import type { Response } from 'express';
import { FileInterceptor } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';
import { PhotosService } from './photos.service';

@Controller('photos')
export class PhotosController {
  constructor(
    private readonly photosService: PhotosService,
  ) {}

  @Post()
  @UseInterceptors(
    FileInterceptor('file', {
      storage: memoryStorage(),
      limits: {
        fileSize: 5 * 1024 * 1024,
      },
    }),
  )
  enviar(
    @UploadedFile() arquivo: Express.Multer.File | undefined,
    @Headers('authorization') authorization?: string,
  ) {
    if (!arquivo) {
      throw new BadRequestException(
        'Nenhuma fotografia enviada.',
      );
    }

    return this.photosService.enviar(
      arquivo,
      authorization,
    );
  }

  @Get()
  listar(
    @Headers('authorization') authorization?: string,
  ) {
    return this.photosService.listar(authorization);
  }

  @Get(':id/file')
  async buscarArquivo(
    @Param('id', ParseIntPipe) id: number,
    @Headers('authorization') authorization: string | undefined,
    @Res({ passthrough: true }) response: Response,
  ) {
    const arquivo = await this.photosService.buscarArquivo(
      id,
      authorization,
    );

    const contentType =
      typeof arquivo.contentType === 'string'
        ? arquivo.contentType
        : 'application/octet-stream';

    response.setHeader('Content-Type', contentType);
    response.setHeader(
      'Content-Disposition',
      `inline; filename="${arquivo.nomeArquivo}"`,
    );

    return new StreamableFile(arquivo.buffer);
  }

  @Get(':id')
  buscarPorId(
    @Param('id', ParseIntPipe) id: number,
    @Headers('authorization') authorization?: string,
  ) {
    return this.photosService.buscarPorId(
      id,
      authorization,
    );
  }
}