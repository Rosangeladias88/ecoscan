
import { Type } from 'class-transformer';
import { IsInt, Min } from 'class-validator';

export class CreateHistoryDto {
  @Type(() => Number)
  @IsInt()
  @Min(1)
  usuarioId: number;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  materialId: number;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  fotografiaId: number;
}
