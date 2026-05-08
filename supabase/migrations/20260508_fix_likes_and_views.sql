-- Fix Double Likes and Unique Views
-- Run this in Supabase SQL Editor

-- 1. Create table for unique views
CREATE TABLE IF NOT EXISTS public.menfess_views (
    menfess_id UUID REFERENCES public.menfess(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    viewed_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (menfess_id, user_id)
);

-- 2. Update increment_view to support unique views
DROP FUNCTION IF EXISTS public.increment_view(uuid);
CREATE OR REPLACE FUNCTION public.increment_view(p_menfess_id UUID, p_user_id UUID)
RETURNS void AS $$
BEGIN
  -- Insert into views table, do nothing if already exists
  INSERT INTO public.menfess_views (menfess_id, user_id)
  VALUES (p_menfess_id, p_user_id)
  ON CONFLICT (menfess_id, user_id) DO NOTHING;

  -- Only increment if the row was actually inserted
  IF FOUND THEN
    UPDATE public.menfess
    SET view_count = view_count + 1
    WHERE id = p_menfess_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Automatic Like Counter Trigger (To prevent double counting from App + RPC)
-- This is much more reliable than calling RPC from Flutter
CREATE OR REPLACE FUNCTION public.handle_reaction_counter()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE public.menfess 
        SET like_count = like_count + 1 
        WHERE id = NEW.menfess_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE public.menfess 
        SET like_count = GREATEST(0, like_count - 1) 
        WHERE id = OLD.menfess_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_reaction_counter ON public.reactions;
CREATE TRIGGER on_reaction_counter
AFTER INSERT OR DELETE ON public.reactions
FOR EACH ROW EXECUTE FUNCTION public.handle_reaction_counter();
