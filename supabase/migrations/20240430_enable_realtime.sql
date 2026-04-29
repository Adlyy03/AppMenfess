-- Enable Realtime for Menfess table to support Live Counter

-- 1. Tambahkan tabel menfess ke publikasi realtime Supabase
ALTER PUBLICATION supabase_realtime ADD TABLE public.menfess;

-- Catatan: Pastikan di Dashboard Supabase > Database > Replication 
-- tabel 'menfess' sudah terpilih (checked) jika perintah di atas gagal.
