-- Q7: Max Pain Analysis — Strike with Highest Total OI per Expiry
-- Max pain = strike where option writers (sellers) lose minimum money
-- = strike with highest combined CE+PE open interest
-- Uses: CTE, RANK() OVER (PARTITION BY expiry), HAVING, NULLIF
-- ---------------------------------------------------------------
WITH strike_oi AS (
    SELECT
        ex.expiry_dt,
        ex.strike_pr,
        SUM(CASE WHEN ex.option_typ = 'CE' THEN t.open_int ELSE 0 END) AS ce_oi,
        SUM(CASE WHEN ex.option_typ = 'PE' THEN t.open_int ELSE 0 END) AS pe_oi,
        SUM(t.open_int) AS total_oi
    FROM trades t
    JOIN expiries ex    ON t.expiry_id     = ex.expiry_id
    JOIN instruments i  ON ex.instrument_id = i.instrument_id
    WHERE i.symbol          = 'NIFTY'
      AND i.instrument_type = 'OPTIDX'
      AND ex.option_typ     IN ('CE', 'PE')
      AND ex.expiry_dt      BETWEEN '2019-08-01' AND '2019-11-30'
    GROUP BY ex.expiry_dt, ex.strike_pr
    HAVING SUM(t.open_int) > 0   -- filter out zero-OI rows
),
ranked AS (
    SELECT *,
        RANK() OVER (
            PARTITION BY expiry_dt
            ORDER BY total_oi DESC
        ) AS rnk
    FROM strike_oi
    WHERE strike_pr BETWEEN 10000 AND 12500
)
SELECT
    expiry_dt,
    strike_pr                               AS max_pain_strike,
    ce_oi, pe_oi, total_oi,
    ROUND(pe_oi * 1.0 / NULLIF(ce_oi, 0), 3) AS pcr
FROM ranked
WHERE rnk <= 3
ORDER BY expiry_dt, rnk;

-- Sample Output (Aug 2019 expiry):
-- expiry_dt  | max_pain_strike |    ce_oi    |    pe_oi    |  total_oi   |  pcr
-- -----------+-----------------+-------------+-------------+-------------+------
-- 2019-08-29 |    11000.0      | 49805325    | 61445175    | 111250500   | 1.234
-- 2019-08-29 |    11200.0      | 42729000    | 26050125    |  68779125   | 0.610
-- 2019-08-29 |    11500.0      | 47087775    | 13216650    |  60304425   | 0.281
