--                           Table "public.subscriptions"
--       Column      |            Type             | Collation | Nullable | Default 
-- ------------------+-----------------------------+-----------+----------+---------
--  id               | integer                     |           | not null | 
--  user_id          | integer                     |           |          | 
--  term_start       | timestamp without time zone |           | not null | now()
--  term_end         | timestamp without time zone |           | not null | now()
--  transaction_type | character varying(255)      |           |          | 

CREATE MATERIALIZED VIEW subscription_by_month AS

-- generating series of year/month's from earliest term_start to latest term_end
WITH year_month AS (
  SELECT * FROM
  GENERATE_SERIES(
    (SELECT DATE_TRUNC('month', MIN(term_start)) FROM subscriptions),
    (SELECT DATE_TRUNC('month', MAX(term_end)) FROM subscriptions),
    INTERVAL '1 month'
  ) AS month
), user_subscription_by_month AS (
  SELECT
    s.id AS subscription_id,
    s.user_id,
    u.university_id,
    s.term_start,
    s.term_end,
    s.transaction_type,
    ym.month
  FROM subscriptions s
  INNER JOIN users u ON s.user_id = u.id
  INNER JOIN year_month ym
    ON DATE_TRUNC('MONTH', ym.month) BETWEEN DATE_TRUNC('month', s.term_start) AND DATE_TRUNC('month', s.term_end)
  ORDER BY 
    s.user_id ASC,
    ym.month ASC
)
SELECT 
  university_id,
  transaction_type,
  month,
  COUNT(*) AS subs
FROM user_subscription_by_month
GROUP BY university_id, transaction_type, month
ORDER BY university_id, month ASC

WITH DATA;


--                 Materialized view "public.subscription_by_month"
--       Column      |            Type             | Collation | Nullable | Default 
-- ------------------+-----------------------------+-----------+----------+---------
--  id               | integer                     |           |          | 
--  user_id          | integer                     |           |          | 
--  university_id    | integer                     |           |          | 
--  term_start       | timestamp without time zone |           |          | 
--  term_end         | timestamp without time zone |           |          | 
--  transaction_type | character varying(255)      |           |          | 
--  month            | timestamp without time zone |           |          | 

CREATE INDEX subscription_by_month_university_idx ON subscription_by_month USING btree (university_id);
CREATE INDEX subscription_by_month_transaction_idx ON subscription_by_month USING btree (transaction_type);
CREATE INDEX subscription_by_month_idx ON subscription_by_month USING btree (month);




-- TESTING
SELECT 
  month,
  COUNT(*)
FROM subscription_by_month
GROUP BY month
ORDER BY 1 ASC;


SELECT COUNT(*)
FROM subscriptions 
WHERE '2023-03-01 00:00:00' BETWEEN DATE_TRUNC('month', term_start) AND DATE_TRUNC('month', term_end);
