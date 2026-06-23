-- Agregar columnas a Recargas
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Recargas') AND name = 'MetodoPago')
BEGIN
    ALTER TABLE Recargas ADD MetodoPago VARCHAR(100) NULL;
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Recargas') AND name = 'NumeroReferencia')
BEGIN
    ALTER TABLE Recargas ADD NumeroReferencia VARCHAR(200) NULL;
END
GO

-- Agregar columnas a Retiros
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Retiros') AND name = 'MetodoRetiro')
BEGIN
    ALTER TABLE Retiros ADD MetodoRetiro VARCHAR(100) NULL;
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Retiros') AND name = 'CuentaDestino')
BEGIN
    ALTER TABLE Retiros ADD CuentaDestino VARCHAR(200) NULL;
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Retiros') AND name = 'Titular')
BEGIN
    ALTER TABLE Retiros ADD Titular VARCHAR(200) NULL;
END
GO

PRINT 'Columnas agregadas correctamente a Recargas y Retiros.';
