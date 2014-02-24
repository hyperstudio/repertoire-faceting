-- remove the utility functions

DROP FUNCTION recreate_table(tbl TEXT, select_expr TEXT);

DROP FUNCTION renumber_table(tbl TEXT, col TEXT);

DROP FUNCTION renumber_table(tbl TEXT, col TEXT, threshold REAL);

DROP FUNCTION signature_wastage(tbl TEXT, col TEXT);

DROP FUNCTION nest_levels(tbl TEXT);

DROP FUNCTION expand_nesting(tbl TEXT);