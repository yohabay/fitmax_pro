-- Fresh Schema Setup - Run this to completely reset the database
-- This will drop ALL existing tables and recreate them from scratch

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop ALL existing tables in correct order (reverse dependencies)
DROP TABLE IF EXISTS blocks CASCADE;
DROP TABLE IF EXISTS reports CASCADE;
DROP TABLE IF EXISTS chat_messages CASCADE;
DROP TABLE IF EXISTS follows CASCADE;
DROP TABLE IF EXISTS user_settings CASCADE;
DROP TABLE IF EXISTS challenges CASCADE;
DROP TABLE IF EXISTS friends CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS post_likes CASCADE;
DROP TABLE IF EXISTS posts CASCADE;
DROP TABLE IF EXISTS progress_entries CASCADE;
DROP TABLE IF EXISTS meals CASCADE;
DROP TABLE IF EXISTS user_favorites CASCADE;
DROP TABLE IF EXISTS workouts CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- Recreate all tables

-- Profiles table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  avatar TEXT,
  bio TEXT,
  level INTEGER DEFAULT 1,
  xp INTEGER DEFAULT 0,
  streak INTEGER DEFAULT 0,
  badges TEXT[] DEFAULT '{}',
  join_date TIMESTAMPTZ DEFAULT NOW(),
  fitness_goal TEXT DEFAULT '',
  fitness_level TEXT DEFAULT '',
  age INTEGER DEFAULT 25,
  height DOUBLE PRECISION DEFAULT 170.0,
  weight DOUBLE PRECISION DEFAULT 70.0,
  gender TEXT DEFAULT '',
  preferred_activities TEXT[] DEFAULT '{}',
  workout_days INTEGER DEFAULT 3,
  workout_duration INTEGER DEFAULT 30,
  achievements TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Workouts table
CREATE TABLE workouts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  duration TEXT NOT NULL,
  difficulty TEXT NOT NULL,
  calories INTEGER NOT NULL,
  category TEXT NOT NULL,
  image_url TEXT NOT NULL,
  video_url TEXT,
  rating DOUBLE PRECISION NOT NULL,
  completions INTEGER DEFAULT 0,
  trainer TEXT NOT NULL,
  is_premium BOOLEAN DEFAULT FALSE,
  is_featured BOOLEAN DEFAULT FALSE,
  exercises JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User favorites
CREATE TABLE user_favorites (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id TEXT DEFAULT 'demo_user',
  workout_id UUID REFERENCES workouts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, workout_id)
);

