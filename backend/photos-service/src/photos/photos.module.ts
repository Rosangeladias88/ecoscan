import { Module } from '@nestjs/common';
import { PhotosController } from './photos.controller';
import { PhotosService } from './photos.service';
import { JwtAuthModule } from '../auth/jwt.module';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Module({
  imports: [JwtAuthModule],
  controllers: [PhotosController],
  providers: [PhotosService, JwtAuthGuard],
})
export class PhotosModule {}