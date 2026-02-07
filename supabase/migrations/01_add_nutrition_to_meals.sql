-- Migration: Add nutrition columns to meals table
-- Run this first in Supabase SQL Editor

-- Add nutrition columns to meals table
ALTER TABLE public.meals 
ADD COLUMN IF NOT EXISTS calories INTEGER,
ADD COLUMN IF NOT EXISTS protein NUMERIC,
ADD COLUMN IF NOT EXISTS carbs NUMERIC,
ADD COLUMN IF NOT EXISTS fats NUMERIC;

-- Add comment for documentation
COMMENT ON COLUMN public.meals.calories IS 'Calories provided by this meal';
COMMENT ON COLUMN public.meals.protein IS 'Protein in grams provided by this meal';
COMMENT ON COLUMN public.meals.carbs IS 'Carbohydrates in grams provided by this meal';
COMMENT ON COLUMN public.meals.fats IS 'Fats in grams provided by this meal';
