import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import type { AuthenticatedRequest } from './authenticated-request';

interface JwtPayload {
  sub: string | number;
  email?: string;
}

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private readonly jwtService: JwtService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context
      .switchToHttp()
      .getRequest<AuthenticatedRequest>();

    const authorization = request.headers.authorization;

    if (!authorization?.startsWith('Bearer ')) {
      throw new UnauthorizedException('Token não informado.');
    }

    const token = authorization.slice(7).trim();

    if (!token) {
      throw new UnauthorizedException('Token não informado.');
    }

    try {
      const payload = await this.jwtService.verifyAsync<JwtPayload>(
        token,
        { algorithms: ['HS256'] },
      );

      const usuarioId = Number(payload.sub);

      if (!Number.isSafeInteger(usuarioId) || usuarioId <= 0) {
        throw new UnauthorizedException(
          'Identificador inválido no token.',
        );
      }

      request.user = {
        id: usuarioId,
        email: payload.email,
      };

      return true;
    } catch {
      throw new UnauthorizedException('Token inválido ou expirado.');
    }
  }
}