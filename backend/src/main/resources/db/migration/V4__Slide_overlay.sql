CREATE TABLE overlays (
  id SERIAL PRIMARY KEY,
  enabled boolean NOT NULL,
  image text NOT NULL,
  placement text DEFAULT 'TopLeft' NOT NULL,
  width text DEFAULT '100%' NOT NULL,
  height text DEFAULT '100%' NOT NULL,
  conference_id integer NOT NULL
);

ALTER TABLE overlays
  ADD CONSTRAINT overlays_conference_fkey FOREIGN KEY (conference_id)
  REFERENCES conferences (id)
  ON UPDATE CASCADE ON DELETE CASCADE;
