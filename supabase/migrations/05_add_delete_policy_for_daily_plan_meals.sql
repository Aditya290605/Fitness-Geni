-- Add missing DELETE policy for daily_plan_meals
-- This allows users to delete their own meal entries

CREATE POLICY "Users can delete own daily plan meals"
  ON daily_plan_meals FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM daily_plans
      WHERE daily_plans.id = daily_plan_meals.daily_plan_id
      AND daily_plans.user_id = auth.uid()
    )
  );
