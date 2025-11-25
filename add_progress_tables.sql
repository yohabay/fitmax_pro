-- Add progress tracking tables to existing database

-- Workout sessions table (tracks completed workouts)
CREATE TABLE IF NOT EXISTS workout_sessions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id TEXT DEFAULT 'demo_user',
  workout_name TEXT NOT NULL,
  duration INTEGER NOT NULL, -- in minutes
  calories_burned INTEGER NOT NULL,
  exercises JSONB DEFAULT '[]',
  completed_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Personal records table (tracks PRs for exercises)
CREATE TABLE IF NOT EXISTS personal_records (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id TEXT DEFAULT 'demo_user',
  exercise_name TEXT NOT NULL,
  value DOUBLE PRECISION NOT NULL,
  unit TEXT NOT NULL,
  achieved_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, exercise_name)
);

-- Enable RLS
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE personal_records ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own workout sessions" ON workout_sessions FOR SELECT USING (auth.uid()::text = user_id OR user_id = 'demo_user');
CREATE POLICY "Users can insert own workout sessions" ON workout_sessions FOR INSERT WITH CHECK (auth.uid()::text = user_id OR user_id = 'demo_user');

CREATE POLICY "Users can view own personal records" ON personal_records FOR SELECT USING (auth.uid()::text = user_id OR user_id = 'demo_user');
CREATE POLICY "Users can insert own personal records" ON personal_records FOR INSERT WITH CHECK (auth.uid()::text = user_id OR user_id = 'demo_user');
CREATE POLICY "Users can update own personal records" ON personal_records FOR UPDATE USING (auth.uid()::text = user_id OR user_id = 'demo_user');

-- Sample data
INSERT INTO workout_sessions (user_id, workout_name, duration, calories_burned, exercises, completed_at) VALUES
('demo_user', 'Upper Body Strength', 45, 320, '[{"name": "Bench Press", "sets": 3, "reps": 10, "weight": 80}, {"name": "Pull-ups", "sets": 3, "reps": 8, "weight": 0}]', NOW() - INTERVAL '1 day'),
('demo_user', 'Cardio HIIT', 30, 280, '[]', NOW() - INTERVAL '3 days'),
('demo_user', 'Full Body Circuit', 50, 400, '[{"name": "Squats", "sets": 4, "reps": 15, "weight": 0}, {"name": "Push-ups", "sets": 3, "reps": 12, "weight": 0}]', NOW() - INTERVAL '5 days'),
('demo_user', 'Morning Yoga', 25, 150, '[]', NOW() - INTERVAL '7 days');

INSERT INTO personal_records (user_id, exercise_name, value, unit, achieved_at) VALUES
('demo_user', 'Bench Press', 85.0, 'kg', NOW() - INTERVAL '2 days'),
('demo_user', 'Squat', 120.0, 'kg', NOW() - INTERVAL '5 days'),
('demo_user', 'Deadlift', 140.0, 'kg', NOW() - INTERVAL '1 week'),
('demo_user', 'Pull-ups', 12.0, 'reps', NOW() - INTERVAL '3 days'),
('demo_user', '5K Run', 22.5, 'min', NOW() - INTERVAL '1 week');