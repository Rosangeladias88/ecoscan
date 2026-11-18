-- CreateTable
CREATE TABLE "fotos" (
    "id" SERIAL NOT NULL,
    "nome_arquivo" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "criado_em" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "fotos_pkey" PRIMARY KEY ("id")
);
