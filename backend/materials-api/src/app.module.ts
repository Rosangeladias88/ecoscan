
import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { MaterialsModule } from './materials/materials.module';

@Module({
  imports: [PrismaModule, MaterialsModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
