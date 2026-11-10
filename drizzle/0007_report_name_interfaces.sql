CREATE TABLE IF NOT EXISTS "inspection_report_name_interface_links" (
	"report_name_code" text NOT NULL,
	"report_name_interface_code" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "report_name_interface_links_pkey" PRIMARY KEY("report_name_code","report_name_interface_code")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "inspection_report_name_interfaces" (
	"code" text NOT NULL,
	"name" text,
	"description" text,
	"version" integer DEFAULT 1 NOT NULL,
	"config" jsonb,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "report_name_interfaces_pkey" PRIMARY KEY("code")
);
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_report_name_interface_links" ADD CONSTRAINT "rnil_report_fk" FOREIGN KEY ("report_name_code") REFERENCES "public"."inspection_report_names"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "inspection_report_name_interface_links" ADD CONSTRAINT "rnil_interface_fk" FOREIGN KEY ("report_name_interface_code") REFERENCES "public"."inspection_report_name_interfaces"("code") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_rnil_report" ON "inspection_report_name_interface_links" USING btree ("report_name_code");--> statement-breakpoint
ALTER TABLE "inspection_report_names" DROP COLUMN IF EXISTS "ext_fields";