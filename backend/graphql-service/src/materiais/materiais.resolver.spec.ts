import { Test, TestingModule } from '@nestjs/testing';
import { MateriaisResolver } from './materiais.resolver';

describe('MateriaisResolver', () => {
  let resolver: MateriaisResolver;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [MateriaisResolver],
    }).compile();

    resolver = module.get<MateriaisResolver>(MateriaisResolver);
  });

  it('should be defined', () => {
    expect(resolver).toBeDefined();
  });
});
