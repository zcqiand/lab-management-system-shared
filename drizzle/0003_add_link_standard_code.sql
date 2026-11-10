ALTER TABLE "inspection_param_interface_links" ADD COLUMN "inspection_standard_code" text;--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_param_interface_links" ADD CONSTRAINT "pil_standard_fk" FOREIGN KEY ("inspection_standard_code") REFERENCES "public"."inspection_standards"("code") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
ALTER TABLE "inspection_param_interfaces" DROP COLUMN IF EXISTS "is_official";--> statement-breakpoint
ALTER TABLE "inspection_param_interfaces" DROP COLUMN IF EXISTS "sort_order";