-- CreateEnum
CREATE TYPE "Papel" AS ENUM ('usuario', 'coletador', 'empresa');

-- AlterTable
ALTER TABLE "Usuario" ADD COLUMN     "papel" "Papel" NOT NULL DEFAULT 'usuario';
