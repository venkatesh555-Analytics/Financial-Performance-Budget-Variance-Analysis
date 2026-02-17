/* ============================================================
   Financial Performance & Budget Variance Analysis
   ============================================================ */

/* ------------------------------------------------------------
   1. OVERALL KPI METRICS
------------------------------------------------------------ */

-- Total Revenue
SELECT SUM(actual_revenue) AS total_revenue
FROM finance_fact;

-- Total Expense
SELECT SUM(expense) AS total_expense
FROM finance_fact;

-- Net Profit
SELECT 
    SUM(actual_revenue) - SUM(expense) AS net_profit
FROM finance_fact;

-- Profit Margin %
SELECT 
    ROUND(
        (SUM(actual_revenue) - SUM(expense)) 
        / SUM(actual_revenue) * 100, 
    2) AS profit_margin_pct
FROM finance_fact;


/* ------------------------------------------------------------
   2. BUDGET VARIANCE ANALYSIS
------------------------------------------------------------ */

-- Revenue Variance
SELECT 
    SUM(actual_revenue) - SUM(budget_revenue) AS revenue_variance
FROM finance_fact;

-- Revenue Variance %
SELECT 
    ROUND(
        (SUM(actual_revenue) - SUM(budget_revenue)) 
        / SUM(budget_revenue) * 100,
    2) AS revenue_variance_pct
FROM finance_fact;


/* ------------------------------------------------------------
   3. MONTHLY REVENUE TREND
------------------------------------------------------------ */

SELECT 
    d.month_year,
    SUM(f.actual_revenue) AS monthly_revenue,
    SUM(f.expense) AS monthly_expense,
    SUM(f.actual_revenue) - SUM(f.expense) AS monthly_net_profit
FROM finance_fact f
JOIN date_dim d 
    ON f.date = d.date
GROUP BY d.month_year
ORDER BY d.month_year;


/* ------------------------------------------------------------
   4. MONTH-OVER-MONTH (MoM) GROWTH
------------------------------------------------------------ */

WITH monthly_revenue AS (
    SELECT 
        d.month_year,
        SUM(f.actual_revenue) AS total_revenue
    FROM finance_fact f
    JOIN date_dim d 
        ON f.date = d.date
    GROUP BY d.month_year
)

SELECT 
    month_year,
    total_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) 
            OVER (ORDER BY month_year)) 
        / LAG(total_revenue) 
            OVER (ORDER BY month_year) * 100,
    2) AS mom_growth_pct
FROM monthly_revenue;


/* ------------------------------------------------------------
   5. YEAR-OVER-YEAR (YoY) GROWTH
------------------------------------------------------------ */

WITH yearly_revenue AS (
    SELECT 
        d.year,
        SUM(f.actual_revenue) AS total_revenue
    FROM finance_fact f
    JOIN date_dim d 
        ON f.date = d.date
    GROUP BY d.year
)

SELECT 
    year,
    total_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) 
            OVER (ORDER BY year)) 
        / LAG(total_revenue) 
            OVER (ORDER BY year) * 100,
    2) AS yoy_growth_pct
FROM yearly_revenue;


/* ------------------------------------------------------------
   6. DEPARTMENT EXPENSE ANALYSIS
------------------------------------------------------------ */

SELECT 
    department,
    SUM(expense) AS total_expense
FROM finance_fact
GROUP BY department
ORDER BY total_expense DESC;


/* ------------------------------------------------------------
   7. DEPARTMENT NET PROFIT ANALYSIS
------------------------------------------------------------ */

SELECT 
    department,
    SUM(actual_revenue) AS total_revenue,
    SUM(expense) AS total_expense,
    SUM(actual_revenue) - SUM(expense) AS net_profit,
    ROUND(
        (SUM(actual_revenue) - SUM(expense)) 
        / SUM(actual_revenue) * 100,
    2) AS profit_margin_pct
FROM finance_fact
GROUP BY department
ORDER BY net_profit DESC;


/* ------------------------------------------------------------
   8. RANK DEPARTMENTS BY PROFITABILITY
------------------------------------------------------------ */

SELECT 
    department,
    SUM(actual_revenue) - SUM(expense) AS net_profit,
    RANK() OVER (
        ORDER BY SUM(actual_revenue) - SUM(expense) DESC
    ) AS profitability_rank
FROM finance_fact
GROUP BY department;


/* ------------------------------------------------------------
   9. IDENTIFY LOSS-MAKING DEPARTMENTS
------------------------------------------------------------ */

SELECT 
    department,
    SUM(actual_revenue) - SUM(expense) AS net_profit
FROM finance_fact
GROUP BY department
HAVING SUM(actual_revenue) - SUM(expense) < 0;


/* ------------------------------------------------------------
   10. MONTHLY VARIANCE SUMMARY
------------------------------------------------------------ */

SELECT 
    d.month_year,
    SUM(f.budget_revenue) AS total_budget_revenue,
    SUM(f.actual_revenue) AS total_actual_revenue,
    SUM(f.actual_revenue) - SUM(f.budget_revenue) AS revenue_variance,
    ROUND(
        (SUM(f.actual_revenue) - SUM(f.budget_revenue)) 
        / SUM(f.budget_revenue) * 100,
    2) AS revenue_variance_pct
FROM finance_fact f
JOIN date_dim d 
    ON f.date = d.date
GROUP BY d.month_year
ORDER BY d.month_year;
