

CREATE OR REPLACE FUNCTION renumber_table(tbl TEXT, col TEXT) RETURNS VOID AS $$
BEGIN
  -- Drop column if exists (also resets sequence)
  BEGIN
    EXECUTE 'ALTER TABLE ' || tbl || ' DROP COLUMN ' || col;
  EXCEPTION
    WHEN undefined_column THEN NULL;
  END;
  -- Add column
  EXECUTE 'ALTER TABLE ' || tbl || ' ADD COLUMN ' || col || ' SERIAL';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION recreate_table(tbl TEXT, expr TEXT) RETURNS VOID AS $$
BEGIN
  EXECUTE 'DROP TABLE IF EXISTS ' || tbl;
  EXECUTE 'CREATE TABLE ' || tbl || ' AS ' || expr;
END;
$$ LANGUAGE plpgsql;
