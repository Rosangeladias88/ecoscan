
import { ApiProperty } from '@nestjs/swagger';
import {
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  MinLength,
} from 'class-validator';

import { Papel } from '../../generated/prisma/client';

export class RegisterDto {
  @ApiProperty({
    example: 'Maria Silva',
    description: 'Nome completo do usuário',
  })
  @IsString()
  @IsNotEmpty()
  nome: string;

  @ApiProperty({
    example: 'maria@exemplo.com',
    description: 'E-mail do usuário',
  })
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiProperty({
    example: 'SenhaTeste123!',
    description: 'Senha com no mínimo 8 caracteres',
    minLength: 8,
    writeOnly: true,
  })
  @IsString()
  @MinLength(8)
  senha: string;

  @ApiProperty({
    example: 'usuario',
    description: 'Perfil da conta',
    enum: Papel,
    required: false,
    default: Papel.usuario,
  })
  @IsOptional()
  @IsEnum(Papel)
  papel?: Papel;
}
