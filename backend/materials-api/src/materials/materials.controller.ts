import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
} from '@nestjs/common';
import { MaterialsService } from './materials.service';
import { CreateMaterialDto } from './dto/create-material.dto';
import { UpdateMaterialDto } from './dto/update-material.dto';
import { CreateOrientationDto } from './dto/create-orientation.dto';

@Controller('materials')
export class MaterialsController {
  constructor(private readonly materialsService: MaterialsService) {}

  @Get()
  findAll() {
    return this.materialsService.findAll();
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.materialsService.findOne(id);
  }

  @Post()
  create(@Body() data: CreateMaterialDto) {
    return this.materialsService.create(data);
  }

  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() data: UpdateMaterialDto,
  ) {
    return this.materialsService.update(id, data);
  }

  @Patch(':id/deactivate')
  deactivate(@Param('id', ParseIntPipe) id: number) {
    return this.materialsService.deactivate(id);
  }

  @Post(':id/orientation')
  createOrientation(
    @Param('id', ParseIntPipe) id: number,
    @Body() data: CreateOrientationDto,
  ) {
    return this.materialsService.createOrientation(id, data);
  }

  @Patch(':id/orientation')
  updateOrientation(
    @Param('id', ParseIntPipe) id: number,
    @Body() data: CreateOrientationDto,
  ) {
    return this.materialsService.updateOrientation(id, data);
  }
}
