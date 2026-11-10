
import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Query,
} from '@nestjs/common';
import { CreateHistoryDto } from './dto/create-history.dto';
import { HistoryService } from './history.service';

@Controller('history')
export class HistoryController {
  constructor(private readonly historyService: HistoryService) {}

  @Post()
  create(@Body() data: CreateHistoryDto) {
    return this.historyService.create(data);
  }

  @Get()
  findAll(
    @Query('usuarioId', ParseIntPipe) usuarioId: number,
  ) {
    return this.historyService.findAll(usuarioId);
  }

  @Get(':id')
  findOne(
    @Param('id', ParseIntPipe) id: number,
    @Query('usuarioId', ParseIntPipe) usuarioId: number,
  ) {
    return this.historyService.findOne(id, usuarioId);
  }
}
