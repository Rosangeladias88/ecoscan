import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { CreateHistoryDto } from './dto/create-history.dto';
import { HistoryService } from './history.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import type { AuthenticatedRequest } from '../auth/jwt-auth.guard';

@Controller('history')
@UseGuards(JwtAuthGuard)
export class HistoryController {
  constructor(private readonly historyService: HistoryService) {}

  @Post()
  create(
    @Body() data: CreateHistoryDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.historyService.create(
      data,
      request.user.id,
      request.headers.authorization,
    );
  }

  @Get()
  findAll(@Req() request: AuthenticatedRequest) {
    return this.historyService.findAll(request.user.id);
  }

  @Get(':id')
  findOne(
    @Param('id', ParseIntPipe) id: number,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.historyService.findOne(id, request.user.id);
  }
}