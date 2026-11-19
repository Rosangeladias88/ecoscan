-- CreateTable
CREATE TABLE "Material" (
    "id" SERIAL NOT NULL,
    "nome" TEXT NOT NULL,
    "categoria" TEXT NOT NULL,
    "reciclavel" BOOLEAN NOT NULL,
    "ativo" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "Material_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Orientacao" (
    "id" SERIAL NOT NULL,
    "materialId" INTEGER NOT NULL,
    "preparo" TEXT NOT NULL,
    "destino" TEXT NOT NULL,

    CONSTRAINT "Orientacao_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Orientacao_materialId_key" ON "Orientacao"("materialId");

-- AddForeignKey
ALTER TABLE "Orientacao" ADD CONSTRAINT "Orientacao_materialId_fkey" FOREIGN KEY ("materialId") REFERENCES "Material"("id") ON DELETE CASCADE ON UPDATE CASCADE;
