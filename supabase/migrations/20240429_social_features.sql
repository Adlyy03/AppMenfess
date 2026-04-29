-- SQL Migrations untuk Menfess App (Likes, Comments, Views)

-- ============================================================================
-- 1. FUNCTIONS UNTUK ATOMIC INCREMENT/DECREMENT COUNTERS
-- ============================================================================

-- Increment Like
DROP FUNCTION IF EXISTS increment_like(uuid);
CREATE OR REPLACE FUNCTION increment_like(p_menfess_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.menfess
  SET like_count = like_count + 1
  WHERE id = p_menfess_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Decrement Like
DROP FUNCTION IF EXISTS decrement_like(uuid);
CREATE OR REPLACE FUNCTION decrement_like(p_menfess_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.menfess
  SET like_count = GREATEST(0, like_count - 1)
  WHERE id = p_menfess_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Increment Comment
DROP FUNCTION IF EXISTS increment_comment(uuid);
CREATE OR REPLACE FUNCTION increment_comment(p_menfess_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.menfess
  SET comment_count = comment_count + 1
  WHERE id = p_menfess_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Increment View
DROP FUNCTION IF EXISTS increment_view(uuid);
CREATE OR REPLACE FUNCTION increment_view(menfess_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.menfess
  SET view_count = view_count + 1
  WHERE id = menfess_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 2. SCHEMA FIXES (Mencegah Duplicate Like)
-- ============================================================================

-- Tambahkan UNIQUE constraint pada reactions (menfess_id, user_id) 
-- kalau belum ada agar ON CONFLICT di Flutter berfungsi dengan benar.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.constraint_column_usage WHERE constraint_name = 'reactions_menfess_user_unique') THEN
        ALTER TABLE public.reactions ADD CONSTRAINT reactions_menfess_user_unique UNIQUE (menfess_id, user_id);
    END IF;
END $$;

-- ============================================================================
-- 3. INDEXES (Untuk Performa)
-- ============================================================================

-- Index untuk feed pagination dan filtering
CREATE INDEX IF NOT EXISTS idx_menfess_created_at ON public.menfess(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_menfess_user_id ON public.menfess(user_id);

-- Index untuk comments (sering di-query berdasarkan menfess_id)
CREATE INDEX IF NOT EXISTS idx_comments_menfess_id ON public.comments(menfess_id);

-- Index untuk reactions (sering di-query untuk ngecek user sudah like atau belum)
CREATE INDEX IF NOT EXISTS idx_reactions_user_menfess ON public.reactions(user_id, menfess_id);

-- ============================================================================
-- 4. RLS POLICIES (Review)
-- ============================================================================

-- Pastikan authenticated users bisa select, insert, delete like-nya sendiri
DROP POLICY IF EXISTS "Enable read access for all users" ON public.reactions;
CREATE POLICY "Enable read access for all users" ON public.reactions FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can insert their own reactions" ON public.reactions;
CREATE POLICY "Users can insert their own reactions" ON public.reactions FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own reactions" ON public.reactions;
CREATE POLICY "Users can delete their own reactions" ON public.reactions FOR DELETE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own reactions" ON public.reactions;
CREATE POLICY "Users can update their own reactions" ON public.reactions FOR UPDATE USING (auth.uid() = user_id);

-- Policies untuk komentar
DROP POLICY IF EXISTS "Enable read access for all comments" ON public.comments;
CREATE POLICY "Enable read access for all comments" ON public.comments FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can insert their own comments" ON public.comments;
CREATE POLICY "Users can insert their own comments" ON public.comments FOR INSERT WITH CHECK (auth.uid() = user_id);
