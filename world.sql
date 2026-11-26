-- world.sql -- the world, as a question.
--
-- Everything else here tells you the world. This asks for it. Put the question
-- to anything that keeps SQLite, which is most things, including very likely
-- the telephone you are holding:
--
--   sqlite3 < world.sql
--
-- and it is answered in twenty-five rows, one column wide. The first
-- twenty-four are the world. The last is what it says.
--
-- No table is created. None is consulted. There is nothing after any FROM
-- below that was there before the question was put, and the database may be
-- as empty as you like; an empty one is recommended, as being nearest to the
-- facts. The world is not kept anywhere. It is worked out on being asked, and
-- let go of when the asking stops, and nothing is written down. A database
-- finds this hard to credit and will hand you the rows with a straight face.
--
-- It asks the time once, at the top, and turns to suit: all the way round in
-- five hundred and twenty-four seconds, near enough. Ask again a minute later
-- and you get a different answer to the same question. In any other table that
-- would be looked into.
--
-- The Caret is in it, at the usual latitude. The At was left out. It would
-- have needed a join, and it has never been joined to anything.

WITH RECURSIVE

  -- The time. The only fact in the file, and it is borrowed.
  hour(t) AS (
    SELECT (CAST(strftime('%s', 'now') AS INTEGER) % 524) * 0.012
  ),

  -- Sixty across and twenty-four down, counted out one at a time,
  -- because there was nowhere to look them up.
  across(i) AS (SELECT -30 UNION ALL SELECT i + 1 FROM across WHERE i < 29),
  down(j)   AS (SELECT -12 UNION ALL SELECT j + 1 FROM down   WHERE j < 11),

  -- Every place there could be anything, and how far it is from the middle.
  place(i, j, x, y, r) AS (
    SELECT i, j, (i + 0.5) / 22.0, (j + 0.5) / 11.0,
           1 - ((i + 0.5) / 22.0) * ((i + 0.5) / 22.0)
             - ((j + 0.5) / 11.0) * ((j + 0.5) / 11.0)
      FROM across, down
  ),

  -- The same places, with the third direction supplied. NULL means sky.
  -- It is the one honest use of NULL on record: not known, and not there.
  ball(i, j, x, y, z) AS (
    SELECT i, j, x, y, CASE WHEN r >= 0 THEN sqrt(r) END FROM place
  ),

  -- Where the light falls, and which way each place is facing just now.
  lit(i, j, y, z, k, a) AS (
    SELECT i, j, y, z,
           CASE WHEN z * 0.6 - x * 0.5 - y * 0.6 > 0.5 THEN 1
                WHEN z * 0.6 - x * 0.5 - y * 0.6 > 0.1 THEN 2
                ELSE 3 END,
           atan2(x, z) + t
      FROM ball, hour
  ),

  -- What is there. Sky first, then the ship, then the ice, then the Hash,
  -- and whatever is left over is sea, which is how the sea has always been
  -- arrived at.
  mark(i, j, c) AS (
    SELECT i, j,
           CASE WHEN z IS NULL THEN ' '
                WHEN j = 4 AND cos(a - (SELECT t FROM hour) * 1.3) > 0.9998 THEN '^'
                WHEN abs(y) > 0.935 THEN substr('*++', k, 1)
                WHEN sin(a * 2 + y * 3) + cos(a - y * 2 + 4) > 0.8 THEN substr('#o:', k, 1)
                ELSE substr('~-.', k, 1) END
      FROM lit
  ),

  -- The rows, put together a character at a time from the left, in the
  -- order they would be read. Nobody told the database there was an order.
  line(j, i, s) AS (
    SELECT j, -31, '' FROM down
    UNION ALL
    SELECT line.j, mark.i, line.s || mark.c
      FROM line JOIN mark ON mark.j = line.j AND mark.i = line.i + 1
  )

-- The question itself. It is the shortest part, as it usually is.
SELECT s AS world
  FROM (SELECT j, rtrim(s) AS s FROM line WHERE i = 29
        UNION ALL SELECT 12, ''
        UNION ALL SELECT 13, 'hello world')
 ORDER BY j;

-- Twenty-six rows, then, with the blank one. It was not counted above,
-- there being nothing in it, and it turns up in the answer all the same.
-- Nothing has been stored. Close the database and look: it is the size
-- it was. You could put the question again.
