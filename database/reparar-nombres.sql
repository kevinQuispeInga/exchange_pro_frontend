-- ============================================================
-- REPARACIÓN: Poblar Nombres/Apellidos cuando quedaron NULL
-- ============================================================

-- 1. Ver qué usuarios hay actualmente
SELECT IdUsuario, Correo, Nombres, Apellidos, NombreCompleto
FROM Usuarios;

-- 2. Asignar Nombres/Apellidos provisionales desde el correo
--    (toma el texto antes de @ como nombre, "User" como apellido)
UPDATE Usuarios SET
    Nombres = LEFT(Correo, CHARINDEX('@', Correo) - 1),
    Apellidos = 'User'
WHERE Nombres IS NULL OR Apellidos IS NULL;

-- 3. Reconstruir la columna calculada si hace falta
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('Usuarios')
      AND name = 'NombreCompleto'
      AND is_computed = 0
)
BEGIN
    ALTER TABLE Usuarios DROP COLUMN NombreCompleto;
    ALTER TABLE Usuarios ADD NombreCompleto AS (Nombres + ' ' + Apellidos);
END

-- 4. Verificar resultado
SELECT IdUsuario, Correo, Nombres, Apellidos, NombreCompleto
FROM Usuarios;
