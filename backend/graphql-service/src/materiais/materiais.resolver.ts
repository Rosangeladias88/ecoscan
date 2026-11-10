
import { Query, Resolver } from '@nestjs/graphql';

@Resolver()
export class MateriaisResolver {
  @Query(() => [String], {
    name: 'materiais',
  })
  listarMateriais(): string[] {
    return [
      'Plástico',
      'Papel',
      'Vidro',
      'Metal',
      'Orgânico',
    ];
  }
}
