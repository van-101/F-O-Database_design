-- Q6: OI Build-up vs Unwinding Classification
-- Interprets daily price+OI direction to classify market positioning
-- Uses: CASE logic combining OI change direction with price movement
-- -----------------------------------------------------------------
-- Classification logic:
--   OI up   + Price up   = LONG BUILD-UP   (bulls adding positions)
--   OI up   + Price down = SHORT BUILD-UP  (bears adding positions)
--   OI down + Price up   = SHORT COVERING  (bears exiting)
--   OI down + Price down = LONG UNWINDING  (bulls exiting)
-- -----------------------------------------------------------------
SELECT
    t.timestamp,
    i.symbol,
    e.name              AS exchange,
    SUM(t.chg_in_oi)    AS net_oi_change,
    SUM(t.open_int)     AS total_oi,
    SUM(t.contracts)    AS total_volume,
    CASE
        WHEN SUM(t.chg_in_oi) > 0 AND AVG(t.close) >  AVG(t.open) THEN 'LONG BUILD-UP'
        WHEN SUM(t.chg_in_oi) > 0 AND AVG(t.close) <= AVG(t.open) THEN 'SHORT BUILD-UP'
        WHEN SUM(t.chg_in_oi) < 0 AND AVG(t.close) >  AVG(t.open) THEN 'SHORT COVERING'
        WHEN SUM(t.chg_in_oi) < 0 AND AVG(t.close) <= AVG(t.open) THEN 'LONG UNWINDING'
        ELSE 'NEUTRAL'
    END AS oi_signal
FROM trades t
JOIN expiries ex    ON t.expiry_id     = ex.expiry_id
JOIN instruments i  ON ex.instrument_id = i.instrument_id
JOIN exchanges e    ON i.exchange_id    = e.exchange_id
WHERE i.symbol IN ('NIFTY', 'BANKNIFTY', 'SENSEX')
  AND i.instrument_type = 'FUTIDX'
GROUP BY t.timestamp, i.symbol, e.name
ORDER BY t.timestamp DESC, ABS(SUM(t.chg_in_oi)) DESC
LIMIT 12;
