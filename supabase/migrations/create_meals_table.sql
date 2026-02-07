-- Create meals table for storing user meal plans
CREATE TABLE IF NOT EXISTS meals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  time TEXT NOT NULL CHECK (time IN ('Morning', 'Afternoon', 'Night')),
  ingredients TEXT[] NOT NULL,
  recipe_steps TEXT[] NOT NULL,
  is_done BOOLEAN NOT NULL DEFAULT false,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  
  -- Ensure unique meal time per user per day
  UNIQUE(user_id, date, time)
);

-- Create index for faster queries by user and date
CREATE INDEX IF NOT EXISTS idx_meals_user_date ON meals(user_id, date);

-- Enable Row Level Security
ALTER TABLE meals ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own meals
CREATE POLICY "Users can view own meals"
  ON meals FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own meals
CREATE POLICY "Users can insert own meals"
  ON meals FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own meals
CREATE POLICY "Users can update own meals"
  ON meals FOR UPDATE
  USING (auth.uid() = user_id);

-- Policy: Users can delete their own meals
CREATE POLICY "Users can delete own meals"
  ON meals FOR DELETE
  USING (auth.uid() = user_id);
