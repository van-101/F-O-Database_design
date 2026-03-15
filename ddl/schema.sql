-- ============================================================
-- F&O Database Schema — Normalized 3NF
-- Compatible with DuckDB and PostgreSQL
-- ============================================================

CREATE TABLE IF NOT EXISTS exchanges (
    exchange_id INTEGER PRIMARY KEY,
    name        VARCHAR(10)  NOT NULL UNIQUE,   -- 'NSE', 'BSE', 'MCX'
    country     VARCHAR(50)  DEFAULT 'India',
    currency    VARCHAR(5)   DEFAULT 'INR'
);

CREATE TABLE IF NOT EXISTS instruments (
    instrument_id   INTEGER PRIMARY KEY,
    exchange_id     INTEGER     NOT NULL REFERENCES exchanges(exchange_id),
    symbol          VARCHAR(30) NOT NULL,
    instrument_type VARCHAR(10) NOT NULL,        -- FUTIDX, FUTSTK, OPTIDX, OPTSTK
    UNIQUE(exchange_id, symbol, instrument_type)
);

CREATE TABLE IF NOT EXISTS expiries (
    expiry_id     INTEGER PRIMARY KEY,
    instrument_id INTEGER     NOT NULL REFERENCES instruments(instrument_id),
    expiry_dt     DATE        NOT NULL,
    strike_pr     DOUBLE PRECISION DEFAULT 0.0, -- 0 for futures
    option_typ    VARCHAR(5)  DEFAULT 'XX',      -- 'XX'=futures, 'CE'=call, 'PE'=put
    UNIQUE(instrument_id, expiry_dt, strike_pr, option_typ)
);

CREATE TABLE IF NOT EXISTS trades (
    trade_id   INTEGER          PRIMARY KEY,
    expiry_id  INTEGER          NOT NULL REFERENCES expiries(expiry_id),
    timestamp  DATE             NOT NULL,
    open       DOUBLE PRECISION,
    high       DOUBLE PRECISION,
    low        DOUBLE PRECISION,
    close      DOUBLE PRECISION,
    settle_pr  DOUBLE PRECISION,                 -- official exchange settlement price
    contracts  BIGINT,
    val_inlakh DOUBLE PRECISION,                 -- notional value in Indian Lakhs
    open_int   BIGINT,
    chg_in_oi  BIGINT
);

-- ── Seed Exchanges ─────────────────────────────────────────
INSERT INTO exchanges VALUES (1, 'NSE', 'India', 'INR');
INSERT INTO exchanges VALUES (2, 'BSE', 'India', 'INR');
INSERT INTO exchanges VALUES (3, 'MCX', 'India', 'INR');
