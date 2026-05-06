-- Drop trigger dulu
DROP TRIGGER IF EXISTS on_bookmark_notification ON public.bookmarks;
DROP TRIGGER IF EXISTS on_reaction_added ON public.reactions;
DROP TRIGGER IF EXISTS on_comment_added ON public.comments;
DROP FUNCTION IF EXISTS handle_bookmark_notification();
DROP FUNCTION IF EXISTS handle_new_reaction();
DROP FUNCTION IF EXISTS handle_new_comment();

-- Drop dan buat ulang tabel notifications
DROP TABLE IF EXISTS public.notifications CASCADE;

CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    actor_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    menfess_id UUID REFERENCES public.menfess(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, actor_id, menfess_id, type)
);

-- Enable RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view their own notifications"
ON public.notifications FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "System can insert notifications"
ON public.notifications FOR INSERT
WITH CHECK (true);

CREATE POLICY "Users can update their own notifications"
ON public.notifications FOR UPDATE
USING (auth.uid() = user_id);

-- Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;

-- Trigger untuk LIKE
CREATE OR REPLACE FUNCTION handle_new_reaction()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user_id != (SELECT user_id FROM public.menfess WHERE id = NEW.menfess_id) THEN
    INSERT INTO public.notifications (user_id, actor_id, menfess_id, type)
    VALUES (
      (SELECT user_id FROM public.menfess WHERE id = NEW.menfess_id),
      NEW.user_id,
      NEW.menfess_id,
      'like'
    )
    ON CONFLICT (user_id, actor_id, menfess_id, type) DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_reaction_added
AFTER INSERT ON public.reactions
FOR EACH ROW EXECUTE FUNCTION handle_new_reaction();

-- Trigger untuk COMMENT
CREATE OR REPLACE FUNCTION handle_new_comment()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user_id != (SELECT user_id FROM public.menfess WHERE id = NEW.menfess_id) THEN
    INSERT INTO public.notifications (user_id, actor_id, menfess_id, type)
    VALUES (
      (SELECT user_id FROM public.menfess WHERE id = NEW.menfess_id),
      NEW.user_id,
      NEW.menfess_id,
      'comment'
    )
    ON CONFLICT (user_id, actor_id, menfess_id, type) DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_comment_added
AFTER INSERT ON public.comments
FOR EACH ROW EXECUTE FUNCTION handle_new_comment();

-- Trigger untuk BOOKMARK
CREATE OR REPLACE FUNCTION handle_bookmark_notification()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.notifications (user_id, actor_id, menfess_id, type)
  SELECT 
    m.user_id,
    NEW.user_id,
    NEW.menfess_id,
    'bookmark'
  FROM public.menfess m
  WHERE m.id = NEW.menfess_id
  AND m.user_id != NEW.user_id
  ON CONFLICT (user_id, actor_id, menfess_id, type) DO NOTHING;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_bookmark_notification
AFTER INSERT ON public.bookmarks
FOR EACH ROW EXECUTE FUNCTION handle_bookmark_notification();
