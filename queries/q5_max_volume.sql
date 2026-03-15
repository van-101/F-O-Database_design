-- Q5: Performance-Optimized Query — Max Volume per Symbol in Last 30 Days
-- Uses: CTE, ROW_NUMBER() window function, INTERVAL filter, indexes on timestamp
-- Optimization: idx_trades_timestamp eliminates full table scan on WHERE clause
-- -------------------------------------------------------------------------------
WITH daily_vol AS (
    SELECT
        i.symbol,
        e.name                       AS exchange,
        t.timestamp,
        SUM(t.contracts)             AS daily_contracts,
        ROUND(SUM(t.val_inlakh), 2)  AS daily_value_lakh
    FROM trades t
    JOIN expiries ex    ON t.expiry_id     = ex.expiry_id
    JOIN instruments i  ON ex.instrument_id = i.instrument_id
    JOIN exchanges e    ON i.exchange_id    = e.exchange_id
    WHERE t.timestamp >= (SELECT MAX(timestamp) - INTERVAL '30 days' FROM trades)
    GROUP BY i.symbol, e.name, t.timestamp
),
ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY symbol, exchange
            ORDER BY daily_contracts DESC
        ) AS rn
    FROM daily_vol
)
SELECT
    symbol,
    exchange,
    timestamp        AS peak_date,
    daily_contracts  AS max_contracts,
    daily_value_lakh AS value_lakh
FROM ranked
WHERE rn = 1
ORDER BY max_contracts DESC
LIMIT 10;

-- Sample Output:
-- symbol     | exchange | peak_date  | max_contracts | value_lakh
-- -----------+----------+------------+---------------+------------
-- BANKNIFTY  | NSE      | 2019-11-14 |   36882827    | 226830329
-- NIFTY      | NSE      | 2019-10-24 |    9448952    |  82345616
-- YESBANK    | NSE      | 2019-10-31 |     623085    |    960397
