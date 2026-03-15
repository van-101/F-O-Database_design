-- Q1: Top 10 Symbols by Open Interest Change Across Exchanges
-- Uses: 4-table JOIN, GROUP BY, ABS() for sorting by magnitude
-- ---------------------------------------------------------------
SELECT
    i.symbol,
    e.name                    AS exchange,
    i.instrument_type,
    SUM(t.chg_in_oi)          AS total_oi_change,
    ROUND(AVG(t.open_int), 0) AS avg_open_interest,
    COUNT(*)                  AS trade_days
FROM trades t
JOIN expiries ex    ON t.expiry_id     = ex.expiry_id
JOIN instruments i  ON ex.instrument_id = i.instrument_id
JOIN exchanges e    ON i.exchange_id    = e.exchange_id
GROUP BY i.symbol, e.name, i.instrument_type
ORDER BY ABS(SUM(t.chg_in_oi)) DESC
LIMIT 10;

-- Sample Output:
-- symbol     | exchange | instrument_type | total_oi_change | avg_open_interest | trade_days
-- -----------+----------+-----------------+-----------------+-------------------+-----------
-- IDEA       | NSE      | OPTSTK          |    729134000    |       2061006     |    7666
-- IDEA       | NSE      | FUTSTK          |    614530000    |     178061198     |     207
-- NIFTY      | NSE      | OPTIDX          |    553794075    |         32248     |  228862
-- YESBANK    | NSE      | OPTSTK          |    297517000    |        833148     |    9386
-- SBIN       | NSE      | OPTSTK          |    226764000    |        357758     |   15584
