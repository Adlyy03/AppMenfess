  -- ============================================================================
  -- CREATE ADMIN ACCOUNT
  -- ============================================================================
  -- Script untuk membuat akun admin khusus di Supabase
  -- Jalankan di Supabase Dashboard → SQL Editor
  -- ============================================================================

  -- STEP 1: Buat user di auth.users (Supabase Auth)
  -- ============================================================================
  -- PENTING: Ganti nilai berikut sesuai kebutuhan:
  --   - email: Email admin
  --   - password: Password admin (minimal 6 karakter)
  --   - display_name: Nama tampilan admin

  -- Cara 1: Buat via SQL (Recommended untuk testing)
  -- ============================================================================
  DO $$
  DECLARE
    new_user_id uuid;
    admin_email text := 'admin@menfess.com';  -- GANTI INI
    admin_password text := 'admin123456';      -- GANTI INI
    admin_display_name text := 'Super Admin';  -- GANTI INI
  BEGIN
    -- Insert ke auth.users
    INSERT INTO auth.users (
      instance_id,
      id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      recovery_sent_at,
      last_sign_in_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      confirmation_token,
      email_change,
      email_change_token_new,
      recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      admin_email,
      crypt(admin_password, gen_salt('bf')),  -- Hash password
      NOW(),
      NOW(),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      jsonb_build_object('display_name', admin_display_name),
      NOW(),
      NOW(),
      '',
      '',
      '',
      ''
    )
    RETURNING id INTO new_user_id;

    -- Insert ke public.users dengan role super_admin
    INSERT INTO public.users (
      id,
      display_name,
      role,
      is_banned,
      created_at
    ) VALUES (
      new_user_id,
      admin_display_name,
      'super_admin',
      false,
      NOW()
    );

    RAISE NOTICE 'Admin account created successfully!';
    RAISE NOTICE 'User ID: %', new_user_id;
    RAISE NOTICE 'Email: %', admin_email;
    RAISE NOTICE 'Password: %', admin_password;
    RAISE NOTICE 'Role: super_admin';
  END $$;


  -- ============================================================================
  -- CARA 2: Upgrade existing user jadi admin
  -- ============================================================================
  -- Kalau kamu sudah punya akun dan mau upgrade jadi admin:

  -- 2.1 Cari user ID kamu
  SELECT id, email, raw_user_meta_data->>'display_name' as display_name 
  FROM auth.users 
  ORDER BY created_at DESC;

  -- 2.2 Update role jadi super_admin (GANTI 'YOUR_USER_ID' dengan UUID yang benar)
  -- Contoh: UPDATE public.users SET role = 'super_admin' WHERE id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
  -- UPDATE public.users SET role = 'super_admin' WHERE id = 'YOUR_USER_ID';


  -- ============================================================================
  -- CARA 3: Buat multiple admin accounts
  -- ============================================================================
  -- Untuk buat beberapa admin sekaligus:

  DO $$
  DECLARE
    admin_accounts jsonb := '[
      {"email": "admin1@menfess.com", "password": "admin123456", "name": "Admin 1"},
      {"email": "admin2@menfess.com", "password": "admin123456", "name": "Admin 2"},
      {"email": "moderator@menfess.com", "password": "mod123456", "name": "Moderator"}
    ]'::jsonb;
    admin_record jsonb;
    new_user_id uuid;
    admin_role text;
  BEGIN
    FOR admin_record IN SELECT * FROM jsonb_array_elements(admin_accounts)
    LOOP
      -- Tentukan role (moderator untuk yang ketiga, super_admin untuk lainnya)
      IF admin_record->>'email' LIKE '%moderator%' THEN
        admin_role := 'moderator';
      ELSE
        admin_role := 'super_admin';
      END IF;

      -- Insert ke auth.users
      INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        recovery_sent_at,
        last_sign_in_at,
        raw_app_meta_data,
        raw_user_meta_data,
        created_at,
        updated_at,
        confirmation_token,
        email_change,
        email_change_token_new,
        recovery_token
      ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        gen_random_uuid(),
        'authenticated',
        'authenticated',
        admin_record->>'email',
        crypt(admin_record->>'password', gen_salt('bf')),
        NOW(),
        NOW(),
        NOW(),
        '{"provider":"email","providers":["email"]}',
        jsonb_build_object('display_name', admin_record->>'name'),
        NOW(),
        NOW(),
        '',
        '',
        '',
        ''
      )
      RETURNING id INTO new_user_id;

      -- Insert ke public.users
      INSERT INTO public.users (
        id,
        display_name,
        role,
        is_banned,
        created_at
      ) VALUES (
        new_user_id,
        admin_record->>'name',
        admin_role,
        false,
        NOW()
      );

      RAISE NOTICE 'Created: % (%) - Role: %', 
        admin_record->>'name', 
        admin_record->>'email',
        admin_role;
    END LOOP;
  END $$;


  -- ============================================================================
  -- VERIFY ADMIN ACCOUNTS
  -- ============================================================================
  -- Cek semua admin accounts yang sudah dibuat:

  SELECT 
    u.id,
    au.email,
    u.display_name,
    u.role,
    u.is_banned,
    u.created_at
  FROM public.users u
  JOIN auth.users au ON au.id = u.id
  WHERE u.role IN ('super_admin', 'moderator')
  ORDER BY u.created_at DESC;


  -- ============================================================================
  -- DELETE ADMIN ACCOUNT (Kalau salah/testing)
  -- ============================================================================
  -- HATI-HATI: Ini akan hapus permanent!
  -- Uncomment dan ganti email/ID yang benar:

  -- DELETE FROM auth.users WHERE email = 'admin@menfess.com';
  -- DELETE FROM public.users WHERE id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';


  -- ============================================================================
  -- QUICK REFERENCE
  -- ============================================================================
  -- Default admin credentials (setelah run script):
  --   Email: admin@menfess.com
  --   Password: admin123456
  --   Role: super_admin
  --
  -- PENTING: 
  --   1. GANTI password setelah first login!
  --   2. Jangan share credentials ini!
  --   3. Gunakan email yang valid untuk production
  -- ============================================================================
