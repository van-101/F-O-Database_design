-- ============================================================
-- Partitioning Strategy — PostgreSQL
-- (DuckDB does not support declarative partitioning;
--  use separate DuckDB files per partition for same effect)
-- ============================================================

-- Partition trades by expiry month (range partitioning)
-- Each monthly expiry (~3rd Thursday) maps to one partition
CREATE TABLE trades_partitioned (
    trade_id   INTEGER          NOT NULL,
    expiry_id  INTEGER          NOT NULL,
    timestamp  DATE             NOT NULL,
    open       DOUBLE PRECISION,
    high       DOUBLE PRECISION,
    low        DOUBLE PRECISION,
    close      DOUBLE PRECISION,
    settle_pr  DOUBLE PRECISION,
    contracts  BIGINT,
    val_inlakh DOUBLE PRECISION,
    open_int   BIGINT,
    chg_in_oi  BIGINT
) PARTITION BY RANGE (timestamp);

-- Monthly partitions for the 3-month dataset (Aug-Oct 2019)
CREATE TABLE trades_2019_08 PARTITION OF trades_partitioned
    FOR VALUES FROM ('2019-08-01') TO ('2019-09-01');

CREATE TABLE trades_2019_09 PARTITION OF trades_partitioned
    FOR VALUES FROM ('2019-09-01') TO ('2019-10-01');

CREATE TABLE trades_2019_10 PARTITION OF trades_partitioned
    FOR VALUES FROM ('2019-10-01') TO ('2019-11-01');

CREATE TABLE trades_2019_11 PARTITION OF trades_partitioned
    FOR VALUES FROM ('2019-11-01') TO ('2019-12-01');

-- Default catch-all partition
CREATE TABLE trades_default PARTITION OF trades_partitioned DEFAULT;

-- Index on each partition (PostgreSQL auto-propagates to partitions)
CREATE INDEX ON trades_partitioned (timestamp);
CREATE INDEX ON trades_partitioned (expiry_id);

-- ── Why partition by timestamp? ────────────────────────────
-- 1. Queries filtering on date range (most common) scan only 1-2 partitions
-- 2. Monthly data archival: drop old partition = instant, no DELETE overhead
-- 3. Partition pruning: planner skips irrelevant partitions automatically
-- 4. For 10M+ rows/day HFT: partition by date + sub-partition by exchange
--
-- Alternative: partition by exchange (NSE/BSE/MCX)
-- Better for cross-exchange queries that need full time range per exchange
