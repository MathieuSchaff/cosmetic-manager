import { pgTable, varchar, text, integer, timestamp, boolean, numeric, pgEnum, uuid } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

export const productCategoryEnum = pgEnum('product_category', [
  'cleanser','toner','serum','moisturizer','sunscreen','mask','treatment','other'
]);

export const productStatusEnum = pgEnum('product_status', [
  'active','available','paused','wishlist'
]);

export const timeOfDayEnum = pgEnum('time_of_day', ['morning','evening']);
export const frequencyEnum = pgEnum('frequency', ['daily','weekly','custom']);

export const products = pgTable('products', {
  id: uuid('id').primaryKey().defaultRandom(),
  name: varchar('name', { length: 160 }).notNull(),
  brand: varchar('brand', { length: 120 }).notNull(),
  category: productCategoryEnum('category').notNull(),
  priceCents: integer('price_cents').notNull().default(0),
  volumeMl: numeric('volume_ml', { precision: 10, scale: 2 }),
  status: productStatusEnum('status').notNull().default('available'),
  openedAt: timestamp('opened_at', { withTimezone: true }),
  expiresAt: timestamp('expires_at', { withTimezone: true }),
  notes: text('notes'),
  rating: integer('rating'), // 1..5
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow(),
  deletedAt: timestamp('deleted_at', { withTimezone: true }),
});

export const ingredients = pgTable('ingredients', {
  id: uuid('id').primaryKey().defaultRandom(),
  name: varchar('name', { length: 160 }).notNull().unique(),
  // type pourrait devenir un enum si une nomenclature stable
  type: varchar('type', { length: 80 }),
  isPotentiallyIrritating: boolean('is_potentially_irritating').notNull().default(false),
  benefits: text('benefits'), // JSON stringifié possible si tu veux
  incompatibleWith: text('incompatible_with'), // idem
});

export const productIngredients = pgTable('product_ingredients', {
  productId: uuid('product_id').notNull().references(() => products.id, { onDelete: 'cascade' }),
  ingredientId: uuid('ingredient_id').notNull().references(() => ingredients.id, { onDelete: 'restrict' }),
  concentration: numeric('concentration', { precision: 5, scale: 2 }), // %
}, (t) => ({
  pk: { primaryKey: [t.productId, t.ingredientId] },
}));

export const routines = pgTable('routines', {
  id: uuid('id').primaryKey().defaultRandom(),
  name: varchar('name', { length: 120 }).notNull(),
  timeOfDay: timeOfDayEnum('time_of_day').notNull(),
  frequency: frequencyEnum('frequency').notNull().default('daily'),
  skinConcerns: text('skin_concerns'), // JSON stringifié
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow(),
});

export const routineSteps = pgTable('routine_steps', {
  id: uuid('id').primaryKey().defaultRandom(),
  routineId: uuid('routine_id').notNull().references(() => routines.id, { onDelete: 'cascade' }),
  order: integer('order').notNull(),
  // un step peut référencer un product OU un ingredient (optionnel selon ton design)
  productId: uuid('product_id').references(() => products.id, { onDelete: 'set null' }),
  ingredientId: uuid('ingredient_id').references(() => ingredients.id, { onDelete: 'set null' }),
  notes: text('notes'),
});
export const productsRelations = relations(products, ({ many }) => ({
  productIngredients: many(productIngredients),
}));

export const ingredientsRelations = relations(ingredients, ({ many }) => ({
  productIngredients: many(productIngredients),
}));

export const routinesRelations = relations(routines, ({ many }) => ({
  steps: many(routineSteps),
}));
