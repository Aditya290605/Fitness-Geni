-- Migration: Create RPC functions for nutrition tracking
-- Run this FOURTH in Supabase SQL Editor (AFTER the first 3 migrations)

-- Function to increment daily nutrition when marking meal as done
CREATE OR REPLACE FUNCTION increment_daily_nutrition(
  plan_id UUID,
  cal INTEGER,
  prot NUMERIC,
  carb NUMERIC,
  fat NUMERIC
)
RETURNS VOID AS $$
BEGIN
  UPDATE public.daily_plans
  SET
    consumed_calories = COALESCE(consumed_calories, 0) + cal,
    consumed_protein = COALESCE(consumed_protein, 0) + prot,
    consumed_carbs = COALESCE(consumed_carbs, 0) + carb,
    consumed_fats = COALESCE(consumed_fats, 0) + fat
  WHERE id = plan_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to decrement daily nutrition when unmarking meal
CREATE OR REPLACE FUNCTION decrement_daily_nutrition(
  plan_id UUID,
  cal INTEGER,
  prot NUMERIC,
  carb NUMERIC,
  fat NUMERIC
)
RETURNS VOID AS $$
BEGIN
  UPDATE public.daily_plans
  SET
    consumed_calories = GREATEST(COALESCE(consumed_calories, 0) - cal, 0),
    consumed_protein = GREATEST(COALESCE(consumed_protein, 0) - prot, 0),
    consumed_carbs = GREATEST(COALESCE(consumed_carbs, 0) - carb, 0),
    consumed_fats = GREATEST(COALESCE(consumed_fats, 0) - fat, 0)
  WHERE id = plan_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION increment_daily_nutrition TO authenticated;
GRANT EXECUTE ON FUNCTION decrement_daily_nutrition TO authenticated;
