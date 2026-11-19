
import { Module } from '@nestjs/common';
import { HistoryController } from './history.controller';
import { HistoryService } from './history.service';
import { JwtAuthModule } from '../auth/jwt.module';

@Module({
  imports: [JwtAuthModule],
  controllers: [HistoryController],
  providers: [HistoryService],
})
export class HistoryModule {}