-- Meals table
CREATE TABLE meals (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id TEXT DEFAULT 'demo_user',
  meal_type TEXT NOT NULL,
  food_name TEXT NOT NULL,
  calories INTEGER NOT NULL,
  time TEXT NOT NULL,
  image_url TEXT,
  macros JSONB NOT NULL,
  date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Progress entries
CREATE TABLE progress_entries (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id TEXT DEFAULT 'demo_user',
  type TEXT NOT NULL,
  value DOUBLE PRECISION NOT NULL,
  unit TEXT NOT NULL,
  date DATE DEFAULT CURRENT_DATE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Posts table
CREATE TABLE posts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id TEXT DEFAULT 'demo_user',
  content TEXT NOT NULL,
  image_url TEXT,
  likes INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Post likes table
CREATE TABLE post_likes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id TEXT DEFAULT 'demo_user',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

-- Comments table
CREATE TABLE comments (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id TEXT DEFAULT 'demo_user',
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Friends table
CREATE TABLE friends (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id TEXT DEFAULT 'demo_user',
  friend_id TEXT NOT NULL,
  friend_name TEXT NOT NULL,
  friend_avatar TEXT,
  friend_level INTEGER DEFAULT 1,
  friend_streak INTEGER DEFAULT 0,
  status TEXT DEFAULT 'accepted',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Challenges table
CREATE TABLE challenges (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT,
  video_url TEXT,
  start_date DATE DEFAULT CURRENT_DATE,
  end_date DATE,
  participants INTEGER DEFAULT 0,
  category TEXT DEFAULT 'general',
  rules JSONB DEFAULT '{}',
  rewards JSONB DEFAULT '[]',
  days_left INTEGER DEFAULT 30,
  progress DOUBLE PRECISION DEFAULT 0.0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User settings table
CREATE TABLE user_settings (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE UNIQUE,
  theme_mode TEXT DEFAULT 'system',
  notifications_enabled BOOLEAN DEFAULT true,
  workout_reminders BOOLEAN DEFAULT true,
  meal_reminders BOOLEAN DEFAULT true,
  social_notifications BOOLEAN DEFAULT true,
  language TEXT DEFAULT 'English',
  units TEXT DEFAULT 'Metric',
  auto_backup BOOLEAN DEFAULT true,
  biometric_auth BOOLEAN DEFAULT false,
  workout_reminder_time TEXT DEFAULT '09:00',
  meal_reminder_time TEXT DEFAULT '12:00',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Follows table (using usernames for demo)
CREATE TABLE follows (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  follower_id TEXT DEFAULT 'demo_user',
  following_id TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(follower_id, following_id)
);

-- Chat messages table
CREATE TABLE chat_messages (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  sender_id TEXT DEFAULT 'demo_user',
  receiver_id TEXT NOT NULL,
  content TEXT NOT NULL,
  message_type TEXT DEFAULT 'text',
  media_url TEXT,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reports table
CREATE TABLE reports (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  reporter_id TEXT DEFAULT 'demo_user',
  reported_user_id TEXT,
  reported_post_id UUID,
  report_type TEXT NOT NULL,
  reason TEXT NOT NULL,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Blocks table
CREATE TABLE blocks (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  blocker_id TEXT DEFAULT 'demo_user',
  blocked_id TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(blocker_id, blocked_id)
);

-- User challenges table (tracks which users joined which challenges)
-- Note: This table may already exist, so using CREATE TABLE IF NOT EXISTS
CREATE TABLE IF NOT EXISTS user_challenges (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id TEXT DEFAULT 'demo_user',
  challenge_id UUID REFERENCES challenges(id) ON DELETE CASCADE,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  progress DOUBLE PRECISION DEFAULT 0.0,
  UNIQUE(user_id, challenge_id)
);

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

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE meals ENABLE ROW LEVEL SECURITY;
ALTER TABLE progress_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE friends ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocks ENABLE ROW LEVEL SECURITY;
-- Enable RLS (skip if already enabled)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relname = 'user_challenges'
        AND n.nspname = 'public'
        AND c.relrowsecurity = true
    ) THEN
        ALTER TABLE user_challenges ENABLE ROW LEVEL SECURITY;
    END IF;
END $$;
-- Enable RLS for new tables (skip if already enabled)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relname = 'workout_sessions'
        AND n.nspname = 'public'
        AND c.relrowsecurity = true
    ) THEN
        ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relname = 'personal_records'
        AND n.nspname = 'public'
        AND c.relrowsecurity = true
    ) THEN
        ALTER TABLE personal_records ENABLE ROW LEVEL SECURITY;
    END IF;
END $$;

-- RLS Policies
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Anyone can view workouts" ON workouts FOR SELECT USING (true);

CREATE POLICY "Users can view own favorites" ON user_favorites FOR SELECT USING (auth.uid()::text = user_id OR user_id = 'demo_user');
CREATE POLICY "Users can insert own favorites" ON user_favorites FOR INSERT WITH CHECK (auth.uid()::text = user_id OR user_id = 'demo_user');
CREATE POLICY "Users can delete own favorites" ON user_favorites FOR DELETE USING (auth.uid()::text = user_id OR user_id = 'demo_user');

CREATE POLICY "Users can view own meals" ON meals FOR SELECT USING (auth.uid()::text = user_id OR user_id = 'demo_user');
CREATE POLICY "Users can insert own meals" ON meals FOR INSERT WITH CHECK (auth.uid()::text = user_id OR user_id = 'demo_user');
CREATE POLICY "Users can update own meals" ON meals FOR UPDATE USING (auth.uid()::text = user_id OR user_id = 'demo_user');
CREATE POLICY "Users can delete own meals" ON meals FOR DELETE USING (auth.uid()::text = user_id OR user_id = 'demo_user');

CREATE POLICY "Users can view own progress" ON progress_entries FOR SELECT USING (auth.uid()::text = user_id OR user_id = 'demo_user');
CREATE POLICY "Users can insert own progress" ON progress_entries FOR INSERT WITH CHECK (auth.uid()::text = user_id OR user_id = 'demo_user');

CREATE POLICY "Anyone can view posts" ON posts FOR SELECT USING (true);
CREATE POLICY "Users can insert own posts" ON posts FOR INSERT WITH CHECK (auth.uid()::text = user_id OR user_id = 'demo_user');
CREATE POLICY "Users can update own posts" ON posts FOR UPDATE USING (auth.uid()::text = user_id OR user_id = 'demo_user');
CREATE POLICY "Users can delete own posts" ON posts FOR DELETE USING (auth.uid()::text = user_id OR user_id = 'demo_user');

CREATE POLICY "Users can view post likes" ON post_likes FOR SELECT USING (auth.uid()::text = user_id OR user_id = 'demo_user');
CREATE POLICY "Users can insert own likes" ON post_likes FOR INSERT WITH CHECK (auth.uid()::text = user_id OR user_id = 'demo_user');
CREATE POLICY "Users can delete own likes" ON post_likes FOR DELETE USING (auth.uid()::text = user_id OR user_id = 'demo_user');

CREATE POLICY "Anyone can view comments" ON comments FOR SELECT USING (true);
CREATE POLICY "Users can insert own comments" ON comments FOR INSERT WITH CHECK (auth.uid()::text = user_id OR user_id = 'demo_user');
CREATE POLICY "Users can update own comments" ON comments FOR UPDATE USING (auth.uid()::text = user_id OR user_id = 'demo_user');
CREATE POLICY "Users can delete own comments" ON comments FOR DELETE USING (auth.uid()::text = user_id OR user_id = 'demo_user');

CREATE POLICY "Users can view own friends" ON friends FOR SELECT USING (auth.uid()::text = user_id OR user_id = 'demo_user');
CREATE POLICY "Users can manage own friends" ON friends FOR ALL USING (auth.uid()::text = user_id OR user_id = 'demo_user');

CREATE POLICY "Anyone can view challenges" ON challenges FOR SELECT USING (true);
CREATE POLICY "Users can join challenges" ON challenges FOR UPDATE USING (true);

CREATE POLICY "Users can view own settings" ON user_settings FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own settings" ON user_settings FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own settings" ON user_settings FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own follows" ON follows FOR SELECT USING (auth.uid()::text = follower_id OR follower_id = 'demo_user');
CREATE POLICY "Users can follow others" ON follows FOR INSERT WITH CHECK (auth.uid()::text = follower_id OR follower_id = 'demo_user');
CREATE POLICY "Users can unfollow" ON follows FOR DELETE USING (auth.uid()::text = follower_id OR follower_id = 'demo_user');

CREATE POLICY "Users can view their chat messages" ON chat_messages FOR SELECT USING (
  auth.uid()::text = sender_id OR auth.uid()::text = receiver_id OR
  sender_id = 'demo_user' OR receiver_id = 'demo_user'
);
CREATE POLICY "Users can send messages" ON chat_messages FOR INSERT WITH CHECK (
  auth.uid()::text = sender_id OR sender_id = 'demo_user'
);

CREATE POLICY "Users can view own reports" ON reports FOR SELECT USING (auth.uid()::text = reporter_id OR reporter_id = 'demo_user');
CREATE POLICY "Users can create reports" ON reports FOR INSERT WITH CHECK (auth.uid()::text = reporter_id OR reporter_id = 'demo_user');

CREATE POLICY "Users can view own blocks" ON blocks FOR SELECT USING (auth.uid()::text = blocker_id OR blocker_id = 'demo_user');
CREATE POLICY "Users can block others" ON blocks FOR INSERT WITH CHECK (auth.uid()::text = blocker_id OR blocker_id = 'demo_user');
CREATE POLICY "Users can unblock" ON blocks FOR DELETE USING (auth.uid()::text = blocker_id OR blocker_id = 'demo_user');

-- Create policies (skip if they already exist)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'user_challenges' AND policyname = 'Users can view own challenge participations') THEN
        CREATE POLICY "Users can view own challenge participations" ON user_challenges FOR SELECT USING (auth.uid()::text = user_id OR user_id = 'demo_user');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'user_challenges' AND policyname = 'Users can join challenges') THEN
        CREATE POLICY "Users can join challenges" ON user_challenges FOR INSERT WITH CHECK (auth.uid()::text = user_id OR user_id = 'demo_user');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'user_challenges' AND policyname = 'Users can leave challenges') THEN
        CREATE POLICY "Users can leave challenges" ON user_challenges FOR DELETE USING (auth.uid()::text = user_id OR user_id = 'demo_user');
    END IF;
END $$;

-- Create policies for new tables (skip if they already exist)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'workout_sessions' AND policyname = 'Users can view own workout sessions') THEN
        CREATE POLICY "Users can view own workout sessions" ON workout_sessions FOR SELECT USING (auth.uid()::text = user_id OR user_id = 'demo_user');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'workout_sessions' AND policyname = 'Users can insert own workout sessions') THEN
        CREATE POLICY "Users can insert own workout sessions" ON workout_sessions FOR INSERT WITH CHECK (auth.uid()::text = user_id OR user_id = 'demo_user');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'personal_records' AND policyname = 'Users can view own personal records') THEN
        CREATE POLICY "Users can view own personal records" ON personal_records FOR SELECT USING (auth.uid()::text = user_id OR user_id = 'demo_user');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'personal_records' AND policyname = 'Users can insert own personal records') THEN
        CREATE POLICY "Users can insert own personal records" ON personal_records FOR INSERT WITH CHECK (auth.uid()::text = user_id OR user_id = 'demo_user');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'personal_records' AND policyname = 'Users can update own personal records') THEN
        CREATE POLICY "Users can update own personal records" ON personal_records FOR UPDATE USING (auth.uid()::text = user_id OR user_id = 'demo_user');
    END IF;
