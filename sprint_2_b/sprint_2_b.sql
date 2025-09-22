USE transactions;

SELECT *
FROM company
LIMIT 5;

SELECT *
FROM transaction
LIMIT 5;

-- NIVEL 1
-- Exercici 2
-- CON JOIN
-- a) Listado de los países que están generando ventas
SELECT DISTINCT c.country AS country_con_ventas
FROM company AS c
INNER JOIN transaction AS t
	ON c.id = t.company_id
WHERE declined = 0 -- que están generando ventas (tienen que ser "declined" = 0 = false)
ORDER BY country_con_ventas ASC; -- añadido para una mayor legibilidad

-- b) Desde cuántos países se generan las ventas
SELECT COUNT(DISTINCT country) AS n_paises_con_ventas
FROM company AS c
INNER JOIN transaction AS t
	ON c.id = t.company_id
WHERE t.declined = 0; -- países que generan ventas

-- c) Identifica a la compañía con la mayor media de ventas
SELECT
	c.id,
	c.company_name AS company_with_highest_avg_sales,
	AVG(t.amount) AS avg_sales_amount
FROM company AS c
INNER JOIN transaction AS t
	ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY 
	c.id,
	company_with_highest_avg_sales
ORDER BY avg_sales_amount DESC
LIMIT 1;

-- Exercici 3
-- SIN JOIN
-- a) Muestra todas las transacciones realizadas por empresas de Alemania
-- OPCION 1 - con IN
SELECT *
FROM transaction
WHERE company_id IN (
	SELECT
		id
	FROM company
	WHERE country = "Germany"
    )
	AND declined = 0
;

-- a) Muestra todas las transacciones realizadas por empresas de Alemania
-- OPCION 2 - con WHERE EXISTS
SELECT *
FROM transaction
WHERE EXISTS (SELECT 1
				FROM company AS c
                WHERE c.id = transaction.company_id
                AND c.country = "Germany"
                )
	AND declined = 0
;


/* CON JOIN
Muestra todas las transacciones realizadas por empresas de Alemania
SELECT
	t.id,
    c.id,
    c.company_name,
    c.country
FROM transaction AS t
INNER JOIN company AS c
	ON t.company_id = c.id
WHERE c.country = "Germany";
*/

-- b) Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones
SELECT c.company_name AS companies_above_avg_transaction_amount
FROM company AS c
INNER JOIN transaction AS t
	ON c.id = t.company_id
WHERE t.amount > (SELECT AVG(amount) AS avg_amount -- calculo la media de todas las transacciones
					FROM transaction
                    WHERE declined = 0
					)
	AND declined = 0
;

-- c) Eliminarán del sistema las empresas que carecen de transacciones registradas, entrega el listado de estas empresas
-- OPCION 1 - con IN
SELECT company_name AS company_without_transactions
FROM company
WHERE id NOT IN (
			SELECT company_id
			FROM transaction
            )
;


-- c) Eliminarán del sistema las empresas que carecen de transacciones registradas, entrega el listado de estas empresas
-- OPCION 2 - con WHERE EXISTS
SELECT c.company_name AS company_without_transactions
FROM company AS c
WHERE NOT EXISTS (SELECT 1
					FROM transaction AS t
                    WHERE t.company_id = c.id
                    )
;


-- NIVEL 2
-- Ejercicio 1
-- Identifica los cinco días que se generó la mayor cantidad de ingresos en la empresa por ventas.
-- Muestra la fecha de cada transacción junto con el total de las ventas.
SELECT
	CAST(timestamp AS DATE) AS transaction_date, -- opcion sin CAST:  DATE(timestamp) AS date,
    SUM(amount) AS sales
FROM transaction
WHERE declined = 0
GROUP BY transaction_date
ORDER BY sales DESC
LIMIT 5;
    
-- Ejercicio 2
-- ¿Cuál es la media de ventas por país? Presenta los resultados ordenados de mayor a menor medio
SELECT
	c.country,
    AVG(t.amount) AS avg_sales
FROM company AS c
INNER JOIN transaction AS t
	ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY c.country
ORDER BY avg_sales DESC;


/*Ejercicio 3
En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia
a la compañía “Non Institute”.
Para ello, te piden la lista de todas las transacciones realizadas por empresas
que están ubicadas en el mismo país que esta compañía.
*/

-- *Ejercicio 3 - Muestra el listado aplicando JOIN y subconsultas
-- OPCION 1 - con IN
SELECT t.*
FROM transaction AS t
INNER JOIN company AS c
	ON c.id = t.company_id
WHERE c.country IN (SELECT country
					FROM company
					WHERE company_name = "Non Institute"
                    )
	AND t.declined = 0
;

-- *Ejercicio 3 - Muestra el listado aplicando JOIN y subconsultas
-- OPCION 2 - con WHERE EXISTS
SELECT t.*
FROM transaction AS t
INNER JOIN company AS c
	ON t.company_id = c.id
WHERE EXISTS(SELECT 1
			FROM company AS cc
            WHERE c.country = cc.country
				AND cc.company_name = "Non Institute"
			)
	AND c.company_name <> "Non Institute"
    AND t.declined = 0
;




-- Muestra el listado aplicando solo subconsultas
SELECT t.*
FROM transaction AS t
WHERE t.company_id IN (SELECT c.id
						FROM company AS c
                        WHERE c.country IN (SELECT c.country
											FROM company AS c
                                            WHERE c.company_name = "Non Institute"
                                            )
						)
	AND declined = 0
;


-- NIVEL 3
-- Ejercicio 1
-- Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones
-- con un valor comprendido entre 350 y 400 euros y en alguna de estas fechas:
-- 29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024. Ordena los resultados de mayor a menor cantidad.
SELECT
	c.company_name,
    c.phone,
    c.country,
   CAST(t.timestamp AS DATE) AS date,
    t.amount
FROM company As c
INNER JOIN transaction AS t
	ON c.id = t.company_id
WHERE t.amount BETWEEN 350 AND 400
	AND CAST(t.timestamp AS DATE) IN ("2015-04-29", "2018-07-20", "2024-03-13")
ORDER BY amount DESC;

-- Ejercicio 2
-- Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera,
-- por lo que te piden la información sobre la cantidad de transacciones que realizan las empresas,
-- pero el departamento de recursos humanos es exigente y quiere un listado de las empresas en las que especifiques
-- si tienen más de 400 transacciones o menos.
SELECT
	c.id,
    c.company_name,
    (CASE WHEN COUNT(t.id) >= 400 THEN "400 transacciones o mas"
    ELSE "menos de 400 transacciones"
    END) AS n_transacciones
FROM company AS c
INNER JOIN transaction AS t
	ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY c.id, c.company_name
ORDER BY n_transacciones DESC; -- no obligatorio