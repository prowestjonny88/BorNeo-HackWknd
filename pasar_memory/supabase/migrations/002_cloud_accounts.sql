CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL,
  business_name TEXT NOT NULL,
  business_type TEXT NOT NULL,
  preferred_language TEXT NOT NULL DEFAULT 'English',
  email TEXT NOT NULL,
  phone TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE menu_items
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE daily_summaries
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

CREATE INDEX IF NOT EXISTS menu_items_user_id_idx ON menu_items(user_id);
CREATE INDEX IF NOT EXISTS daily_summaries_user_id_idx ON daily_summaries(user_id);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_summaries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "profiles_select_own" ON profiles;
CREATE POLICY "profiles_select_own" ON profiles
  FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "profiles_upsert_own" ON profiles;
CREATE POLICY "profiles_upsert_own" ON profiles
  FOR ALL USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "menu_items_select_own" ON menu_items;
CREATE POLICY "menu_items_select_own" ON menu_items
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "menu_items_write_own" ON menu_items;
CREATE POLICY "menu_items_write_own" ON menu_items
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "daily_summaries_select_own" ON daily_summaries;
CREATE POLICY "daily_summaries_select_own" ON daily_summaries
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "daily_summaries_write_own" ON daily_summaries;
CREATE POLICY "daily_summaries_write_own" ON daily_summaries
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
