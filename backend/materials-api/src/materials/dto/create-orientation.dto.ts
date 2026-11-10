
import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class CreateOrientationDto {
  @IsString({ message: 'O preparo deve ser um texto.' })
  @IsNotEmpty({ message: 'O preparo é obrigatório.' })
  @MaxLength(1000, { message: 'O preparo deve ter no máximo 1000 caracteres.' })
  preparo: string;

  @IsString({ message: 'O destino deve ser um texto.' })
  @IsNotEmpty({ message: 'O destino é obrigatório.' })
  @MaxLength(1000, { message: 'O destino deve ter no máximo 1000 caracteres.' })
  destino: string;
}
