CREATE TYPE "public"."audit_action" AS ENUM('login', 'logout', 'create', 'update', 'delete', 'flow', 'export', 'other');--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "audit_events" (
	"id" text PRIMARY KEY NOT NULL,
	"action" "audit_action" NOT NULL,
	"operator" text NOT NULL,
	"target" text NOT NULL,
	"target_id" text,
	"detail" text,
	"ip" text,
	"at" text NOT NULL,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL,
	"tenant_id" text DEFAULT '' NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "contracts" (
	"id" text PRIMARY KEY NOT NULL,
	"contract_code" text NOT NULL,
	"client_unit" text NOT NULL,
	"project_name" text NOT NULL,
	"project_location" text,
	"construction_unit" text NOT NULL,
	"inspection_specialty_code" text,
	"building_unit" text,
	"supervisor_unit" text,
	"inspection_person" text,
	"inspection_phone" text,
	"witness_unit" text NOT NULL,
	"witness" text NOT NULL,
	"witness_phone" text,
	"contact_person" text,
	"contact_phone" text,
	"entrusted_date" text,
	"status" text DEFAULT 'active' NOT NULL,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL,
	"tenant_id" text DEFAULT '' NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "inspection_brands" (
	"code" text PRIMARY KEY NOT NULL,
	"inspection_object_code" text,
	"name" text NOT NULL,
	"remark" text,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL,
	"tenant_id" text DEFAULT '' NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "inspection_calculation_methods" (
	"inspection_object_code" text NOT NULL,
	"inspection_parameter_code" text NOT NULL,
	"testing_standard_code" text,
	"report_name_code" text,
	"algorithm_type" text DEFAULT 'manual' NOT NULL,
	"specimen_count" integer DEFAULT 1 NOT NULL,
	"formula" text,
	"conditions" text,
	"rounding_rule" text,
	"remark" text,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL,
	CONSTRAINT "inspection_calculation_rules_pkey" PRIMARY KEY("inspection_object_code","inspection_parameter_code")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "inspection_grades" (
	"code" text PRIMARY KEY NOT NULL,
	"inspection_object_code" text,
	"name" text NOT NULL,
	"remark" text,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL,
	"tenant_id" text DEFAULT '' NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "inspection_models" (
	"code" text PRIMARY KEY NOT NULL,
	"inspection_object_code" text,
	"name" text NOT NULL,
	"remark" text,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL,
	"tenant_id" text DEFAULT '' NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "inspection_object_parameters" (
	"inspection_object_code" text NOT NULL,
	"inspection_parameter_code" text NOT NULL,
	"qualification_level" text DEFAULT 'QUALIFIED' NOT NULL,
	"source_page" integer,
	"remark" text,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL,
	CONSTRAINT "inspection_object_parameters_pkey" PRIMARY KEY("inspection_object_code","inspection_parameter_code")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "inspection_object_report_names" (
	"inspection_object_code" text NOT NULL,
	"report_name_code" text NOT NULL,
	"remark" text,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL,
	CONSTRAINT "inspection_object_report_names_pkey" PRIMARY KEY("inspection_object_code","report_name_code")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "inspection_object_standards" (
	"inspection_object_code" text NOT NULL,
	"inspection_standard_code" text NOT NULL,
	"role" text NOT NULL,
	"remark" text,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL,
	CONSTRAINT "inspection_object_standards_pkey" PRIMARY KEY("inspection_object_code","inspection_standard_code","role")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "inspection_objects" (
	"code" text PRIMARY KEY NOT NULL,
	"inspection_specialty_code" text NOT NULL,
	"source_project_no" text NOT NULL,
	"source_project_name" text NOT NULL,
	"name" text NOT NULL,
	"is_optional_for_qualification" boolean DEFAULT false NOT NULL,
	"is_official" boolean DEFAULT true NOT NULL,
	"enabled" boolean DEFAULT true NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "inspection_param_interface_links" (
	"inspection_parameter_code" text NOT NULL,
	"param_interface_code" text NOT NULL,
	"report_name_code" text,
	"config" jsonb,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL,
	CONSTRAINT "param_interface_links_pkey" PRIMARY KEY("inspection_parameter_code","param_interface_code")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "inspection_param_interfaces" (
	"code" text NOT NULL,
	"name" text,
	"component_path" text NOT NULL,
	"description" text,
	"is_official" boolean,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"config" jsonb,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL,
	CONSTRAINT "param_interfaces_pkey" PRIMARY KEY("code")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "inspection_parameters" (
	"code" text PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"raw_name" text NOT NULL,
	"canonical_name" text NOT NULL,
	"method_text" text,
	"aliases" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"unit" text,
	"source_type" text DEFAULT 'official' NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "inspection_report_name_parameters" (
	"report_name_code" text NOT NULL,
	"inspection_parameter_code" text NOT NULL,
	"remark" text,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL,
	CONSTRAINT "inspection_report_name_parameters_pkey" PRIMARY KEY("report_name_code","inspection_parameter_code")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "inspection_report_name_standards" (
	"report_name_code" text NOT NULL,
	"inspection_standard_code" text NOT NULL,
	"role" text NOT NULL,
	"remark" text,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL,
	CONSTRAINT "inspection_report_name_standards_pkey" PRIMARY KEY("report_name_code","inspection_standard_code","role")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "inspection_report_names" (
	"code" text PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"full_name" text,
	"template_path" text,
	"summary_name" text,
	"ext_fields" jsonb,
	"description" text,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "inspection_specialties" (
	"code" text PRIMARY KEY NOT NULL,
	"official_no" text NOT NULL,
	"name" text NOT NULL,
	"is_official" boolean DEFAULT true NOT NULL,
	"enabled" boolean DEFAULT true NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "inspection_specialty_objects" (
	"inspection_specialty_code" text NOT NULL,
	"inspection_object_code" text NOT NULL,
	"remark" text,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL,
	CONSTRAINT "inspection_specialty_objects_pkey" PRIMARY KEY("inspection_specialty_code","inspection_object_code")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "inspection_specs" (
	"code" text PRIMARY KEY NOT NULL,
	"inspection_object_code" text,
	"name" text NOT NULL,
	"remark" text,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL,
	"tenant_id" text DEFAULT '' NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "inspection_standard_parameters" (
	"inspection_standard_code" text NOT NULL,
	"inspection_parameter_code" text NOT NULL,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL,
	CONSTRAINT "inspection_standard_parameters_pkey" PRIMARY KEY("inspection_standard_code","inspection_parameter_code")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "inspection_standards" (
	"code" text PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"version" text,
	"status" text DEFAULT 'active' NOT NULL,
	"source_document_id" text,
	"source_hash" text,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "inspection_technical_requirements" (
	"inspection_object_code" text NOT NULL,
	"inspection_parameter_code" text NOT NULL,
	"judgment_standard_code" text NOT NULL,
	"conditions" text,
	"value_type" text DEFAULT 'numeric' NOT NULL,
	"min_value" integer,
	"max_value" integer,
	"target_value" text,
	"expression" text,
	"unit" text,
	"comparison" text NOT NULL,
	"judgment_mode" text DEFAULT 'manual' NOT NULL,
	"verification_status" text DEFAULT 'draft' NOT NULL,
	"clause" text,
	"source_page" integer,
	"source_hash" text,
	"brand" text,
	"model" text,
	"grade" text,
	"spec" text,
	"sieve" text,
	"remark" text,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL,
	"tenant_id" text DEFAULT '' NOT NULL,
	CONSTRAINT "inspection_technical_requirements_pkey" PRIMARY KEY("inspection_object_code","inspection_parameter_code","judgment_standard_code")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "sample_receipts" (
	"id" text PRIMARY KEY NOT NULL,
	"contract_id" text NOT NULL,
	"commission_code" text NOT NULL,
	"commission_date" text NOT NULL,
	"commission_register_code" text,
	"commission_register_date" text,
	"category_code" text NOT NULL,
	"project_name" text,
	"client_unit" text,
	"building_unit" text,
	"supervisor_unit" text,
	"construction_unit" text,
	"witness_unit" text,
	"sampling_location" text,
	"witness" text,
	"witness_phone" text,
	"inspector" text,
	"inspector_phone" text,
	"received_by" text NOT NULL,
	"sample_source" text NOT NULL,
	"test_category" text NOT NULL,
	"test_environment" text,
	"main_equipment" text,
	"test_operator" text,
	"test_start_date" text,
	"test_end_date" text,
	"original_record_no" text,
	"remark" text,
	"judgment_basis" jsonb,
	"testing_basis" jsonb,
	"test_parameters" jsonb,
	"flow_status" text DEFAULT 'receiving' NOT NULL,
	"flow_history" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"last_submitted_by" text,
	"assignee_id" text,
	"assignee_name" text,
	"planned_test_date" text,
	"report_code" text,
	"report_date" text,
	"conclusion" text,
	"result" text,
	"issued_at" timestamp with time zone,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL,
	"tenant_id" text DEFAULT '' NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "samples" (
	"id" text PRIMARY KEY NOT NULL,
	"receipt_id" text NOT NULL,
	"sample_code" text NOT NULL,
	"sample_name" text,
	"model" text,
	"specification" text,
	"grade" text,
	"brand" text,
	"manufacturer" text,
	"structural_part" text,
	"represent_quantity" text,
	"sample_quantity" text,
	"batch_number" text,
	"supply_unit" text,
	"arrival_date" text,
	"sampling_date" text,
	"curing_condition" text,
	"age" text,
	"ext" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"remark" text,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL,
	"tenant_id" text DEFAULT '' NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "test_records" (
	"id" text PRIMARY KEY NOT NULL,
	"sample_id" text NOT NULL,
	"parameter_code" text NOT NULL,
	"standard_code" text,
	"requirement_code" text,
	"requirement" text NOT NULL,
	"result" text NOT NULL,
	"verdict" text,
	"created_at" text DEFAULT '' NOT NULL,
	"updated_at" text DEFAULT '' NOT NULL,
	"tenant_id" text DEFAULT '' NOT NULL
);
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "contracts" ADD CONSTRAINT "contracts_specialty_fk" FOREIGN KEY ("inspection_specialty_code") REFERENCES "public"."inspection_specialties"("code") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_brands" ADD CONSTRAINT "brands_object_fk" FOREIGN KEY ("inspection_object_code") REFERENCES "public"."inspection_objects"("code") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_calculation_methods" ADD CONSTRAINT "calc_rule_object_fk" FOREIGN KEY ("inspection_object_code") REFERENCES "public"."inspection_objects"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_calculation_methods" ADD CONSTRAINT "calc_rule_parameter_fk" FOREIGN KEY ("inspection_parameter_code") REFERENCES "public"."inspection_parameters"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_calculation_methods" ADD CONSTRAINT "calc_rule_standard_fk" FOREIGN KEY ("testing_standard_code") REFERENCES "public"."inspection_standards"("code") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_calculation_methods" ADD CONSTRAINT "calc_rule_report_fk" FOREIGN KEY ("report_name_code") REFERENCES "public"."inspection_report_names"("code") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_grades" ADD CONSTRAINT "grades_object_fk" FOREIGN KEY ("inspection_object_code") REFERENCES "public"."inspection_objects"("code") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_models" ADD CONSTRAINT "models_object_fk" FOREIGN KEY ("inspection_object_code") REFERENCES "public"."inspection_objects"("code") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_object_parameters" ADD CONSTRAINT "obj_params_object_fk" FOREIGN KEY ("inspection_object_code") REFERENCES "public"."inspection_objects"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_object_parameters" ADD CONSTRAINT "obj_params_parameter_fk" FOREIGN KEY ("inspection_parameter_code") REFERENCES "public"."inspection_parameters"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_object_report_names" ADD CONSTRAINT "obj_rn_object_fk" FOREIGN KEY ("inspection_object_code") REFERENCES "public"."inspection_objects"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_object_report_names" ADD CONSTRAINT "obj_rn_report_fk" FOREIGN KEY ("report_name_code") REFERENCES "public"."inspection_report_names"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_object_standards" ADD CONSTRAINT "obj_std_object_fk" FOREIGN KEY ("inspection_object_code") REFERENCES "public"."inspection_objects"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_object_standards" ADD CONSTRAINT "obj_std_standard_fk" FOREIGN KEY ("inspection_standard_code") REFERENCES "public"."inspection_standards"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_objects" ADD CONSTRAINT "objects_specialty_fk" FOREIGN KEY ("inspection_specialty_code") REFERENCES "public"."inspection_specialties"("code") ON DELETE restrict ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_param_interface_links" ADD CONSTRAINT "pil_param_fk" FOREIGN KEY ("inspection_parameter_code") REFERENCES "public"."inspection_parameters"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_param_interface_links" ADD CONSTRAINT "pil_interface_fk" FOREIGN KEY ("param_interface_code") REFERENCES "public"."inspection_param_interfaces"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_param_interface_links" ADD CONSTRAINT "pil_report_fk" FOREIGN KEY ("report_name_code") REFERENCES "public"."inspection_report_names"("code") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_report_name_parameters" ADD CONSTRAINT "rn_param_report_fk" FOREIGN KEY ("report_name_code") REFERENCES "public"."inspection_report_names"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_report_name_parameters" ADD CONSTRAINT "rn_param_parameter_fk" FOREIGN KEY ("inspection_parameter_code") REFERENCES "public"."inspection_parameters"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_report_name_standards" ADD CONSTRAINT "rn_std_report_fk" FOREIGN KEY ("report_name_code") REFERENCES "public"."inspection_report_names"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_report_name_standards" ADD CONSTRAINT "rn_std_standard_fk" FOREIGN KEY ("inspection_standard_code") REFERENCES "public"."inspection_standards"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_specialty_objects" ADD CONSTRAINT "specialty_objects_specialty_fk" FOREIGN KEY ("inspection_specialty_code") REFERENCES "public"."inspection_specialties"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_specialty_objects" ADD CONSTRAINT "specialty_objects_object_fk" FOREIGN KEY ("inspection_object_code") REFERENCES "public"."inspection_objects"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_specs" ADD CONSTRAINT "specs_object_fk" FOREIGN KEY ("inspection_object_code") REFERENCES "public"."inspection_objects"("code") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_standard_parameters" ADD CONSTRAINT "std_param_standard_fk" FOREIGN KEY ("inspection_standard_code") REFERENCES "public"."inspection_standards"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_standard_parameters" ADD CONSTRAINT "std_param_parameter_fk" FOREIGN KEY ("inspection_parameter_code") REFERENCES "public"."inspection_parameters"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_technical_requirements" ADD CONSTRAINT "tech_req_object_fk" FOREIGN KEY ("inspection_object_code") REFERENCES "public"."inspection_objects"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_technical_requirements" ADD CONSTRAINT "tech_req_parameter_fk" FOREIGN KEY ("inspection_parameter_code") REFERENCES "public"."inspection_parameters"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_technical_requirements" ADD CONSTRAINT "tech_req_judgment_standard_fk" FOREIGN KEY ("judgment_standard_code") REFERENCES "public"."inspection_standards"("code") ON DELETE restrict ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_technical_requirements" ADD CONSTRAINT "tech_req_brand_fk" FOREIGN KEY ("brand") REFERENCES "public"."inspection_brands"("code") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_technical_requirements" ADD CONSTRAINT "tech_req_model_fk" FOREIGN KEY ("model") REFERENCES "public"."inspection_models"("code") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_technical_requirements" ADD CONSTRAINT "tech_req_grade_fk" FOREIGN KEY ("grade") REFERENCES "public"."inspection_grades"("code") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_technical_requirements" ADD CONSTRAINT "tech_req_spec_fk" FOREIGN KEY ("spec") REFERENCES "public"."inspection_specs"("code") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "sample_receipts" ADD CONSTRAINT "sample_receipts_contract_fk" FOREIGN KEY ("contract_id") REFERENCES "public"."contracts"("id") ON DELETE restrict ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "sample_receipts" ADD CONSTRAINT "receipts_category_fk" FOREIGN KEY ("category_code") REFERENCES "public"."inspection_report_names"("code") ON DELETE restrict ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "samples" ADD CONSTRAINT "samples_receipt_fk" FOREIGN KEY ("receipt_id") REFERENCES "public"."sample_receipts"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "test_records" ADD CONSTRAINT "test_records_sample_fk" FOREIGN KEY ("sample_id") REFERENCES "public"."samples"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "test_records" ADD CONSTRAINT "testrec_param_fk" FOREIGN KEY ("parameter_code") REFERENCES "public"."inspection_parameters"("code") ON DELETE restrict ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "test_records" ADD CONSTRAINT "testrec_standard_fk" FOREIGN KEY ("standard_code") REFERENCES "public"."inspection_standards"("code") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_audit_events_at" ON "audit_events" USING btree ("at");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_audit_events_operator" ON "audit_events" USING btree ("operator");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_audit_events_target" ON "audit_events" USING btree ("target","target_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_audit_events_tenant" ON "audit_events" USING btree ("tenant_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_contracts_tenant" ON "contracts" USING btree ("tenant_id");--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "idx_contracts_tenant_code" ON "contracts" USING btree ("tenant_id","contract_code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_brands_tenant" ON "inspection_brands" USING btree ("tenant_id");--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "idx_brands_tenant_code" ON "inspection_brands" USING btree ("tenant_id","code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_inspection_brands_object" ON "inspection_brands" USING btree ("inspection_object_code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_calc_method_object" ON "inspection_calculation_methods" USING btree ("inspection_object_code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_grades_tenant" ON "inspection_grades" USING btree ("tenant_id");--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "idx_grades_tenant_code" ON "inspection_grades" USING btree ("tenant_id","code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_inspection_grades_object" ON "inspection_grades" USING btree ("inspection_object_code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_models_tenant" ON "inspection_models" USING btree ("tenant_id");--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "idx_models_tenant_code" ON "inspection_models" USING btree ("tenant_id","code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_inspection_models_object" ON "inspection_models" USING btree ("inspection_object_code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_obj_params_object" ON "inspection_object_parameters" USING btree ("inspection_object_code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_obj_params_param" ON "inspection_object_parameters" USING btree ("inspection_parameter_code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_obj_rn_object" ON "inspection_object_report_names" USING btree ("inspection_object_code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_obj_std_object" ON "inspection_object_standards" USING btree ("inspection_object_code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_objects_specialty" ON "inspection_objects" USING btree ("inspection_specialty_code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_pil_param" ON "inspection_param_interface_links" USING btree ("inspection_parameter_code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_rn_param_report" ON "inspection_report_name_parameters" USING btree ("report_name_code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_rn_std_report" ON "inspection_report_name_standards" USING btree ("report_name_code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_specs_tenant" ON "inspection_specs" USING btree ("tenant_id");--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "idx_specs_tenant_code" ON "inspection_specs" USING btree ("tenant_id","code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_inspection_specs_object" ON "inspection_specs" USING btree ("inspection_object_code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_std_param_standard" ON "inspection_standard_parameters" USING btree ("inspection_standard_code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_tech_req_object" ON "inspection_technical_requirements" USING btree ("inspection_object_code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_tech_req_parameter" ON "inspection_technical_requirements" USING btree ("inspection_parameter_code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_tech_req_tenant" ON "inspection_technical_requirements" USING btree ("tenant_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_receipts_tenant" ON "sample_receipts" USING btree ("tenant_id");--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "idx_receipts_tenant_commission" ON "sample_receipts" USING btree ("tenant_id","commission_code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_sample_receipts_category" ON "sample_receipts" USING btree ("category_code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_sample_receipts_contract" ON "sample_receipts" USING btree ("contract_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_sample_receipts_flow_status" ON "sample_receipts" USING btree ("flow_status");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_samples_receipt" ON "samples" USING btree ("receipt_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_samples_tenant" ON "samples" USING btree ("tenant_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_test_records_sample" ON "test_records" USING btree ("sample_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_test_records_tenant" ON "test_records" USING btree ("tenant_id");