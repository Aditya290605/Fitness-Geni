-- Fix existing daily_plans and daily_plan_meals tables
-- This assumes the tables already exist but need to be updated

-- First, check if plan_date column exists, if not, it might be named 'date'
-- Add missing columns to daily_plans if they don't exist
DO $$ 
BEGIN
  -- Add consumed_calories if missing
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'daily_plans' AND column_name = 'consumed_calories'
  ) THEN
    ALTER TABLE daily_plans ADD COLUMN consumed_calories INT DEFAULT 0;
  END IF;

  -- Add consumed_protein if missing
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'daily_plans' AND column_name = 'consumed_protein'
  ) THEN
    ALTER TABLE daily_plans ADD COLUMN consumed_protein DOUBLE PRECISION DEFAULT 0;
  END IF;

  -- Add consumed_carbs if missing
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'daily_plans' AND column_name = 'consumed_carbs'
  ) THEN
    ALTER TABLE daily_plans ADD COLUMN consumed_carbs DOUBLE PRECISION DEFAULT 0;
  END IF;

  -- Add consumed_fats if missing
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'daily_plans' AND column_name = 'consumed_fats'
  ) THEN
    ALTER TABLE daily_plans ADD COLUMN consumed_fats DOUBLE PRECISION DEFAULT 0;
  END IF;
END $$;

-- Ensure daily_plan_meals has UUID id with proper default
DO $$
BEGIN
  -- Check if id column has proper UUID generation
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'daily_plan_meals' 
    AND column_name = 'id' 
    AND column_default LIKE '%gen_random_uuid%'
  ) THEN
    -- Drop existing default and add proper UUID generation
    ALTER TABLE daily_plan_meals ALTER COLUMN id SET DEFAULT gen_random_uuid();
  END IF;
END $$;

-- Make sure daily_plans has proper UUID generation too
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'daily_plans' 
    AND column_name = 'id' 
    AND column_default LIKE '%gen_random_uuid%'
  ) THEN
    ALTER TABLE daily_plans ALTER COLUMN id SET DEFAULT gen_random_uuid();
  END IF;
END $$;

COMMENT ON TABLE daily_plans IS 'Stores daily meal plans for users';
COMMENT ON TABLE daily_plan_meals IS 'Junction table linking daily plans to meals';
