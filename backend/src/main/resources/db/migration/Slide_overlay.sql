ALTER TABLE settings ADD COLUMN user_editable boolean NOT NULL DEFAULT FALSE;

INSERT INTO settings (key, hint, value) VALUES('slide-overlay', 'Slide overlay', '{"type": "complex", "value": null}');