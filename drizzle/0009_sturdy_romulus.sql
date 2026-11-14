ALTER TABLE "inspection_calculation_methods" DROP CONSTRAINT "calc_rule_standard_fk";
--> statement-breakpoint
ALTER TABLE "inspection_calculation_methods" ALTER COLUMN "testing_standard_code" SET NOT NULL;--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_calculation_methods" ADD CONSTRAINT "calc_rule_standard_fk" FOREIGN KEY ("testing_standard_code") REFERENCES "public"."inspection_standards"("code") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
ALTER TABLE "inspection_calculation_methods" DROP CONSTRAINT "inspection_calculation_rules_pkey";
--> statement-breakpoint
ALTER TABLE "inspection_calculation_methods" ADD CONSTRAINT "inspection_calculation_rules_pkey" PRIMARY KEY("inspection_object_code","inspection_parameter_code","testing_standard_code");