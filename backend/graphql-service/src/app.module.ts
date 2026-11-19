
import { Module } from '@nestjs/common';
import { GraphQLModule } from '@nestjs/graphql';
import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo';
import { join } from 'node:path';

import { AppController } from './app.controller';
import { AppService } from './app.service';
import { MateriaisModule } from './materiais/materiais.module';

@Module({
  imports: [
    GraphQLModule.forRoot<ApolloDriverConfig>({
      driver: ApolloDriver,
      autoSchemaFile: join(process.cwd(), 'src/schema.gql'),
      playground: false,
      graphiql: true,
    }),
    MateriaisModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
