import { Module } from '@nestjs/common';
import { MateriaisResolver } from './materiais.resolver';

@Module({
  providers: [MateriaisResolver]
})
export class MateriaisModule {}
