-- Q3: Cross-Exchange Comparison — MCX Gold Futures vs NSE Index Futures
-- Uses: CTE (WITH), UNION ALL, multi-exchange JOIN, aggregate comparison
-- -----------------------------------------------------------------------
WITH mcx_gold AS (
    SELECT
        'MCX - GOLD'               AS category,
        ROUND(AVG(t.settle_pr), 2) AS avg_settle_pr,
        ROUND(AVG(t.close), 2)     AS avg_close,
        SUM(t.contracts)           AS total_contracts,
        COUNT(*)                   AS records
    FROM trades t
    JOIN expiries ex    ON t.expiry_id     = ex.expiry_id
    JOIN instruments i  ON ex.instrument_id = i.instrument_id
    JOIN exchanges e    ON i.exchange_id    = e.exchange_id
    WHERE e.name = 'MCX' AND i.symbol = 'GOLD'
),
nse_idx AS (
    SELECT
        'NSE - ' || i.symbol       AS category,
        ROUND(AVG(t.settle_pr), 2) AS avg_settle_pr,
        ROUND(AVG(t.close), 2)     AS avg_close,
        SUM(t.contracts)           AS total_contracts,
        COUNT(*)                   AS records
    FROM trades t
    JOIN expiries ex    ON t.expiry_id     = ex.expiry_id
    JOIN instruments i  ON ex.instrument_id = i.instrument_id
    JOIN exchanges e    ON i.exchange_id    = e.exchange_id
    WHERE e.name = 'NSE' AND i.instrument_type = 'FUTIDX'
    GROUP BY i.symbol
)
SELECT * FROM mcx_gold
UNION ALL
SELECT * FROM nse_idx
ORDER BY avg_settle_pr DESC;

-- Sample Output:
-- category        | avg_settle_pr | avg_close | total_contracts | records
-- ----------------+---------------+-----------+-----------------+--------
-- MCX - GOLD      |    38003.63   | 38002.90  |    1742395      |   115
-- NSE - BANKNIFTY |    28818.47   | 28818.49  |   16040562      |   207
-- NSE - NIFTYIT   |    15592.01   | 15634.06  |      9533       |   207
-- NSE - NIFTY     |    11368.58   | 11368.57  |   13440402      |   207
