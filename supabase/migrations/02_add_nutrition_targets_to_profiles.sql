-- Migration: Add daily nutrition targets to profiles table
-- Run this second in Supabase SQL Editor

-- Add daily nutrition target columns to profiles
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS daily_calories INTEGER,
ADD COLUMN IF NOT EXISTS daily_protein NUMERIC,
ADD COLUMN IF NOT EXISTS daily_carbs NUMERIC,
ADD COLUMN IF NOT EXISTS daily_fats NUMERIC;

-- Add comment for documentation
COMMENT ON COLUMN public.profiles.daily_calories IS 'Daily calorie target for this user';
COMMENT ON COLUMN public.profiles.daily_protein IS 'Daily protein target in grams for this user';
COMMENT ON COLUMN public.profiles.daily_carbs IS 'Daily carbohydrates target in grams for this user';
COMMENT ON COLUMN public.profiles.daily_fats IS 'Daily fats target in grams for this user';
