SET client_encoding = 'UTF8';

CREATE TABLE csses (
  id SERIAL PRIMARY KEY,
  selector character varying(255) NOT NULL,
  property character varying(255) NOT NULL,
  value character varying(255) NOT NULL,
  type character varying(255) NOT NULL,
  title character varying(255) NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE services (
  id SERIAL PRIMARY KEY,
  key character varying(255) NOT NULL,
  value boolean NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE settings (
  id SERIAL PRIMARY KEY,
  key character varying(255) NOT NULL,
  hint character varying(255) NOT NULL,
  value json NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE slides (
  id SERIAL PRIMARY KEY,
  title character varying(255) NOT NULL,
  body character varying(255) NOT NULL,
  visible boolean NOT NULL,
  type character varying(255) NOT NULL,
  index integer NOT NULL,
  name character varying(255) NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  color text
);
