-- university
CREATE TABLE university (
  id int NOT NULL PRIMARY KEY,
  name VARCHAR(255),
  short_name VARCHAR(255),
  country VARCHAR(255),
  state VARCHAR(255)
);

CREATE INDEX university_name_idx ON university USING btree (name);
CREATE INDEX university_country_idx ON university USING btree (country);
CREATE INDEX university_state_idx ON university USING btree (state);

-- users
CREATE TABLE users (
  id int NOT NULL PRIMARY KEY,
  name VARCHAR(255),
  program_year VARCHAR(255),
  university_id int,
  created_at timestamp NOT NULL DEFAULT NOW(),
  updated_at timestamp NOT NULL DEFAULT NOW(),

  FOREIGN KEY (university_id) REFERENCES university(id)
);

CREATE INDEX users_created_idx ON users USING btree (created_at);
CREATE INDEX users_updated_idx ON users USING btree (updated_at);
CREATE INDEX users_university_idx ON users USING btree (university_id);

-- subscriptions
CREATE TABLE subscriptions (
  id int NOT NULL PRIMARY KEY,
  user_id int,
  term_start timestamp NOT NULL DEFAULT NOW(),
  term_end timestamp NOT NULL DEFAULT NOW(),
  transaction_type VARCHAR(255),

  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX subscriptions_user_id_idx ON subscriptions USING btree (user_id);
CREATE INDEX subscriptions_term_start_idx ON subscriptions USING btree (term_start);
CREATE INDEX subscriptions_term_end_idx ON subscriptions USING btree (term_end);
CREATE INDEX subscriptions_transaction_type_idx ON subscriptions USING btree (transaction_type);


-- copying data to tables
-- university
\copy university FROM '/Users/dustinlo/Desktop/sketchy_interview/universities.csv' delimiter ',' CSV HEADER;
-- users
\copy users FROM '/Users/dustinlo/Desktop/sketchy_interview/users_clean.csv' delimiter ',' CSV HEADER;
-- subscriptions
\copy subscriptions FROM '/Users/dustinlo/Desktop/sketchy_interview/subscriptions_clean.csv' delimiter ',' CSV HEADER;
