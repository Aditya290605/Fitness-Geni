-- Migration: Add nutrition tracking to daily_plans table
-- Run this third in Supabase SQL Editor

-- Add consumed nutrition tracking columns to daily_plans
ALTER TABLE public.daily_plans
ADD COLUMN IF NOT EXISTS consumed_calories INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS consumed_protein NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS consumed_carbs NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS consumed_fats NUMERIC DEFAULT 0;

-- Add comment for documentation
COMMENT ON COLUMN public.daily_plans.consumed_calories IS 'Total calories consumed today (updated when meals are marked done)';
COMMENT ON COLUMN public.daily_plans.consumed_protein IS 'Total protein in grams consumed today';
COMMENT ON COLUMN public.daily_plans.consumed_carbs IS 'Total carbs in grams consumed today';
COMMENT ON COLUMN public.daily_plans.consumed_fats IS 'Total fats in grams consumed today';
