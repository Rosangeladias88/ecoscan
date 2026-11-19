import { Type } from 'class-transformer';
import { IsInt, IsOptional, Min } from 'class-validator';

export class CreateHistoryDto {
  @Type(() => Number)
  @IsInt()
  @Min(1)
  materialId: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  fotografiaId?: number | null;
}