import {
  BadRequestException,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Req,
  Res,
  StreamableFile,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import type { Response } from 'express';
import { memoryStorage } from 'multer';
import { PhotosService } from './photos.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import type { AuthenticatedRequest } from '../auth/authenticated-request';

@Controller('photos')
@UseGuards(JwtAuthGuard)
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
    @Req() request: AuthenticatedRequest,
  ) {
    if (!arquivo) {
      throw new BadRequestException(
        'Nenhuma fotografia enviada.',
      );
    }

    return this.photosService.enviar(
      arquivo,
      request.user.id,
    );
  }

  @Get()
  listar(@Req() request: AuthenticatedRequest) {
    return this.photosService.listar(request.user.id);
  }

  @Get(':id/file')
  async buscarArquivo(
    @Param('id', ParseIntPipe) id: number,
    @Req() request: AuthenticatedRequest,
    @Res({ passthrough: true }) response: Response,
  ) {
    const arquivo = await this.photosService.buscarArquivo(
      id,
      request.user.id,
    );

    response.setHeader('Content-Type', arquivo.contentType);
    response.setHeader(
      'Content-Disposition',
      `inline; filename="${arquivo.nomeArquivo}"`,
    );

    return new StreamableFile(arquivo.buffer);
  }

  @Get(':id')
  buscarPorId(
    @Param('id', ParseIntPipe) id: number,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.photosService.buscarPorId(
      id,
      request.user.id,
    );
  }
}