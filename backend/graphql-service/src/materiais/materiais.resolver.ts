import { Query, Resolver } from '@nestjs/graphql';

interface Material {
  id: number;
  nome: string;
  categoria: string;
  reciclavel: boolean;
  ativo: boolean;
}

@Resolver()
export class MateriaisResolver {
  @Query(() => [String], { name: 'materiais' })
  async listarMateriais(): Promise<string[]> {
    const resposta = await fetch(
      'http://localhost:3002/materials',
    );

    if (!resposta.ok) {
      throw new Error('Erro ao consultar a API de materiais');
    }

    const materiais = (await resposta.json()) as Material[];

return materiais.map((material) => material.nome);
  }
}