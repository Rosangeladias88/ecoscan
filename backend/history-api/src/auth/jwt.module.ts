
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';

@Module({
  imports: [
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => {
        const secret = configService.get<string>('JWT_SECRET');

        if (!secret) {
          throw new Error('JWT_SECRET não configurado.');
        }

        return {
          secret,
          verifyOptions: {
            algorithms: ['HS256'],
          },
        };
      },
    }),
  ],
  exports: [JwtModule],
})
export class JwtAuthModule {}
