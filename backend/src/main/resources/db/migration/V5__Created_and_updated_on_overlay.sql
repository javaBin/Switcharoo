ALTER TABLE overlays ADD COLUMN created_at timestamp with time zone DEFAULT now() NOT NULL;
ALTER TABLE overlays ADD COLUMN updated_at timestamp with time zone DEFAULT now() NOT NULL;
