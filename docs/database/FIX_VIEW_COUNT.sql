-- Fix view count: 1 user = 1 view per post

-- 1. Buat tabel untuk track unique views
CREATE TABLE IF NOT EXISTS public.menfess_views (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    menfess_id UUID NOT NULL REFERENCES public.menfess(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    viewed_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(menfess_id, user_id)
);

-- 2. Enable RLS
ALTER TABLE public.menfess_views ENABLE ROW LEVEL SECURITY;

-- 3. Policy: semua user bisa insert view
CREATE POLICY "Anyone can insert views"
ON public.menfess_views FOR INSERT
WITH CHECK (true);

-- 4. Policy: user bisa liat view sendiri
CREATE POLICY "Users can view their own views"
ON public.menfess_views FOR SELECT
USING (auth.uid() = user_id);

-- 5. Function untuk increment view (unique per user)
CREATE OR REPLACE FUNCTION increment_view(menfess_id UUID, user_id UUID)
RETURNS void AS $$
BEGIN
  -- Insert view record (akan fail kalau udah ada karena UNIQUE constraint)
  INSERT INTO public.menfess_views (menfess_id, user_id)
  VALUES (menfess_id, user_id)
  ON CONFLICT (menfess_id, user_id) DO NOTHING;
  
  -- Update view count di tabel menfess
  UPDATE public.menfess
  SET view_count = (
    SELECT COUNT(DISTINCT user_id)
    FROM public.menfess_views
    WHERE menfess_views.menfess_id = menfess.id
  )
  WHERE id = menfess_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
