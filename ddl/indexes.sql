-- ============================================================
-- Performance Indexes — F&O Database
-- ============================================================

-- trades: primary access patterns
CREATE INDEX IF NOT EXISTS idx_trades_timestamp   ON trades(timestamp);
CREATE INDEX IF NOT EXISTS idx_trades_expiry_id   ON trades(expiry_id);

-- instruments: symbol and exchange lookups
CREATE INDEX IF NOT EXISTS idx_inst_symbol        ON instruments(symbol);
CREATE INDEX IF NOT EXISTS idx_inst_exchange_id   ON instruments(exchange_id);

-- expiries: join and filter patterns
CREATE INDEX IF NOT EXISTS idx_exp_instrument_id  ON expiries(instrument_id);
CREATE INDEX IF NOT EXISTS idx_exp_expiry_dt      ON expiries(expiry_dt);
CREATE INDEX IF NOT EXISTS idx_exp_option_typ     ON expiries(option_typ);

-- Composite index for option chain queries (symbol + expiry + strike)
CREATE INDEX IF NOT EXISTS idx_exp_chain
    ON expiries(instrument_id, expiry_dt, strike_pr, option_typ);

-- ── PostgreSQL only: BRIN index for time-series timestamp ──
-- BRIN is ideal because timestamp is monotonically increasing
-- (new trades always have later dates). 1/1000th size of B-tree.
--
-- CREATE INDEX idx_trades_ts_brin ON trades USING BRIN (timestamp)
--     WITH (pages_per_range = 128);
