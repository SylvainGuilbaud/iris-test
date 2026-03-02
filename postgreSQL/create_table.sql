CREATE SCHEMA app;

-- CREATE SEQUENCE IF NOT EXISTS app.customer_id_seq
-- 	INCREMENT BY 1
-- 	MINVALUE 1
-- 	MAXVALUE 9223372036854775807
-- 	START 1;

-- DROP TABLE app.customer;

CREATE TABLE IF NOT EXISTS app.customer (
	-- id integer NOT NULL DEFAULT nextval('app.customer_id_seq'),
	id integer NOT NULL,
	last_name varchar(100) NULL,
	first_name varchar(100) NULL,
	city varchar(100) NULL,
    active bool DEFAULT 't',
    category integer DEFAULT 1,
    hashtag bytea,
	gender varchar,
	country varchar(100),
	description text,
	created timestamp NULL,
    inserted timestamp NULL DEFAULT now(),
    lastUpdate timestamp NULL,
	CONSTRAINT customer_pkey PRIMARY KEY (id)
);
INSERT INTO app.customer (id, last_name, first_name, city, active, category, hashtag, gender, country, description, created, inserted, lastUpdate) VALUES
(1, 'Smith', 'John', 'New York', true, 1, '\\x6861736868617368', 'M', 'USA', 'A regular customer.', '2024-01-01 10:00:00', now(), '2024-01-01 10:00:00'),
(2, 'Doe', 'Jane', 'Los Angeles', false, 2, '\\x6861736868617368', 'F', 'USA', 'An inactive customer.', '2024-02-01 11:00:00', now(), '2024-02-01 11:00:00'),
(3, 'Brown', 'Charlie', 'Chicago', true, 1, '\\x6861736868617368', 'M', 'USA', 'A loyal customer.', '2024-03-01 12:00:00', now(), '2024-03-01 12:00:00');


CREATE TABLE IF NOT EXISTS app.personne (
  id int NOT NULL,
  LastName varchar(255) DEFAULT NULL,
  FirstName varchar(255) DEFAULT NULL,
  DOB date DEFAULT NULL,
  Sex varchar(10) DEFAULT NULL,
  PRIMARY KEY (id)
);

insert into app.personne values (1,'Hendrix','Jimi','1942-11-27','M');
insert into app.personne values (2,'Verdurin','Olivia','1954-09-15','F');

INSERT INTO app.personne (id, LastName, FirstName, DOB, Sex) VALUES
(3, 'Smith', 'John', '1980-01-01', 'M'),
(4, 'Doe', 'Jane', '1990-02-01', 'F'),
(5, 'Brown', 'Charlie', '1975-03-01', 'M');