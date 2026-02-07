-- Create daily_plans table for tracking daily meal plans
CREATE TABLE IF NOT EXISTS daily_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  plan_date DATE NOT NULL DEFAULT CURRENT_DATE,
  consumed_calories INT DEFAULT 0,
  consumed_protein DOUBLE PRECISION DEFAULT 0,
  consumed_carbs DOUBLE PRECISION DEFAULT 0,
  consumed_fats DOUBLE PRECISION DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  
  -- Ensure one plan per user per day
  UNIQUE(user_id, plan_date)
);

-- Create daily_plan_meals junction table
CREATE TABLE IF NOT EXISTS daily_plan_meals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  daily_plan_id UUID NOT NULL REFERENCES daily_plans(id) ON DELETE CASCADE,
  meal_id UUID NOT NULL REFERENCES meals(id) ON DELETE CASCADE,
  meal_time TEXT NOT NULL CHECK (meal_time IN ('morning', 'afternoon', 'night')),
  is_completed BOOLEAN NOT NULL DEFAULT false,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  
  -- Ensure one meal per time per plan
  UNIQUE(daily_plan_id, meal_time)
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_daily_plans_user_date ON daily_plans(user_id, plan_date);
CREATE INDEX IF NOT EXISTS idx_daily_plan_meals_plan ON daily_plan_meals(daily_plan_id);
CREATE INDEX IF NOT EXISTS idx_daily_plan_meals_meal ON daily_plan_meals(meal_id);

-- Enable Row Level Security
ALTER TABLE daily_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_plan_meals ENABLE ROW LEVEL SECURITY;

-- Policies for daily_plans
CREATE POLICY "Users can view own daily plans"
  ON daily_plans FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own daily plans"
  ON daily_plans FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own daily plans"
  ON daily_plans FOR UPDATE
  USING (auth.uid() = user_id);

-- Policies for daily_plan_meals
CREATE POLICY "Users can view own daily plan meals"
  ON daily_plan_meals FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM daily_plans
      WHERE daily_plans.id = daily_plan_meals.daily_plan_id
      AND daily_plans.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own daily plan meals"
  ON daily_plan_meals FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM daily_plans
      WHERE daily_plans.id = daily_plan_meals.daily_plan_id
      AND daily_plans.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own daily plan meals"
  ON daily_plan_meals FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM daily_plans
      WHERE daily_plans.id = daily_plan_meals.daily_plan_id
      AND daily_plans.user_id = auth.uid()
    )
  );
