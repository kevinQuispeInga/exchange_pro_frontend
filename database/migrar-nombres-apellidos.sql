-- ============================================================
-- MIGRACIÓN: Separar NombreCompleto en Nombres + Apellidos
-- Uso:   Ejecutar en BD existente (P2PWalletDB)
-- ============================================================

-- 1. Agregar columnas Nombres y Apellidos
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Usuarios') AND name = 'Nombres')
BEGIN
    ALTER TABLE Usuarios ADD Nombres VARCHAR(100) NULL;
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Usuarios') AND name = 'Apellidos')
BEGIN
    ALTER TABLE Usuarios ADD Apellidos VARCHAR(100) NULL;
END
GO

-- 2. Poblar desde NombreCompleto (separar por el primer espacio)
UPDATE Usuarios SET
    Nombres = LEFT(NombreCompleto, CHARINDEX(' ', NombreCompleto + ' ') - 1),
    Apellidos = RIGHT(NombreCompleto, LEN(NombreCompleto) - CHARINDEX(' ', NombreCompleto + ' '))
WHERE Nombres IS NULL OR Apellidos IS NULL;
GO

-- 3. Hacer NOT NULL
ALTER TABLE Usuarios ALTER COLUMN Nombres VARCHAR(100) NOT NULL;
ALTER TABLE Usuarios ALTER COLUMN Apellidos VARCHAR(100) NOT NULL;
GO

-- 4. Convertir NombreCompleto en columna calculada
--    (Primero hay que dropear la columna y recrearla como computed)
ALTER TABLE Usuarios DROP COLUMN NombreCompleto;
GO
ALTER TABLE Usuarios ADD NombreCompleto AS (Nombres + ' ' + Apellidos);
GO

PRINT 'Migración completada: Nombres y Apellidos separados correctamente.';
