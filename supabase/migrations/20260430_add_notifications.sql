-- SQL untuk fitur Notifikasi Internal
-- Jalankan ini di SQL Editor Supabase Dashboard kamu

-- 1. Create notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE, -- Penerima notif
    actor_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,      -- Yang ngelakuin aksi
    menfess_id UUID REFERENCES public.menfess(id) ON DELETE CASCADE, -- Terkait menfess mana
    type TEXT NOT NULL,                                              -- 'like' atau 'comment'
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Enable RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 3. Policies
DROP POLICY IF EXISTS "Users can view their own notifications" ON public.notifications;
CREATE POLICY "Users can view their own notifications"
ON public.notifications FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "System can insert notifications" ON public.notifications;
CREATE POLICY "System can insert notifications"
ON public.notifications FOR INSERT
WITH CHECK (true); -- Kita izinkan insert dari app/trigger

DROP POLICY IF EXISTS "Users can update their own notifications (mark as read)" ON public.notifications;
CREATE POLICY "Users can update their own notifications (mark as read)"
ON public.notifications FOR UPDATE
USING (auth.uid() = user_id);

-- 4. Enable Realtime (Gunakan blok DO biar nggak error kalau udah ada)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' 
        AND schemaname = 'public' 
        AND tablename = 'notifications'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
    END IF;
END $$;

-- 5. Trigger Otomatis (Opsional tapi Mantap)
-- Fungsi ini akan otomatis nambahin notif pas ada like baru
CREATE OR REPLACE FUNCTION public.handle_new_reaction()
RETURNS TRIGGER AS $$
BEGIN
    -- Hanya kirim notif jika yang nge-like bukan pemilik menfess itu sendiri
    -- Dan hanya jika tipenya 'like' (sesuai tabel reactions kamu)
    IF NEW.user_id != (SELECT user_id FROM public.menfess WHERE id = NEW.menfess_id) THEN
        INSERT INTO public.notifications (user_id, actor_id, menfess_id, type)
        VALUES (
            (SELECT user_id FROM public.menfess WHERE id = NEW.menfess_id),
            NEW.user_id,
            NEW.menfess_id,
            'like'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Pasang trigger di tabel reactions (asumsi nama tabelnya 'reactions')
DROP TRIGGER IF EXISTS on_reaction_added ON public.reactions;
CREATE TRIGGER on_reaction_added
AFTER INSERT ON public.reactions
FOR EACH ROW EXECUTE FUNCTION public.handle_new_reaction();

-- 6. Trigger Otomatis buat Komentar
CREATE OR REPLACE FUNCTION public.handle_new_comment()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.user_id != (SELECT user_id FROM public.menfess WHERE id = NEW.menfess_id) THEN
        INSERT INTO public.notifications (user_id, actor_id, menfess_id, type)
        VALUES (
            (SELECT user_id FROM public.menfess WHERE id = NEW.menfess_id),
            NEW.user_id,
            NEW.menfess_id,
            'comment'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Pasang trigger di tabel comments (asumsi nama tabelnya 'comments')
DROP TRIGGER IF EXISTS on_comment_added ON public.comments;
CREATE TRIGGER on_comment_added
AFTER INSERT ON public.comments
FOR EACH ROW EXECUTE FUNCTION public.handle_new_comment();

-- 5. Trigger for bookmarks
CREATE OR REPLACE FUNCTION handle_bookmark_notification()
RETURNS TRIGGER AS $$
BEGIN
  -- Jangan kirim notif kalau bookmark punya sendiri (opsional)
  -- Di sini kita asumsikan pemberi bookmark ingin memberi tahu pemilik post
  INSERT INTO public.notifications (user_id, actor_id, menfess_id, type)
  SELECT 
    m.user_id,
    NEW.user_id,
    NEW.menfess_id,
    'bookmark'
  FROM public.menfess m
  WHERE m.id = NEW.menfess_id
  AND m.user_id != NEW.user_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_bookmark_notification ON public.bookmarks;
CREATE TRIGGER on_bookmark_notification
  AFTER INSERT ON public.bookmarks
  FOR EACH ROW EXECUTE FUNCTION handle_bookmark_notification();
