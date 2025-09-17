USE transactions;

SELECT *
FROM company
LIMIT 5;

SELECT *
FROM transaction
LIMIT 5;

-- Exercici 2
-- CON JOIN
-- a) Listado de los países que están generando ventas
SELECT c.country
FROM company AS c
INNER JOIN transaction AS t
	ON c.id = t.company_id
WHERE declined = 0 -- que están generando ventas (tienen que ser "declined" = 0 = false)
GROUP BY c.country
ORDER BY country ASC; -- añadido para una mayor legibilidad

-- b) Desde cuántos países se generan las ventas
SELECT COUNT(DISTINCT country) AS n_paises
FROM company AS c
INNER JOIN transaction AS t
	ON c.id = t.company_id
WHERE t.declined = 0; -- países que generan ventas

-- c) Identifica a la compañía con la mayor media de ventas
SELECT
	c.id,
	c.company_name,
	AVG(t.amount) AS avg_amount
FROM company AS c
INNER JOIN transaction AS t
	ON c.id = t.company_id
GROUP BY 
	c.id,
	c.company_name
ORDER BY avg_amount DESC
LIMIT 1;

-- Exercici 3
-- SIN JOIN
-- a) Muestra todas las transacciones realizadas por empresas de Alemania
SELECT *
FROM transaction
WHERE company_id IN (
	SELECT
		id
	FROM company
	WHERE country = "Germany"
    )
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
SELECT
	DISTINCT company_id
FROM transaction
WHERE amount > (
		SELECT AVG(amount) AS avg_amount -- calculo la media de todas las transacciones
		FROM transaction
        )
;

-- c) Eliminarán del sistema las empresas que carecen de transacciones registradas, entrega el listado de estas empresas
SELECT id AS empresas_sin_transacciones
FROM company
WHERE id NOT IN (
			SELECT
				DISTINCT company_id
			FROM transaction
            )
;

-- Nivel 2
-- Ejercicio 1
-- Identifica los cinco días que se generó la mayor cantidad de ingresos en la empresa por ventas.
-- Muestra la fecha de cada transacción junto con el total de las ventas.
SELECT
	CAST(t.timestamp AS DATE) AS date,
    SUM(t.amount) AS ingresos
FROM company AS c
INNER JOIN transaction AS t
	ON c.id = t.company_id
GROUP BY t.timestamp
ORDER BY ingresos DESC
LIMIT 5;

-- Ejercicio 2
-- ¿Cuál es la media de ventas por país? Presenta los resultados ordenados de mayor a menor medio
SELECT
	c.country,
    AVG(t.amount) AS avg_ingresos
FROM company AS c
INNER JOIN transaction AS t
	ON c.id = t.company_id
GROUP BY country
ORDER BY avg_ingresos DESC;

/*Ejercicio 3
En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia
a la compañía “Non Institute”.
Para ello, te piden la lista de todas las transacciones realizadas por empresas
que están ubicadas en el mismo país que esta compañía.
*/

-- Muestra el listado aplicando JOIN y subconsultas
SELECT t.*
FROM transaction AS t
INNER JOIN company AS c
	ON c.id = t.company_id
WHERE c.country IN (SELECT country
					FROM company
					WHERE company_name = "Non Institute"
                    )
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
;


-- Nivel 3
-- Ejercicio 1
-- Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones
-- con un valor comprendido entre 350 y 400 euros y en alguna de estas fechas:
-- 29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024.
-- Ordena los resultados de mayor a menor cantidad.
SELECT
	c.company_name,
    c.phone,
    c.country,
   CAST(t.timestamp AS DATE) AS date,
    t.amount
FROM company As c
INNER JOIN transaction AS t
	ON c.id = t.company_id
WHERE t.amount >= 350 AND t.amount <= 400
HAVING date IN ("2015-04-29", "2018-07-20", "2024-03-13")
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
GROUP BY c.id, c.company_name
ORDER BY n_transacciones DESC; -- no obligatorio










