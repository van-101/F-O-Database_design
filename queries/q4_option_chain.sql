-- Q4: Option Chain Summary — Grouped by expiry_dt and strike_pr
-- Uses: CASE WHEN pivot (CE/PE), implied volume, PCR, NULLIF guard
-- -----------------------------------------------------------------
SELECT
    ex.expiry_dt,
    ex.strike_pr,
    -- Call side
    SUM(CASE WHEN ex.option_typ = 'CE' THEN t.contracts ELSE 0 END) AS ce_volume,
    SUM(CASE WHEN ex.option_typ = 'CE' THEN t.open_int  ELSE 0 END) AS ce_oi,
    ROUND(AVG(CASE WHEN ex.option_typ = 'CE' THEN t.close END), 2)  AS ce_ltp,
    -- Put side
    SUM(CASE WHEN ex.option_typ = 'PE' THEN t.contracts ELSE 0 END) AS pe_volume,
    SUM(CASE WHEN ex.option_typ = 'PE' THEN t.open_int  ELSE 0 END) AS pe_oi,
    ROUND(AVG(CASE WHEN ex.option_typ = 'PE' THEN t.close END), 2)  AS pe_ltp,
    -- Implied volume = total CE+PE activity at this strike (proxy for market interest)
    SUM(CASE WHEN ex.option_typ IN ('CE','PE') THEN t.contracts ELSE 0 END) AS implied_volume,
    -- Put-Call Ratio by OI (PCR > 1 = bearish, < 1 = bullish)
    ROUND(
        SUM(CASE WHEN ex.option_typ = 'PE' THEN t.open_int ELSE 0 END) * 1.0 /
        NULLIF(SUM(CASE WHEN ex.option_typ = 'CE' THEN t.open_int ELSE 0 END), 0)
    , 3) AS pcr_oi
FROM trades t
JOIN expiries ex    ON t.expiry_id     = ex.expiry_id
JOIN instruments i  ON ex.instrument_id = i.instrument_id
WHERE i.symbol          = 'NIFTY'
  AND i.instrument_type = 'OPTIDX'
  AND ex.option_typ     IN ('CE', 'PE')
  AND ex.strike_pr      BETWEEN 10500 AND 11500
  AND ex.expiry_dt      = '2019-08-29'
GROUP BY ex.expiry_dt, ex.strike_pr
ORDER BY ex.strike_pr;

-- Sample Output (ATM region ~11000):
-- expiry_dt  | strike_pr | ce_volume   | ce_oi      | ce_ltp | pe_volume  | pe_oi      | pe_ltp | implied_volume | pcr_oi
-- -----------+-----------+-------------+------------+--------+------------+------------+--------+----------------+-------
-- 2019-08-29 |  10900.0  |  1734943    | 19409925   | 177.38 |  3097483   | 28636500   |  93.43 |   4832426      | 1.475
-- 2019-08-29 |  11000.0  |  4317783    | 49805325   | 121.36 |  3350755   | 61445175   | 133.82 |   7668538      | 1.234
-- 2019-08-29 |  11100.0  |  1643147    |  5607375   |  97.61 |   652669   |  3633375   | 157.83 |   2295816      | 0.648
