import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PhotosModule } from './photos/photos.module';
import { AuthModule } from './auth/auth.module';
import { MaterialsModule } from './materials/materials.module';

@Module({
  imports: [PhotosModule, AuthModule, MaterialsModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