END $$;

-- Function to handle user profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, name, email)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'name', 'User'), NEW.email);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Trigger to create profile on signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Sample data for workouts
INSERT INTO workouts (title, description, duration, difficulty, calories, category, image_url, video_url, rating, completions, trainer, is_featured, exercises) VALUES
('Full Body Strength', 'Complete full body workout targeting all major muscle groups', '45 min', 'Intermediate', 320, 'strength', 'assets/images/gym-strength-training.png', 'https://player.vimeo.com/external/370199573.sd.mp4?s=e90dcaba73c19e0e36f03406b47bbd6d4c3b99f6&profile_id=165', 4.8, 1234, 'Mike Johnson', true, '[{"name": "Squats", "sets": 3, "reps": 12, "weight": "135 lbs"}, {"name": "Deadlifts", "sets": 3, "reps": 8, "weight": "185 lbs"}, {"name": "Bench Press", "sets": 3, "reps": 10, "weight": "155 lbs"}, {"name": "Pull-ups", "sets": 3, "reps": 8}]'),
('HIIT Cardio Blast', 'High-intensity interval training for maximum calorie burn', '30 min', 'Advanced', 280, 'cardio', 'assets/images/cardio-hiit-workout.png', 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4', 4.9, 2156, 'Sarah Chen', true, '[{"name": "Burpees", "sets": 4, "reps": 15}, {"name": "Mountain Climbers", "sets": 4, "reps": 20}, {"name": "Jump Squats", "sets": 4, "reps": 15}, {"name": "High Knees", "sets": 4, "reps": 30}]'),
('Morning Yoga Flow', 'Gentle yoga sequence to start your day with mindfulness', '25 min', 'Beginner', 150, 'flexibility', 'assets/images/yoga-morning-flow.png', 'https://sample-videos.com/zip/10/mp4/SampleVideo_640x360_1mb.mp4', 4.7, 892, 'Emma Wilson', false, '[]'),
('Bodyweight Circuit', 'No equipment needed - use your body weight for resistance', '35 min', 'Intermediate', 240, 'bodyweight', 'assets/images/bodyweight-circuit.png', 'https://sample-videos.com/zip/10/mp4/SampleVideo_640x360_2mb.mp4', 4.6, 567, 'Alex Rodriguez', true, '[]'),
('Upper Body Power', 'Build strength in your chest, shoulders, and arms', '40 min', 'Intermediate', 290, 'strength', 'assets/images/gym-strength-training.png', 'assets/videos/1.mp4', 4.5, 756, 'Chris Davis', false, '[{"name": "Push-ups", "sets": 3, "reps": 15}, {"name": "Shoulder Press", "sets": 3, "reps": 12}, {"name": "Bicep Curls", "sets": 3, "reps": 10}]'),
('Core Crusher', 'Intense abdominal workout for six-pack abs', '20 min', 'Advanced', 180, 'strength', 'assets/images/fitness-man.png', 'assets/videos/4.mp4', 4.7, 892, 'Lisa Wong', false, '[{"name": "Planks", "sets": 3, "reps": 1, "duration": "60 sec"}, {"name": "Russian Twists", "sets": 3, "reps": 20}, {"name": "Leg Raises", "sets": 3, "reps": 15}]'),
('Flexibility Flow', 'Improve your range of motion and reduce injury risk', '30 min', 'Beginner', 120, 'flexibility', 'assets/images/yoga-morning-flow.png', 'assets/videos/5.mp4', 4.4, 445, 'Yoga Master', false, '[{"name": "Forward Bend", "sets": 3, "duration": "30 sec"}, {"name": "Warrior Pose", "sets": 3, "duration": "45 sec"}, {"name": "Child Pose", "sets": 3, "duration": "60 sec"}]'),
('Cardio Endurance', 'Build your cardiovascular fitness and stamina', '50 min', 'Intermediate', 350, 'cardio', 'assets/images/cardio-hiit-workout.png', 'assets/videos/20112-307163913_small.mp4', 4.6, 678, 'Running Coach', false, '[{"name": "Jogging", "sets": 1, "duration": "45 min"}, {"name": "Sprint Intervals", "sets": 5, "duration": "30 sec"}]'),
('Lower Body Blast', 'Target your legs and glutes for maximum strength', '45 min', 'Advanced', 320, 'strength', 'assets/images/deadlift-gym.png', 'assets/videos/30415-381526044_small.mp4', 4.8, 934, 'Strength Trainer', false, '[{"name": "Squats", "sets": 4, "reps": 10}, {"name": "Lunges", "sets": 3, "reps": 12}, {"name": "Calf Raises", "sets": 3, "reps": 15}]'),
('Meditation & Breathing', 'Find peace and improve mental clarity', '15 min', 'Beginner', 80, 'flexibility', 'assets/images/yoga-morning-flow.png', 'assets/videos/77916-563974349_small.mp4', 4.3, 234, 'Mindfulness Guide', false, '[{"name": "Deep Breathing", "sets": 1, "duration": "10 min"}, {"name": "Body Scan", "sets": 1, "duration": "5 min"}]'),
('HIIT Express', 'Quick and intense workout for busy schedules', '25 min', 'Advanced', 250, 'cardio', 'assets/images/cardio-hiit-workout.png', 'assets/videos/143431-782373969_small.mp4', 4.9, 1123, 'HIIT Expert', true, '[{"name": "High Knees", "sets": 4, "duration": "30 sec"}, {"name": "Burpees", "sets": 4, "reps": 10}, {"name": "Jump Rope", "sets": 4, "duration": "45 sec"}]'),
('Pilates Core', 'Strengthen your core with controlled movements', '35 min', 'Intermediate', 200, 'flexibility', 'assets/images/yoga-morning-flow.png', 'assets/videos/148208-793717949_small.mp4', 4.5, 567, 'Pilates Instructor', false, '[{"name": "Hundred", "sets": 1, "duration": "100 counts"}, {"name": "Roll Up", "sets": 3, "reps": 5}, {"name": "Single Leg Stretch", "sets": 3, "reps": 8}]');

-- Sample posts with images
INSERT INTO posts (user_id, content, likes, image_url) VALUES
('00000000-0000-0000-0000-000000000000', 'Just completed my first 5K run! Feeling amazing! 🏃‍♂️', 15, 'assets/images/morning-run-sunrise.png'),
('00000000-0000-0000-0000-000000000000', 'New PR on deadlifts today! 200lbs! 💪', 23, 'assets/images/deadlift-gym.png'),
('00000000-0000-0000-0000-000000000000', 'Healthy meal prep for the week! Who else meal preps? 🍎', 8, 'assets/images/placeholder.jpg'),
('00000000-0000-0000-0000-000000000000', 'Morning yoga session done! Starting the day with mindfulness 🧘‍♀️', 12, 'assets/images/yoga-morning-flow.png'),
('00000000-0000-0000-0000-000000000000', 'Post-workout protein shake! Fueling up for recovery 🥤', 9, 'assets/images/fitness-motivation.png'),
('00000000-0000-0000-0000-000000000000', 'Gym progress over 3 months! From beginner to intermediate 💪📈', 27, 'assets/images/gym-strength-training.png');

-- Sample meals for demo
INSERT INTO meals (user_id, meal_type, food_name, calories, time, macros, date) VALUES
('00000000-0000-0000-0000-000000000000', 'Breakfast', 'Oatmeal with berries & honey', 320, '8:00 AM', '{"protein": 12, "carbs": 58, "fat": 6}', CURRENT_DATE),
('00000000-0000-0000-0000-000000000000', 'Lunch', 'Grilled chicken salad', 450, '12:30 PM', '{"protein": 35, "carbs": 15, "fat": 28}', CURRENT_DATE),
('00000000-0000-0000-0000-000000000000', 'Snack', 'Greek yogurt with nuts', 180, '3:00 PM', '{"protein": 15, "carbs": 12, "fat": 8}', CURRENT_DATE);

-- Sample progress entries (weight tracking)
INSERT INTO progress_entries (user_id, type, value, unit, date, notes) VALUES
('00000000-0000-0000-0000-000000000000', 'weight', 75.0, 'kg', CURRENT_DATE - INTERVAL '30 days', 'Starting weight'),
('00000000-0000-0000-0000-000000000000', 'weight', 74.5, 'kg', CURRENT_DATE - INTERVAL '23 days', 'Weekly check'),
('00000000-0000-0000-0000-000000000000', 'weight', 74.0, 'kg', CURRENT_DATE - INTERVAL '16 days', 'Progress'),
('00000000-0000-0000-0000-000000000000', 'weight', 73.8, 'kg', CURRENT_DATE - INTERVAL '9 days', 'Good progress'),
('00000000-0000-0000-0000-000000000000', 'weight', 73.5, 'kg', CURRENT_DATE - INTERVAL '2 days', 'Almost there'),
('00000000-0000-0000-0000-000000000000', 'weight', 73.2, 'kg', CURRENT_DATE, 'Current weight');

-- Sample body measurements
INSERT INTO progress_entries (user_id, type, value, unit, date, notes) VALUES
('00000000-0000-0000-0000-000000000000', 'chest', 95.0, 'cm', CURRENT_DATE - INTERVAL '7 days', 'Chest measurement'),
('00000000-0000-0000-0000-000000000000', 'waist', 82.0, 'cm', CURRENT_DATE - INTERVAL '7 days', 'Waist measurement'),
('00000000-0000-0000-0000-000000000000', 'hips', 98.0, 'cm', CURRENT_DATE - INTERVAL '7 days', 'Hips measurement'),
('00000000-0000-0000-0000-000000000000', 'biceps', 35.0, 'cm', CURRENT_DATE - INTERVAL '7 days', 'Biceps measurement'),
('00000000-0000-0000-0000-000000000000', 'thighs', 58.0, 'cm', CURRENT_DATE - INTERVAL '7 days', 'Thighs measurement'),
('00000000-0000-0000-0000-000000000000', 'chest', 96.0, 'cm', CURRENT_DATE, 'Updated chest'),
('00000000-0000-0000-0000-000000000000', 'waist', 81.0, 'cm', CURRENT_DATE, 'Updated waist'),
('00000000-0000-0000-0000-000000000000', 'hips', 97.5, 'cm', CURRENT_DATE, 'Updated hips'),
('00000000-0000-0000-0000-000000000000', 'biceps', 35.5, 'cm', CURRENT_DATE, 'Updated biceps'),
('00000000-0000-0000-0000-000000000000', 'thighs', 58.5, 'cm', CURRENT_DATE, 'Updated thighs');

-- Sample user favorites (workout favorites)
INSERT INTO user_favorites (user_id, workout_id) VALUES
('00000000-0000-0000-0000-000000000000', (SELECT id FROM workouts WHERE title = 'Full Body Strength' LIMIT 1)),
('00000000-0000-0000-0000-000000000000', (SELECT id FROM workouts WHERE title = 'Morning Yoga Flow' LIMIT 1));

-- Sample friends
INSERT INTO friends (user_id, friend_id, friend_name, friend_avatar, friend_level, friend_streak) VALUES
('00000000-0000-0000-0000-000000000000', 'friend1', 'Emma Wilson', 'assets/images/fitness-woman.png', 12, 15),
('00000000-0000-0000-0000-000000000000', 'friend2', 'Alex Rodriguez', 'assets/images/fitness-man.png', 8, 7),
('00000000-0000-0000-0000-000000000000', 'friend3', 'Sarah Johnson', 'assets/images/fitness-woman-2.png', 15, 22);

-- Sample challenges
INSERT INTO challenges (title, description, video_url, participants, days_left, progress, rules, rewards) VALUES
('30-Day Push-up Challenge', 'Complete 1000 push-ups in 30 days', 'assets/videos/1.mp4', 156, 12, 0.65, '{"daily_goal": 33, "total_goal": 1000}', '["Champion Badge", "1000 Push-ups T-Shirt"]'),
('Summer Shred', 'Lose 10 pounds in 8 weeks', 'assets/videos/4.mp4', 89, 25, 0.3, '{"weekly_goal": 1.25, "total_goal": 10}', '["Shred Master Badge", "Protein Shaker"]'),
('Marathon Training', 'Run 26.2 miles in 12 weeks', 'assets/videos/5.mp4', 234, 45, 0.1, '{"weekly_mileage": 25, "long_run": 16}', '["Marathon Finisher Medal", "Running Shoes"]');

-- Sample workout sessions (only insert if not exists)
INSERT INTO workout_sessions (user_id, workout_name, duration, calories_burned, exercises, completed_at)
SELECT 'demo_user', 'Upper Body Strength', 45, 320, '[{"name": "Bench Press", "sets": 3, "reps": 10, "weight": 80}, {"name": "Pull-ups", "sets": 3, "reps": 8, "weight": 0}]'::jsonb, NOW() - INTERVAL '1 day'
WHERE NOT EXISTS (SELECT 1 FROM workout_sessions WHERE user_id = 'demo_user' AND workout_name = 'Upper Body Strength');

INSERT INTO workout_sessions (user_id, workout_name, duration, calories_burned, exercises, completed_at)
SELECT 'demo_user', 'Cardio HIIT', 30, 280, '[]'::jsonb, NOW() - INTERVAL '3 days'
WHERE NOT EXISTS (SELECT 1 FROM workout_sessions WHERE user_id = 'demo_user' AND workout_name = 'Cardio HIIT');

INSERT INTO workout_sessions (user_id, workout_name, duration, calories_burned, exercises, completed_at)
SELECT 'demo_user', 'Full Body Circuit', 50, 400, '[{"name": "Squats", "sets": 4, "reps": 15, "weight": 0}, {"name": "Push-ups", "sets": 3, "reps": 12, "weight": 0}]'::jsonb, NOW() - INTERVAL '5 days'
WHERE NOT EXISTS (SELECT 1 FROM workout_sessions WHERE user_id = 'demo_user' AND workout_name = 'Full Body Circuit');

INSERT INTO workout_sessions (user_id, workout_name, duration, calories_burned, exercises, completed_at)
SELECT 'demo_user', 'Morning Yoga', 25, 150, '[]'::jsonb, NOW() - INTERVAL '7 days'
WHERE NOT EXISTS (SELECT 1 FROM workout_sessions WHERE user_id = 'demo_user' AND workout_name = 'Morning Yoga');

-- Sample personal records (only insert if not exists)
INSERT INTO personal_records (user_id, exercise_name, value, unit, achieved_at)
SELECT 'demo_user', 'Bench Press', 85.0, 'kg', NOW() - INTERVAL '2 days'
WHERE NOT EXISTS (SELECT 1 FROM personal_records WHERE user_id = 'demo_user' AND exercise_name = 'Bench Press');

INSERT INTO personal_records (user_id, exercise_name, value, unit, achieved_at)
SELECT 'demo_user', 'Squat', 120.0, 'kg', NOW() - INTERVAL '5 days'
WHERE NOT EXISTS (SELECT 1 FROM personal_records WHERE user_id = 'demo_user' AND exercise_name = 'Squat');

INSERT INTO personal_records (user_id, exercise_name, value, unit, achieved_at)
SELECT 'demo_user', 'Deadlift', 140.0, 'kg', NOW() - INTERVAL '1 week'
WHERE NOT EXISTS (SELECT 1 FROM personal_records WHERE user_id = 'demo_user' AND exercise_name = 'Deadlift');

INSERT INTO personal_records (user_id, exercise_name, value, unit, achieved_at)
SELECT 'demo_user', 'Pull-ups', 12.0, 'reps', NOW() - INTERVAL '3 days'
WHERE NOT EXISTS (SELECT 1 FROM personal_records WHERE user_id = 'demo_user' AND exercise_name = 'Pull-ups');

INSERT INTO personal_records (user_id, exercise_name, value, unit, achieved_at)
SELECT 'demo_user', '5K Run', 22.5, 'min', NOW() - INTERVAL '1 week'
WHERE NOT EXISTS (SELECT 1 FROM personal_records WHERE user_id = 'demo_user' AND exercise_name = '5K Run');