-- Q2: Volatility Analysis — 7-Day Rolling Std Dev of NIFTY Option Close Prices
-- Uses: Window function STDDEV() OVER with ROWS BETWEEN, PARTITION BY expiry
-- -------------------------------------------------------------------------------
SELECT
    ex.strike_pr,
    ex.option_typ,
    t.timestamp,
    ROUND(t.close, 2)  AS close,
    ROUND(STDDEV(t.close) OVER (
        PARTITION BY ex.expiry_id
        ORDER BY t.timestamp
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 4) AS rolling_7d_stddev,
    ROUND(AVG(t.close) OVER (
        PARTITION BY ex.expiry_id
        ORDER BY t.timestamp
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_7d_avg
FROM trades t
JOIN expiries ex    ON t.expiry_id     = ex.expiry_id
JOIN instruments i  ON ex.instrument_id = i.instrument_id
WHERE i.symbol          = 'NIFTY'
  AND i.instrument_type = 'OPTIDX'
  AND ex.option_typ     IN ('CE', 'PE')
  AND t.close           > 0
  AND ex.strike_pr      BETWEEN 10800 AND 11000
  AND ex.expiry_dt      = '2019-08-29'
ORDER BY ex.strike_pr, ex.option_typ, t.timestamp
LIMIT 20;

-- Sample Output (strike 10800 CE):
-- strike_pr | option_typ | timestamp  | close  | rolling_7d_stddev | rolling_7d_avg
-- ----------+------------+------------+--------+-------------------+---------------
--   10800   |    CE      | 2019-08-01 | 295.30 |       null        |    295.30
--   10800   |    CE      | 2019-08-02 | 310.35 |     10.6420       |    302.83
--   10800   |    CE      | 2019-08-05 | 224.50 |     45.8428       |    276.72
--   10800   |    CE      | 2019-08-06 | 273.55 |     37.4639       |    275.93
