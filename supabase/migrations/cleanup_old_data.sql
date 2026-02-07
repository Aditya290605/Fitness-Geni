-- Clean up any daily_plan_meals with invalid IDs
-- Run this to remove old test data before testing the fix

-- Delete all daily_plan_meals (they will be regenerated when you create meals again)
DELETE FROM daily_plan_meals;

-- Optionally, also clear daily_plans if you want a fresh start
DELETE FROM daily_plans;

-- Verify the tables are empty
SELECT COUNT(*) as daily_plans_count FROM daily_plans;
SELECT COUNT(*) as daily_plan_meals_count FROM daily_plan_meals;
