
import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import type { Request } from 'express';

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private readonly jwtService: JwtService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<Request>();

    const authorization = request.headers.authorization;
    const [type, token] = authorization?.split(' ') ?? [];

    if (type !== 'Bearer' || !token) {
      throw new UnauthorizedException(
        'Token de autenticação não fornecido.',
      );
    }

    try {
      const payload = await this.jwtService.verifyAsync<{
        sub: number;
        email: string;
      }>(token, {
        secret: process.env.JWT_SECRET,
        algorithms: ['HS256'],
      });

      if (!Number.isInteger(payload.sub) || payload.sub <= 0) {
        throw new UnauthorizedException('Token inválido.');
      }

      const authenticatedRequest = request as Request & {
  user: {
    sub: number;
    email: string;
  };
};

authenticatedRequest.user = payload;

      return true;
    } catch {
      throw new UnauthorizedException(
        'Token inválido ou expirado.',
      );
    }
  }
}
