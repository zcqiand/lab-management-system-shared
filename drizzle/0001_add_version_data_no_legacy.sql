ALTER TABLE "inspection_param_interfaces" ADD COLUMN "version" integer DEFAULT 1 NOT NULL;--> statement-breakpoint
ALTER TABLE "test_records" ADD COLUMN "data" jsonb DEFAULT '{}'::jsonb NOT NULL;