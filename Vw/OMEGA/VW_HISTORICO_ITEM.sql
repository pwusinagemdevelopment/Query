ALTER VIEW VW_HISTORICO_ITEM AS 
WITH CTE_HISTORICO AS (
SELECT C_PROD, 
DT_LIBERACAO,
SUM(QT_PREV_PROD) AS QT_PREV_PROD, 
SUM(QTD_PROD) AS QTD_PROD,TOL_PROD,
APLIC_TOL_PROD,VAR_PERC, 
DEPOSITO 
FROM VW_OS_PRODUZIDO
WHERE ST_OS = 'E'
GROUP BY C_PROD, DT_LIBERACAO,TOL_PROD,APLIC_TOL_PROD,VAR_PERC, DEPOSITO
)
SELECT 
	C_PROD, 
	DT_LIBERACAO,
	QT_PREV_PROD,
	QTD_PROD,
	TOL_PROD,
	APLIC_TOL_PROD,
	VAR_PERC, 
	DEPOSITO,
	((QTD_PROD / QT_PREV_PROD) - 1) * 100 AS VAR_MED,
	CASE WHEN APLIC_TOL_PROD = 1 THEN 'SIM' ELSE 'N�O' END AS TEM_TOL
FROM CTE_HISTORICO