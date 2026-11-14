ALTER TABLE "inspection_technical_requirements" DROP CONSTRAINT "tech_req_brand_fk";
--> statement-breakpoint
ALTER TABLE "inspection_technical_requirements" DROP CONSTRAINT "tech_req_model_fk";
--> statement-breakpoint
ALTER TABLE "inspection_technical_requirements" DROP CONSTRAINT "tech_req_grade_fk";
--> statement-breakpoint
ALTER TABLE "inspection_technical_requirements" DROP CONSTRAINT "tech_req_spec_fk";
--> statement-breakpoint
-- V020 人工回填：变体列 NULL→''（drizzle generate 不生成回填；漏插 SET NOT NULL 直接炸现网 NULL 行——Review Focus 1）
UPDATE "inspection_technical_requirements" SET "brand" = '' WHERE "brand" IS NULL;--> statement-breakpoint
UPDATE "inspection_technical_requirements" SET "model" = '' WHERE "model" IS NULL;--> statement-breakpoint
UPDATE "inspection_technical_requirements" SET "grade" = '' WHERE "grade" IS NULL;--> statement-breakpoint
UPDATE "inspection_technical_requirements" SET "spec" = '' WHERE "spec" IS NULL;--> statement-breakpoint
UPDATE "inspection_technical_requirements" SET "sieve" = '' WHERE "sieve" IS NULL;--> statement-breakpoint
ALTER TABLE "inspection_technical_requirements" ALTER COLUMN "brand" SET DEFAULT '';--> statement-breakpoint
ALTER TABLE "inspection_technical_requirements" ALTER COLUMN "brand" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "inspection_technical_requirements" ALTER COLUMN "model" SET DEFAULT '';--> statement-breakpoint
ALTER TABLE "inspection_technical_requirements" ALTER COLUMN "model" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "inspection_technical_requirements" ALTER COLUMN "grade" SET DEFAULT '';--> statement-breakpoint
ALTER TABLE "inspection_technical_requirements" ALTER COLUMN "grade" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "inspection_technical_requirements" ALTER COLUMN "spec" SET DEFAULT '';--> statement-breakpoint
ALTER TABLE "inspection_technical_requirements" ALTER COLUMN "spec" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "inspection_technical_requirements" ALTER COLUMN "sieve" SET DEFAULT '';--> statement-breakpoint
ALTER TABLE "inspection_technical_requirements" ALTER COLUMN "sieve" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "inspection_technical_requirements" DROP CONSTRAINT "inspection_technical_requirements_pkey";
--> statement-breakpoint
ALTER TABLE "inspection_technical_requirements" ADD CONSTRAINT "inspection_technical_requirements_pkey" PRIMARY KEY("inspection_object_code","inspection_parameter_code","judgment_standard_code","brand","model","spec","grade","sieve");