CREATE TYPE "public"."frequency" AS ENUM('daily', 'weekly', 'custom');--> statement-breakpoint
CREATE TYPE "public"."product_category" AS ENUM('cleanser', 'toner', 'serum', 'moisturizer', 'sunscreen', 'mask', 'treatment', 'other');--> statement-breakpoint
CREATE TYPE "public"."product_status" AS ENUM('active', 'available', 'paused', 'wishlist');--> statement-breakpoint
CREATE TYPE "public"."time_of_day" AS ENUM('morning', 'evening');--> statement-breakpoint
CREATE TABLE "ingredients" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" varchar(160) NOT NULL,
	"type" varchar(80),
	"is_potentially_irritating" boolean DEFAULT false NOT NULL,
	"benefits" text,
	"incompatible_with" text,
	CONSTRAINT "ingredients_name_unique" UNIQUE("name")
);
--> statement-breakpoint
CREATE TABLE "product_ingredients" (
	"product_id" uuid NOT NULL,
	"ingredient_id" uuid NOT NULL,
	"concentration" numeric(5, 2)
);
--> statement-breakpoint
CREATE TABLE "products" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" varchar(160) NOT NULL,
	"brand" varchar(120) NOT NULL,
	"category" "product_category" NOT NULL,
	"price_cents" integer DEFAULT 0 NOT NULL,
	"volume_ml" numeric(10, 2),
	"status" "product_status" DEFAULT 'available' NOT NULL,
	"opened_at" timestamp with time zone,
	"expires_at" timestamp with time zone,
	"notes" text,
	"rating" integer,
	"created_at" timestamp with time zone DEFAULT now(),
	"updated_at" timestamp with time zone DEFAULT now(),
	"deleted_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "routine_steps" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"routine_id" uuid NOT NULL,
	"order" integer NOT NULL,
	"product_id" uuid,
	"ingredient_id" uuid,
	"notes" text
);
--> statement-breakpoint
CREATE TABLE "routines" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" varchar(120) NOT NULL,
	"time_of_day" time_of_day NOT NULL,
	"frequency" "frequency" DEFAULT 'daily' NOT NULL,
	"skin_concerns" text,
	"created_at" timestamp with time zone DEFAULT now(),
	"updated_at" timestamp with time zone DEFAULT now()
);
--> statement-breakpoint
ALTER TABLE "product_ingredients" ADD CONSTRAINT "product_ingredients_product_id_products_id_fk" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "product_ingredients" ADD CONSTRAINT "product_ingredients_ingredient_id_ingredients_id_fk" FOREIGN KEY ("ingredient_id") REFERENCES "public"."ingredients"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "routine_steps" ADD CONSTRAINT "routine_steps_routine_id_routines_id_fk" FOREIGN KEY ("routine_id") REFERENCES "public"."routines"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "routine_steps" ADD CONSTRAINT "routine_steps_product_id_products_id_fk" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "routine_steps" ADD CONSTRAINT "routine_steps_ingredient_id_ingredients_id_fk" FOREIGN KEY ("ingredient_id") REFERENCES "public"."ingredients"("id") ON DELETE set null ON UPDATE no action;