ALTER TABLE "fotos"
ADD COLUMN "usuario_id" INTEGER;

CREATE INDEX "fotos_usuario_id_idx"
ON "fotos"("usuario_id");