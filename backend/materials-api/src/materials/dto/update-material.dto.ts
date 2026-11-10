
import { IsBoolean, IsOptional, IsString, MaxLength, IsNotEmpty } from 'class-validator';

export class UpdateMaterialDto {
  @IsOptional()
  @IsString({ message: 'O nome deve ser um texto.' })
  @IsNotEmpty({ message: 'O nome não pode ficar vazio.' })
  @MaxLength(100, { message: 'O nome deve ter no máximo 100 caracteres.' })
  nome?: string;

  @IsOptional()
  @IsString({ message: 'A categoria deve ser um texto.' })
  @IsNotEmpty({ message: 'A categoria não pode ficar vazia.' })
  @MaxLength(60, { message: 'A categoria deve ter no máximo 60 caracteres.' })
  categoria?: string;

  @IsOptional()
  @IsBoolean({ message: 'O campo reciclavel deve ser verdadeiro ou falso.' })
  reciclavel?: boolean;
}
