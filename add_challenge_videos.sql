-- Add video_url column to existing challenges table
ALTER TABLE challenges ADD COLUMN IF NOT EXISTS video_url TEXT;

-- Update existing challenges with video URLs
UPDATE challenges SET video_url = 'assets/videos/1.mp4' WHERE title = '30-Day Push-up Challenge';
UPDATE challenges SET video_url = 'assets/videos/4.mp4' WHERE title = 'Summer Shred';
UPDATE challenges SET video_url = 'assets/videos/5.mp4' WHERE title = 'Marathon Training';