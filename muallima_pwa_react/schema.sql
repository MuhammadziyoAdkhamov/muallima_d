-- 1. PROFILES (Dilnavoz va Admin)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name TEXT NOT NULL,
  role TEXT CHECK (role IN ('teacher', 'admin')) DEFAULT 'teacher',
  coins_balance INTEGER DEFAULT 0,
  rating_score NUMERIC(3, 2) DEFAULT 5.00,
  rank_title TEXT DEFAULT 'Oliy toifali Muallima',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. EXERCISES (Virtual talabalar daftarlari)
CREATE TABLE IF NOT EXISTS public.exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_name TEXT NOT NULL,
  student_avatar TEXT NOT NULL DEFAULT '🧕',
  topic TEXT NOT NULL,
  difficulty TEXT CHECK (difficulty IN ('oson', 'orta', 'qiyin')) DEFAULT 'orta',
  arabic_raw_text TEXT NOT NULL,
  errors JSONB NOT NULL DEFAULT '[]'::jsonb,
  reward_coins INTEGER DEFAULT 50,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. SUBMISSIONS (Muallima tekshirgan ishlar)
CREATE TABLE IF NOT EXISTS public.submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id UUID REFERENCES public.exercises(id) ON DELETE CASCADE,
  teacher_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  errors_found INTEGER NOT NULL,
  grade TEXT NOT NULL DEFAULT 'A',
  coins_earned INTEGER NOT NULL,
  checked_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. GIFTS (Sovg'alar katalogi)
CREATE TABLE IF NOT EXISTS public.gifts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  cost_coins INTEGER NOT NULL,
  icon_emoji TEXT NOT NULL DEFAULT '🎁',
  description TEXT,
  is_available BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. GIFT ORDERS (Dilnavozning buyurtmalari)
CREATE TABLE IF NOT EXISTS public.gift_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gift_id UUID REFERENCES public.gifts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  coins_spent INTEGER NOT NULL,
  status TEXT CHECK (status IN ('pending', 'delivered')) DEFAULT 'pending',
  ordered_at TIMESTAMPTZ DEFAULT NOW(),
  delivered_at TIMESTAMPTZ
);
