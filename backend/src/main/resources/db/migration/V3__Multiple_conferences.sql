CREATE TABLE conferences (
  id SERIAL PRIMARY KEY,
  name text NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE csses ADD COLUMN conference_id integer;
ALTER TABLE csses
  ADD CONSTRAINT csses_conference_fkey FOREIGN KEY (conference_id)
  REFERENCES conferences (id)
  ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE services ADD COLUMN conference_id integer;
ALTER TABLE services
  ADD CONSTRAINT services_conference_fkey FOREIGN KEY (conference_id)
  REFERENCES conferences (id)
  ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE settings ADD COLUMN conference_id integer;
ALTER TABLE settings
  ADD CONSTRAINT settings_conference_fkey FOREIGN KEY (conference_id)
  REFERENCES conferences (id)
  ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE slides ADD COLUMN conference_id integer;
ALTER TABLE slides
  ADD CONSTRAINT slides_conference_fkey FOREIGN KEY (conference_id)
  REFERENCES conferences (id)
  ON UPDATE CASCADE ON DELETE CASCADE;
