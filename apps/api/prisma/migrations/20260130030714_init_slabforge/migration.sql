/*
  Warnings:

  - You are about to drop the `User` table. If the table is not empty, all the data it contains will be lost.

*/
-- CreateEnum
CREATE TYPE "Sport" AS ENUM ('NFL', 'NBA', 'MLB', 'NHL', 'NCAA_FOOTBALL', 'NCAA_BASKETBALL', 'OTHER');

-- CreateEnum
CREATE TYPE "SourceName" AS ENUM ('EBAY', 'PSA', 'POINT130', 'TCGPLAYER', 'PANINI', 'TOPPS', 'OTHER');

-- CreateEnum
CREATE TYPE "ListingStatus" AS ENUM ('ACTIVE', 'ENDED');

-- DropTable
DROP TABLE "User";

-- CreateTable
CREATE TABLE "CardSet" (
    "id" TEXT NOT NULL,
    "sport" "Sport" NOT NULL,
    "year" INTEGER NOT NULL,
    "brand" TEXT NOT NULL,
    "product" TEXT NOT NULL,
    "release" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CardSet_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Card" (
    "id" TEXT NOT NULL,
    "setId" TEXT NOT NULL,
    "playerName" TEXT NOT NULL,
    "cardNumber" TEXT NOT NULL,
    "team" TEXT,
    "rookieYear" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Card_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Variant" (
    "id" TEXT NOT NULL,
    "cardId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "isInsert" BOOLEAN NOT NULL DEFAULT false,
    "isSerial" BOOLEAN NOT NULL DEFAULT false,
    "printRun" INTEGER,
    "serialMax" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Variant_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "GradingCompany" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "GradingCompany_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SlabbedCard" (
    "id" TEXT NOT NULL,
    "variantId" TEXT NOT NULL,
    "gradingCompanyId" TEXT NOT NULL,
    "grade" DOUBLE PRECISION NOT NULL,
    "certNumber" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SlabbedCard_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Source" (
    "id" "SourceName" NOT NULL,
    "name" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Source_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EbayListing" (
    "id" TEXT NOT NULL,
    "sourceItemId" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "condition" TEXT,
    "currency" TEXT NOT NULL DEFAULT 'USD',
    "startPrice" DECIMAL(12,2),
    "buyItNowPrice" DECIMAL(12,2),
    "shippingPrice" DECIMAL(12,2),
    "sellerFeedbackPct" DOUBLE PRECISION,
    "endTime" TIMESTAMP(3),
    "status" "ListingStatus" NOT NULL DEFAULT 'ACTIVE',
    "rawHash" TEXT,
    "lastFetchedAt" TIMESTAMP(3),
    "rawPayload" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "EbayListing_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MarketSale" (
    "id" TEXT NOT NULL,
    "variantId" TEXT,
    "source" "SourceName" NOT NULL DEFAULT 'EBAY',
    "sourceItemId" TEXT NOT NULL,
    "soldAt" TIMESTAMP(3) NOT NULL,
    "price" DECIMAL(12,2) NOT NULL,
    "shipping" DECIMAL(12,2),
    "totalPrice" DECIMAL(12,2),
    "currency" TEXT NOT NULL DEFAULT 'USD',
    "titleSnapshot" TEXT NOT NULL,
    "gradeDetected" TEXT,
    "confidence" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MarketSale_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "QueryCache" (
    "id" TEXT NOT NULL,
    "source" "SourceName" NOT NULL,
    "queryKey" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "QueryCache_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PopReportSnapshot" (
    "id" TEXT NOT NULL,
    "variantId" TEXT NOT NULL,
    "asOfDate" DATE NOT NULL,
    "totalGraded" INTEGER NOT NULL,
    "byGrade" JSONB NOT NULL,
    "source" "SourceName" NOT NULL DEFAULT 'PSA',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PopReportSnapshot_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ChecklistEntry" (
    "id" TEXT NOT NULL,
    "setId" TEXT NOT NULL,
    "cardNumber" TEXT NOT NULL,
    "playerName" TEXT NOT NULL,
    "team" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ChecklistEntry_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ParallelDefinition" (
    "id" TEXT NOT NULL,
    "setId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "serialMax" INTEGER,
    "rarityTier" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ParallelDefinition_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SetVariantMap" (
    "id" TEXT NOT NULL,
    "cardId" TEXT NOT NULL,
    "parallelDefinitionId" TEXT NOT NULL,

    CONSTRAINT "SetVariantMap_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CompSnapshot" (
    "id" TEXT NOT NULL,
    "variantId" TEXT,
    "source" "SourceName" NOT NULL DEFAULT 'POINT130',
    "observedAt" TIMESTAMP(3) NOT NULL,
    "compCount" INTEGER,
    "median" DECIMAL(12,2),
    "mean" DECIMAL(12,2),
    "p10" DECIMAL(12,2),
    "p90" DECIMAL(12,2),
    "payload" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CompSnapshot_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "CardSet_sport_year_idx" ON "CardSet"("sport", "year");

-- CreateIndex
CREATE INDEX "CardSet_brand_product_idx" ON "CardSet"("brand", "product");

-- CreateIndex
CREATE UNIQUE INDEX "CardSet_sport_year_brand_product_release_key" ON "CardSet"("sport", "year", "brand", "product", "release");

-- CreateIndex
CREATE INDEX "Card_setId_idx" ON "Card"("setId");

-- CreateIndex
CREATE INDEX "Card_playerName_idx" ON "Card"("playerName");

-- CreateIndex
CREATE INDEX "Card_cardNumber_idx" ON "Card"("cardNumber");

-- CreateIndex
CREATE UNIQUE INDEX "Card_setId_cardNumber_playerName_key" ON "Card"("setId", "cardNumber", "playerName");

-- CreateIndex
CREATE INDEX "Variant_cardId_idx" ON "Variant"("cardId");

-- CreateIndex
CREATE INDEX "Variant_name_idx" ON "Variant"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Variant_cardId_name_serialMax_key" ON "Variant"("cardId", "name", "serialMax");

-- CreateIndex
CREATE INDEX "SlabbedCard_variantId_gradingCompanyId_grade_idx" ON "SlabbedCard"("variantId", "gradingCompanyId", "grade");

-- CreateIndex
CREATE UNIQUE INDEX "SlabbedCard_gradingCompanyId_certNumber_key" ON "SlabbedCard"("gradingCompanyId", "certNumber");

-- CreateIndex
CREATE UNIQUE INDEX "EbayListing_sourceItemId_key" ON "EbayListing"("sourceItemId");

-- CreateIndex
CREATE INDEX "EbayListing_status_endTime_idx" ON "EbayListing"("status", "endTime");

-- CreateIndex
CREATE INDEX "EbayListing_lastFetchedAt_idx" ON "EbayListing"("lastFetchedAt");

-- CreateIndex
CREATE INDEX "MarketSale_variantId_soldAt_idx" ON "MarketSale"("variantId", "soldAt" DESC);

-- CreateIndex
CREATE INDEX "MarketSale_soldAt_idx" ON "MarketSale"("soldAt" DESC);

-- CreateIndex
CREATE INDEX "MarketSale_source_soldAt_idx" ON "MarketSale"("source", "soldAt" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "MarketSale_source_sourceItemId_key" ON "MarketSale"("source", "sourceItemId");

-- CreateIndex
CREATE INDEX "QueryCache_expiresAt_idx" ON "QueryCache"("expiresAt");

-- CreateIndex
CREATE UNIQUE INDEX "QueryCache_source_queryKey_key" ON "QueryCache"("source", "queryKey");

-- CreateIndex
CREATE INDEX "PopReportSnapshot_variantId_asOfDate_idx" ON "PopReportSnapshot"("variantId", "asOfDate" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "PopReportSnapshot_variantId_asOfDate_key" ON "PopReportSnapshot"("variantId", "asOfDate");

-- CreateIndex
CREATE INDEX "ChecklistEntry_setId_idx" ON "ChecklistEntry"("setId");

-- CreateIndex
CREATE INDEX "ChecklistEntry_playerName_idx" ON "ChecklistEntry"("playerName");

-- CreateIndex
CREATE UNIQUE INDEX "ChecklistEntry_setId_cardNumber_playerName_key" ON "ChecklistEntry"("setId", "cardNumber", "playerName");

-- CreateIndex
CREATE INDEX "ParallelDefinition_setId_idx" ON "ParallelDefinition"("setId");

-- CreateIndex
CREATE INDEX "ParallelDefinition_name_idx" ON "ParallelDefinition"("name");

-- CreateIndex
CREATE UNIQUE INDEX "ParallelDefinition_setId_name_serialMax_key" ON "ParallelDefinition"("setId", "name", "serialMax");

-- CreateIndex
CREATE INDEX "SetVariantMap_parallelDefinitionId_idx" ON "SetVariantMap"("parallelDefinitionId");

-- CreateIndex
CREATE UNIQUE INDEX "SetVariantMap_cardId_parallelDefinitionId_key" ON "SetVariantMap"("cardId", "parallelDefinitionId");

-- CreateIndex
CREATE INDEX "CompSnapshot_variantId_observedAt_idx" ON "CompSnapshot"("variantId", "observedAt" DESC);

-- CreateIndex
CREATE INDEX "CompSnapshot_observedAt_idx" ON "CompSnapshot"("observedAt" DESC);

-- CreateIndex
CREATE INDEX "CompSnapshot_source_observedAt_idx" ON "CompSnapshot"("source", "observedAt" DESC);

-- AddForeignKey
ALTER TABLE "Card" ADD CONSTRAINT "Card_setId_fkey" FOREIGN KEY ("setId") REFERENCES "CardSet"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Variant" ADD CONSTRAINT "Variant_cardId_fkey" FOREIGN KEY ("cardId") REFERENCES "Card"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SlabbedCard" ADD CONSTRAINT "SlabbedCard_variantId_fkey" FOREIGN KEY ("variantId") REFERENCES "Variant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SlabbedCard" ADD CONSTRAINT "SlabbedCard_gradingCompanyId_fkey" FOREIGN KEY ("gradingCompanyId") REFERENCES "GradingCompany"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MarketSale" ADD CONSTRAINT "MarketSale_variantId_fkey" FOREIGN KEY ("variantId") REFERENCES "Variant"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PopReportSnapshot" ADD CONSTRAINT "PopReportSnapshot_variantId_fkey" FOREIGN KEY ("variantId") REFERENCES "Variant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ChecklistEntry" ADD CONSTRAINT "ChecklistEntry_setId_fkey" FOREIGN KEY ("setId") REFERENCES "CardSet"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ParallelDefinition" ADD CONSTRAINT "ParallelDefinition_setId_fkey" FOREIGN KEY ("setId") REFERENCES "CardSet"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SetVariantMap" ADD CONSTRAINT "SetVariantMap_cardId_fkey" FOREIGN KEY ("cardId") REFERENCES "Card"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SetVariantMap" ADD CONSTRAINT "SetVariantMap_parallelDefinitionId_fkey" FOREIGN KEY ("parallelDefinitionId") REFERENCES "ParallelDefinition"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CompSnapshot" ADD CONSTRAINT "CompSnapshot_variantId_fkey" FOREIGN KEY ("variantId") REFERENCES "Variant"("id") ON DELETE SET NULL ON UPDATE CASCADE;
