-- ---------------------------------------------------------------------------
-- Function to replace empty strings across all columns of a table
-- Source:
-- https://stackoverflow.com/a/10686513/2757825
-- ---------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION f_empty2null(_tbl regclass, OUT updated_rows int)
  LANGUAGE plpgsql AS
$func$
DECLARE
   _typ  CONSTANT regtype[] := '{text, bpchar, varchar}';  -- ARRAY of all basic character types
   _sql  text;
BEGIN
   SELECT INTO _sql                       -- build SQL command
          'UPDATE ' || _tbl
          || E'\nSET    ' || string_agg(format('%1$s = NULLIF(%1$s, '''')', col), E'\n      ,')
          || E'\nWHERE  ' || string_agg(col || ' = ''''', ' OR ')
   FROM  (
      SELECT quote_ident(attname) AS col
      FROM   pg_attribute
      WHERE  attrelid = _tbl              -- valid, visible, legal table name 
      AND    attnum >= 1                  -- exclude tableoid & friends
      AND    NOT attisdropped             -- exclude dropped columns
      AND    NOT attnotnull               -- exclude columns defined NOT NULL!
      AND    atttypid = ANY(_typ)         -- only character types
      ORDER  BY attnum
      ) sub;

   -- RAISE NOTICE '%', _sql;  -- test?

   -- Execute
   IF _sql IS NULL THEN
      updated_rows := 0;                        -- nothing to update
   ELSE
      EXECUTE _sql;
      GET DIAGNOSTICS updated_rows = ROW_COUNT; -- Report number of affected rows
   END IF;
END
$func$;