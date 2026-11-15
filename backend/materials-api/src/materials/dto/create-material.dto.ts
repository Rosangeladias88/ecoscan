
import { IsBoolean, IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class CreateMaterialDto {
  @IsString({ message: 'O nome deve ser um texto.' })
  @IsNotEmpty({ message: 'O nome é obrigatório.' })
  @MaxLength(100, { message: 'O nome deve ter no máximo 100 caracteres.' })
  nome: string;

  @IsString({ message: 'A categoria deve ser um texto.' })
  @IsNotEmpty({ message: 'A categoria é obrigatória.' })
  @MaxLength(60, { message: 'A categoria deve ter no máximo 60 caracteres.' })
  categoria: string;

  @IsBoolean({ message: 'O campo reciclavel deve ser verdadeiro ou falso.' })
  reciclavel: boolean;
}
