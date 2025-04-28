SELECT * FROM movies;
-- Añadir una nueva columna para el título limpio
ALTER TABLE movies
ADD COLUMN clean_title VARCHAR(255);

-- Añadir una nueva columna para el año
ALTER TABLE movies
ADD COLUMN year INT;

-- Actualizar la tabla para llenar las nuevas columnas con los datos limpios
UPDATE movies
SET year = CAST(SUBSTRING(title, LENGTH(title) - 4, 4) AS INT), -- Extraer el año
    clean_title = TRIM(SUBSTRING(title, 1, LENGTH(title) - 6)) -- Extraer el título limpio
WHERE CHARINDEX('(', title) > 0 AND CHARINDEX(')', title, CHARINDEX('(', title)) > 0;

-- Visualizar el resultado

SELECT * FROM movies;

--- ver tabla ratings

SELECT * FROM ratings;

-- Crear tabla con usuarios que han calificado más de 20 y menos de 1000 películas
DROP TABLE IF EXISTS usuarios_sel;

CREATE TABLE usuarios_sel AS
SELECT userId AS user_id, COUNT(*) AS cnt_rat
FROM ratings
GROUP BY userId
HAVING cnt_rat <= 1000
ORDER BY cnt_rat DESC;

-- Crear tabla con películas calificadas por más de 5 usuarios
DROP TABLE IF EXISTS movies_sel;

CREATE TABLE movies_sel AS
SELECT movieId, COUNT(*) AS cnt_rat
FROM ratings
GROUP BY movieId
HAVING cnt_rat > 5
ORDER BY cnt_rat DESC;

-- Crear tablas filtradas de ratings, usuarios y películas
DROP TABLE IF EXISTS ratings_final;

CREATE TABLE ratings_final AS
SELECT a.userId AS user_id,
       a.movieId AS movie_id,
       a.rating AS rating
FROM ratings a
INNER JOIN movies_sel b ON a.movieId = b.movieId
INNER JOIN usuarios_sel c ON a.userId = c.user_id;

-- Crear tabla completa
DROP TABLE IF EXISTS full_ratings;

CREATE TABLE full_ratings AS
SELECT a.*,
       c.title AS movie_title,
       c.genres AS movie_genres,
       c.title AS movie_clean_title,
       c.year AS movie_year
FROM ratings_final a
INNER JOIN movies c ON a.movie_id = c.movieId;

SELECT * FROM full_ratings;

-- Agregar columna con formato de fecha a la tabla full_ratings
ALTER TABLE full_ratings
ADD COLUMN fecha_nueva TEXT;

-- Actualizar la nueva columna con el formato de fecha
UPDATE full_ratings
SET fecha_nueva = (
    SELECT STRFTIME('%Y-%m-%d', timestamp, 'unixepoch')
    FROM ratings
    WHERE userId = full_ratings.user_id AND movieId = full_ratings.movie_id
    LIMIT 1
);
-- Mostrar resultados
SELECT * FROM full_ratings;