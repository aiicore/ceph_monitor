CREATE TABLE IF NOT EXISTS header(
  id        INTEGER PRIMARY KEY,
  mode      TEXT,
  timestamp INTEGER,
  label     TEXT
);

CREATE TABLE IF NOT EXISTS c(
  header_id   INTEGER,
  key         TEXT,
  ctx_i       INTEGER,
  ctx_v       INTEGER,
  cpu_usr     FLOAT,
  cpu_sys FLOAT
);

CREATE TABLE IF NOT EXISTS m(
  header_id   INTEGER,
  key         TEXT,
  min_f       INTEGER,
  maj_f       INTEGER,
  rss         INTEGER
);

CREATE TABLE IF NOT EXISTS i(
  header_id INTEGER,
  key       TEXT,
  io_rd     INTEGER,
  io_rb     INTEGER,
  io_wr     INTEGER,
  io_wb     INTEGER
);


CREATE VIEW IF NOT EXISTS avg_c AS
  SELECT header.id,
         datetime(header.timestamp, 'unixepoch', 'localtime') as datetime,
         ROUND( AVG(c.ctx_i), 4) as 'context_i',
         ROUND( AVG(c.ctx_v), 4) as 'context_v',
         ROUND( AVG(c.cpu_usr), 4) as 'cpu_user_time',
         ROUND( AVG(c.cpu_sys), 4) as 'cpu_system_time',
         header.label
    FROM c JOIN header ON c.header_id = header.id
  GROUP BY c.header_id
  ORDER BY datetime;

CREATE VIEW IF NOT EXISTS avg_i AS
  SELECT header.id,
         datetime(header.timestamp, 'unixepoch', 'localtime') as datetime,
         CAST( AVG(i.io_rd) AS INTEGER ) as 'reads',
         CAST( AVG(i.io_rb) AS INTEGER ) as 'read_bytes',
         CAST( AVG(i.io_wr) AS INTEGER ) as 'writes',
         CAST( AVG(i.io_wb) AS INTEGER ) as 'write_bytes',
         header.label
    FROM i JOIN header ON i.header_id = header.id
  GROUP BY i.header_id
  ORDER BY datetime;

CREATE VIEW IF NOT EXISTS avg_m AS
  SELECT header.id,
         datetime(header.timestamp, 'unixepoch', 'localtime') as datetime,
         ROUND( AVG(m.min_f), 2) as 'minor_page_faults',
         ROUND( AVG(m.maj_f), 2) as 'major_page_faults',
         ROUND( AVG(m.rss), 2) as 'resident_size',
         ROUND( AVG(m.rss) / 1024 / 1024, 4) as 'resident_size_MB',
         header.label
    FROM m JOIN header ON m.header_id = header.id
  GROUP BY m.header_id
  ORDER BY datetime;

 CREATE VIEW IF NOT EXISTS sum_c AS 
   SELECT header.id, 
          datetime(header.timestamp, 'unixepoch', 'localtime') as datetime,
          SUM(c.ctx_i) as 'context_i',
          SUM(c.ctx_v) as 'context_v', 
          SUM(c.cpu_usr) as 'cpu_user_time',
          SUM(c.cpu_sys) as 'cpu_system_time',
          header.label
     FROM c JOIN header ON c.header_id = header.id
   GROUP BY c.header_id
   ORDER BY datetime;

 CREATE VIEW IF NOT EXISTS sum_i AS
   SELECT header.id,
          datetime(header.timestamp, 'unixepoch', 'localtime') as datetime,
          SUM(i.io_rd) as 'reads',
          SUM(i.io_rb) as 'read_bytes',
          SUM(i.io_wr) as 'writes',
          SUM(i.io_wb) as 'write_bytes',
          header.label
     FROM i JOIN header ON i.header_id = header.id
   GROUP BY i.header_id
   ORDER BY datetime;

 CREATE VIEW IF NOT EXISTS sum_m AS
   SELECT header.id,
          datetime(header.timestamp, 'unixepoch', 'localtime') as datetime,
          SUM(m.min_f) as 'minor_page_faults',
          SUM(m.maj_f) as 'major_page_faults',
          SUM(m.rss) as 'resident_size',
          SUM(m.rss) / 1024 / 1024 as 'resident_size_MB',
          header.label
     FROM m JOIN header ON m.header_id = header.id
   GROUP BY m.header_id
   ORDER BY datetime;
