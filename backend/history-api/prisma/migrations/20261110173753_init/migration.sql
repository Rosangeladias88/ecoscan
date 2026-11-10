-- CreateTable
CREATE TABLE "consultas" (
    "id" SERIAL NOT NULL,
    "usuario_id" INTEGER NOT NULL,
    "material_id" INTEGER NOT NULL,
    "fotografia_id" INTEGER NOT NULL,
    "criada_em" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "consultas_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "consultas_fotografia_id_key" ON "consultas"("fotografia_id");
