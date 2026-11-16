
import { Body, Controller, Get, Headers, Post } from '@nestjs/common';
import { HistoryService } from './history.service';

@Controller('history')
export class HistoryController {
  constructor(
    private readonly historyService: HistoryService,
  ) {}

  @Get()
  listar(@Headers('authorization') authorization?: string) {
    return this.historyService.listar(authorization);
  }


@Post()
criar(
  @Body() dados: {
    materialId: number;
    fotografiaId: number;
  },
  @Headers('authorization') authorization?: string,
) {
  return this.historyService.criar(dados, authorization);
}
}