-- ============================================================
-- SCRIPT COMPLETO: P2PWalletDB
-- Incluye: CREATE DATABASE + TABLAS + DATOS REFERENCIALES + ADMIN
-- ============================================================

-- ============================================================
-- 1. CREAR BASE DE DATOS
-- ============================================================
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'P2PWalletDB')
BEGIN
    CREATE DATABASE P2PWalletDB;
END
GO

USE P2PWalletDB;
GO

-- ============================================================
-- 2. TABLAS REFERENCIALES (sin dependencias)
-- ============================================================

-- 2.1 Roles
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Roles')
BEGIN
    CREATE TABLE Roles (
        IdRol       INT          NOT NULL IDENTITY(1,1),
        Nombre      VARCHAR(50)  NOT NULL,
        Descripcion VARCHAR(200) NULL,
        CONSTRAINT PK_Roles PRIMARY KEY (IdRol),
        CONSTRAINT UQ_Roles_Nombre UNIQUE (Nombre)
    );
END
GO

-- 2.2 Monedas
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Monedas')
BEGIN
    CREATE TABLE Monedas (
        IdMoneda INT         NOT NULL IDENTITY(1,1),
        Codigo   VARCHAR(5)  NULL,
        Nombre   VARCHAR(50) NULL,
        CONSTRAINT PK_Monedas PRIMARY KEY (IdMoneda),
        CONSTRAINT UQ_Monedas_Codigo UNIQUE (Codigo)
    );
END
GO

-- 2.3 MetodosPago
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MetodosPago')
BEGIN
    CREATE TABLE MetodosPago (
        IdMetodoPago INT         NOT NULL IDENTITY(1,1),
        Nombre       VARCHAR(50) NOT NULL,
        CONSTRAINT PK_MetodosPago PRIMARY KEY (IdMetodoPago),
        CONSTRAINT UQ_MetodosPago_Nombre UNIQUE (Nombre)
    );
END
GO

-- 2.4 Bancos
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Bancos')
BEGIN
    CREATE TABLE Bancos (
        IdBanco INT          NOT NULL IDENTITY(1,1),
        Nombre  VARCHAR(100) NOT NULL,
        CONSTRAINT PK_Bancos PRIMARY KEY (IdBanco),
        CONSTRAINT UQ_Bancos_Nombre UNIQUE (Nombre)
    );
END
GO

-- ============================================================
-- 3. TABLAS PRINCIPALES
-- ============================================================

-- 3.1 Usuarios
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Usuarios')
BEGIN
    CREATE TABLE Usuarios (
        IdUsuario           BIGINT        NOT NULL IDENTITY(1,1),
        IdRol               INT           NOT NULL,
        NombreCompleto      VARCHAR(150)  NOT NULL,
        Correo              VARCHAR(150)  NOT NULL,
        Telefono            VARCHAR(20)   NOT NULL,
        DocumentoIdentidad  VARCHAR(20)   NOT NULL,
        PasswordHash        VARCHAR(255)  NOT NULL,
        Reputacion          DECIMAL(3,2)  NULL DEFAULT 5.00,
        TotalCalificaciones INT           NULL DEFAULT 0,
        Estado              VARCHAR(20)   NULL DEFAULT 'ACTIVO',
        FechaRegistro       DATETIME      NULL DEFAULT GETDATE(),
        ResetToken          NVARCHAR(255) NULL,
        ResetTokenExpiry    DATETIME2      NULL,
        FotoPerfil          NVARCHAR(500) NULL,
        CONSTRAINT PK_Usuarios PRIMARY KEY (IdUsuario),
        CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (IdRol) REFERENCES Roles(IdRol),
        CONSTRAINT UQ_Usuarios_Correo UNIQUE (Correo),
        CONSTRAINT UQ_Usuarios_DocumentoIdentidad UNIQUE (DocumentoIdentidad)
    );

    CREATE INDEX IX_Usuarios_Correo ON Usuarios(Correo);
END
GO

-- 3.2 Wallets
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Wallets')
BEGIN
    CREATE TABLE Wallets (
        IdWallet     BIGINT   NOT NULL IDENTITY(1,1),
        IdUsuario    BIGINT   NOT NULL,
        FechaCreacion DATETIME NULL DEFAULT GETDATE(),
        CONSTRAINT PK_Wallets PRIMARY KEY (IdWallet),
        CONSTRAINT FK_Wallets_Usuarios FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario),
        CONSTRAINT UQ_Wallets_IdUsuario UNIQUE (IdUsuario)
    );
END
GO

-- 3.3 WalletSaldos
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'WalletSaldos')
BEGIN
    CREATE TABLE WalletSaldos (
        IdSaldo         BIGINT  NOT NULL IDENTITY(1,1),
        IdWallet        BIGINT  NOT NULL,
        IdMoneda        INT     NOT NULL,
        SaldoDisponible DECIMAL NOT NULL DEFAULT 0,
        SaldoRetenido   DECIMAL NOT NULL DEFAULT 0,
        CONSTRAINT PK_WalletSaldos PRIMARY KEY (IdSaldo),
        CONSTRAINT FK_WalletSaldos_Wallets FOREIGN KEY (IdWallet) REFERENCES Wallets(IdWallet),
        CONSTRAINT FK_WalletSaldos_Monedas FOREIGN KEY (IdMoneda) REFERENCES Monedas(IdMoneda),
        CONSTRAINT UQ_WalletSaldos_WalletMoneda UNIQUE (IdWallet, IdMoneda)
    );
END
GO

-- 3.4 Ofertas
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Ofertas')
BEGIN
    CREATE TABLE Ofertas (
        IdOferta       BIGINT        NOT NULL IDENTITY(1,1),
        IdUsuario      BIGINT        NOT NULL,
        TipoOperacion  VARCHAR(10)   NULL,
        MonedaEntrega  INT           NOT NULL,
        MonedaRecibe   INT           NOT NULL,
        TasaCambio     DECIMAL(18,2) NOT NULL,
        MontoOfertado  DECIMAL(18,2) NOT NULL,
        MontoMinimo    DECIMAL(18,2) NOT NULL,
        Estado         VARCHAR(30)   NULL DEFAULT 'ACTIVA',
        FechaPublicacion DATETIME    NULL DEFAULT GETDATE(),
        CONSTRAINT PK_Ofertas PRIMARY KEY (IdOferta),
        CONSTRAINT FK_Ofertas_Usuarios FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario),
        CONSTRAINT FK_Ofertas_MonedaEntrega FOREIGN KEY (MonedaEntrega) REFERENCES Monedas(IdMoneda),
        CONSTRAINT FK_Ofertas_MonedaRecibe FOREIGN KEY (MonedaRecibe) REFERENCES Monedas(IdMoneda)
    );

    CREATE INDEX IX_Ofertas_Estado ON Ofertas(Estado);
END
GO

-- 3.5 OfertaMetodoPago (relacion M:M Ofertas <-> MetodosPago)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OfertaMetodoPago')
BEGIN
    CREATE TABLE OfertaMetodoPago (
        IdOferta      BIGINT NOT NULL,
        IdMetodoPago  INT    NOT NULL,
        CONSTRAINT PK_OfertaMetodoPago PRIMARY KEY (IdOferta, IdMetodoPago),
        CONSTRAINT FK_OfertaMetodoPago_Ofertas FOREIGN KEY (IdOferta) REFERENCES Ofertas(IdOferta),
        CONSTRAINT FK_OfertaMetodoPago_MetodosPago FOREIGN KEY (IdMetodoPago) REFERENCES MetodosPago(IdMetodoPago)
    );
END
GO

-- 3.6 Transacciones
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Transacciones')
BEGIN
    CREATE TABLE Transacciones (
        IdTransaccion  BIGINT        NOT NULL IDENTITY(1,1),
        Codigo         VARCHAR(50)   NULL,
        IdOferta       BIGINT        NOT NULL,
        CompradorId    BIGINT        NOT NULL,
        VendedorId     BIGINT        NOT NULL,
        IdMetodoPago   INT           NOT NULL,
        MontoOperacion DECIMAL(18,2) NULL,
        TotalPagar     DECIMAL(18,2) NULL,
        Estado         VARCHAR(40)   NULL DEFAULT 'PENDIENTE_PAGO',
        FechaInicio    DATETIME      NULL DEFAULT GETDATE(),
        FechaFin       DATETIME      NULL,
        RutaComprobante NVARCHAR(500) NULL,
        CONSTRAINT PK_Transacciones PRIMARY KEY (IdTransaccion),
        CONSTRAINT FK_Transacciones_Ofertas FOREIGN KEY (IdOferta) REFERENCES Ofertas(IdOferta),
        CONSTRAINT FK_Transacciones_Comprador FOREIGN KEY (CompradorId) REFERENCES Usuarios(IdUsuario),
        CONSTRAINT FK_Transacciones_Vendedor FOREIGN KEY (VendedorId) REFERENCES Usuarios(IdUsuario),
        CONSTRAINT FK_Transacciones_MetodosPago FOREIGN KEY (IdMetodoPago) REFERENCES MetodosPago(IdMetodoPago),
        CONSTRAINT UQ_Transacciones_Codigo UNIQUE (Codigo)
    );

    CREATE INDEX IX_Transacciones_Estado ON Transacciones(Estado);
END
GO

-- 3.7 MovimientosWallet
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MovimientosWallet')
BEGIN
    CREATE TABLE MovimientosWallet (
        IdMovimiento    BIGINT        NOT NULL IDENTITY(1,1),
        IdWallet        BIGINT        NOT NULL,
        IdMoneda        INT           NOT NULL,
        TipoOperacion   VARCHAR(50)   NULL,
        Monto           DECIMAL(18,2) NULL,
        Resultado       VARCHAR(20)   NULL,
        ReferenciaTipo  VARCHAR(50)   NULL,
        ReferenciaId    BIGINT        NULL,
        FechaMovimiento DATETIME      NULL DEFAULT GETDATE(),
        CONSTRAINT PK_MovimientosWallet PRIMARY KEY (IdMovimiento),
        CONSTRAINT FK_MovimientosWallet_Wallets FOREIGN KEY (IdWallet) REFERENCES Wallets(IdWallet),
        CONSTRAINT FK_MovimientosWallet_Monedas FOREIGN KEY (IdMoneda) REFERENCES Monedas(IdMoneda)
    );
END
GO

-- 3.8 Calificaciones
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Calificaciones')
BEGIN
    CREATE TABLE Calificaciones (
        IdCalificacion     BIGINT       NOT NULL IDENTITY(1,1),
        IdTransaccion      BIGINT       NOT NULL,
        UsuarioCalificador BIGINT       NOT NULL,
        UsuarioCalificado  BIGINT       NOT NULL,
        Puntuacion         INT          NULL,
        Comentario         VARCHAR(500) NULL,
        FechaCalificacion  DATETIME     NULL DEFAULT GETDATE(),
        CONSTRAINT PK_Calificaciones PRIMARY KEY (IdCalificacion),
        CONSTRAINT FK_Calificaciones_Transacciones FOREIGN KEY (IdTransaccion) REFERENCES Transacciones(IdTransaccion)
    );
END
GO

-- 3.9 ComprobantesPago
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ComprobantesPago')
BEGIN
    CREATE TABLE ComprobantesPago (
        IdComprobante  BIGINT        NOT NULL IDENTITY(1,1),
        IdTransaccion  BIGINT        NOT NULL,
        NombreArchivo  VARCHAR(250)  NULL,
        RutaArchivo    VARCHAR(500)  NULL,
        FechaSubida    DATETIME      NULL DEFAULT GETDATE(),
        CONSTRAINT PK_ComprobantesPago PRIMARY KEY (IdComprobante),
        CONSTRAINT FK_ComprobantesPago_Transacciones FOREIGN KEY (IdTransaccion) REFERENCES Transacciones(IdTransaccion)
    );
END
GO

-- 3.10 Disputas
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Disputas')
BEGIN
    CREATE TABLE Disputas (
        IdDisputa      BIGINT        NOT NULL IDENTITY(1,1),
        IdTransaccion  BIGINT        NOT NULL,
        UsuarioReporta BIGINT        NOT NULL,
        Motivo         VARCHAR(100)  NULL,
        Descripcion    VARCHAR(MAX)  NULL,
        Estado         VARCHAR(30)   NULL DEFAULT 'ABIERTA',
        FechaCreacion  DATETIME      NULL DEFAULT GETDATE(),
        CONSTRAINT PK_Disputas PRIMARY KEY (IdDisputa),
        CONSTRAINT FK_Disputas_Transacciones FOREIGN KEY (IdTransaccion) REFERENCES Transacciones(IdTransaccion),
        CONSTRAINT FK_Disputas_UsuarioReporta FOREIGN KEY (UsuarioReporta) REFERENCES Usuarios(IdUsuario)
    );
END
GO

-- 3.11 EvidenciasDisputa
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EvidenciasDisputa')
BEGIN
    CREATE TABLE EvidenciasDisputa (
        IdEvidencia BIGINT        NOT NULL IDENTITY(1,1),
        IdDisputa   BIGINT        NOT NULL,
        Archivo     VARCHAR(500)  NULL,
        CONSTRAINT PK_EvidenciasDisputa PRIMARY KEY (IdEvidencia),
        CONSTRAINT FK_EvidenciasDisputa_Disputas FOREIGN KEY (IdDisputa) REFERENCES Disputas(IdDisputa)
    );
END
GO

-- 3.12 ResolucionesDisputa
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ResolucionesDisputa')
BEGIN
    CREATE TABLE ResolucionesDisputa (
        IdResolucion    BIGINT        NOT NULL IDENTITY(1,1),
        IdDisputa       BIGINT        NOT NULL,
        AdministradorId BIGINT        NOT NULL,
        Decision        VARCHAR(50)   NULL,
        Observacion     VARCHAR(MAX)  NULL,
        FechaResolucion DATETIME      NULL DEFAULT GETDATE(),
        CONSTRAINT PK_ResolucionesDisputa PRIMARY KEY (IdResolucion),
        CONSTRAINT FK_ResolucionesDisputa_Disputas FOREIGN KEY (IdDisputa) REFERENCES Disputas(IdDisputa),
        CONSTRAINT FK_ResolucionesDisputa_Administrador FOREIGN KEY (AdministradorId) REFERENCES Usuarios(IdUsuario)
    );
END
GO

-- 3.13 Retiros
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Retiros')
BEGIN
    CREATE TABLE Retiros (
        IdRetiro    BIGINT        NOT NULL IDENTITY(1,1),
        IdUsuario   BIGINT        NOT NULL,
        IdMoneda    INT           NOT NULL,
        Monto       DECIMAL(18,2) NOT NULL,
        Estado      VARCHAR(20)   NULL DEFAULT 'COMPLETADO',
        FechaRetiro DATETIME      NULL DEFAULT GETDATE(),
        CONSTRAINT PK_Retiros PRIMARY KEY (IdRetiro),
        CONSTRAINT FK_Retiros_Usuarios FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario),
        CONSTRAINT FK_Retiros_Monedas FOREIGN KEY (IdMoneda) REFERENCES Monedas(IdMoneda)
    );
END
GO

-- 3.14 Recargas
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Recargas')
BEGIN
    CREATE TABLE Recargas (
        IdRecarga    BIGINT        NOT NULL IDENTITY(1,1),
        IdUsuario    BIGINT        NOT NULL,
        IdMoneda     INT           NOT NULL,
        Monto        DECIMAL(18,2) NOT NULL,
        Estado       VARCHAR(20)   NULL DEFAULT 'COMPLETADA',
        FechaRecarga DATETIME      NULL DEFAULT GETDATE(),
        CONSTRAINT PK_Recargas PRIMARY KEY (IdRecarga),
        CONSTRAINT FK_Recargas_Usuarios FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario),
        CONSTRAINT FK_Recargas_Monedas FOREIGN KEY (IdMoneda) REFERENCES Monedas(IdMoneda)
    );
END
GO

-- 3.15 DatosPagoUsuario
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DatosPagoUsuario')
BEGIN
    CREATE TABLE DatosPagoUsuario (
        IdDatoPago    BIGINT       NOT NULL IDENTITY(1,1),
        IdUsuario     BIGINT       NOT NULL,
        Yape          VARCHAR(20)  NULL,
        Plin          VARCHAR(20)  NULL,
        IdBanco       INT          NULL,
        NumeroCuenta  VARCHAR(30)  NULL,
        CCI           VARCHAR(30)  NULL,
        CONSTRAINT PK_DatosPagoUsuario PRIMARY KEY (IdDatoPago),
        CONSTRAINT FK_DatosPagoUsuario_Usuarios FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario),
        CONSTRAINT FK_DatosPagoUsuario_Bancos FOREIGN KEY (IdBanco) REFERENCES Bancos(IdBanco)
    );
END
GO

-- 3.16 Notificaciones
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Notificaciones')
BEGIN
    CREATE TABLE Notificaciones (
        IdNotificacion  BIGINT        NOT NULL IDENTITY(1,1),
        IdUsuario       BIGINT        NULL,
        Titulo          VARCHAR(200)  NULL,
        Mensaje         VARCHAR(MAX)  NULL,
        Leido           BIT           NULL DEFAULT 0,
        Fecha           DATETIME      NULL DEFAULT GETDATE(),
        CONSTRAINT PK_Notificaciones PRIMARY KEY (IdNotificacion),
        CONSTRAINT FK_Notificaciones_Usuarios FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario)
    );
END
GO

-- 3.17 Feedback
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Feedback')
BEGIN
    CREATE TABLE Feedback (
        IdFeedback     BIGINT        NOT NULL IDENTITY(1,1),
        IdUsuario      BIGINT        NOT NULL,
        Tipo           VARCHAR(20)   NOT NULL,
        Titulo         VARCHAR(200)  NOT NULL,
        Descripcion    VARCHAR(2000) NOT NULL,
        FechaCreacion  DATETIME      NOT NULL DEFAULT GETDATE(),
        Estado         VARCHAR(20)   NOT NULL DEFAULT 'PENDIENTE',
        RespuestaAdmin VARCHAR(2000) NULL,
        CONSTRAINT PK_Feedback PRIMARY KEY (IdFeedback),
        CONSTRAINT FK_Feedback_Usuarios FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario)
    );
END
GO

-- 3.18 MatchingOfertas
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MatchingOfertas')
BEGIN
    CREATE TABLE MatchingOfertas (
        IdMatching        BIGINT NOT NULL IDENTITY(1,1),
        OfertaBase        BIGINT NULL,
        OfertaCoincidente BIGINT NULL,
        Compatibilidad    DECIMAL(5,2) NULL,
        Fecha             DATETIME NULL DEFAULT GETDATE(),
        CONSTRAINT PK_MatchingOfertas PRIMARY KEY (IdMatching),
        CONSTRAINT FK_MatchingOfertas_OfertaBase FOREIGN KEY (OfertaBase) REFERENCES Ofertas(IdOferta),
        CONSTRAINT FK_MatchingOfertas_OfertaCoincidente FOREIGN KEY (OfertaCoincidente) REFERENCES Ofertas(IdOferta)
    );
END
GO

-- 3.19 Retenciones
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Retenciones')
BEGIN
    CREATE TABLE Retenciones (
        IdRetencion    BIGINT        NOT NULL IDENTITY(1,1),
        IdOferta       BIGINT        NULL,
        IdTransaccion  BIGINT        NULL,
        Monto          DECIMAL(18,2) NULL,
        Estado         VARCHAR(20)   NULL,
        Fecha          DATETIME      NULL DEFAULT GETDATE(),
        CONSTRAINT PK_Retenciones PRIMARY KEY (IdRetencion),
        CONSTRAINT FK_Retenciones_Oferta FOREIGN KEY (IdOferta) REFERENCES Ofertas(IdOferta),
        CONSTRAINT FK_Retenciones_Transaccion FOREIGN KEY (IdTransaccion) REFERENCES Transacciones(IdTransaccion)
    );
END
GO

-- 3.20 ReportesGenerados
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ReportesGenerados')
BEGIN
    CREATE TABLE ReportesGenerados (
        IdReporte        BIGINT   NOT NULL IDENTITY(1,1),
        AdministradorId  BIGINT   NULL,
        TipoReporte      VARCHAR(50) NULL,
        FechaGeneracion  DATETIME NULL DEFAULT GETDATE(),
        CONSTRAINT PK_ReportesGenerados PRIMARY KEY (IdReporte),
        CONSTRAINT FK_ReportesGenerados_Usuarios FOREIGN KEY (AdministradorId) REFERENCES Usuarios(IdUsuario)
    );
END
GO

-- 3.21 Auditoria
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Auditoria')
BEGIN
    CREATE TABLE Auditoria (
        IdAuditoria    BIGINT       NOT NULL IDENTITY(1,1),
        UsuarioId      BIGINT       NULL,
        Accion         VARCHAR(200) NULL,
        TablaAfectada  VARCHAR(100) NULL,
        RegistroId     BIGINT       NULL,
        Fecha          DATETIME     NULL DEFAULT GETDATE(),
        CONSTRAINT PK_Auditoria PRIMARY KEY (IdAuditoria)
    );
END
GO

-- ============================================================
-- 4. DATOS REFERENCIALES
-- ============================================================

-- 4.1 Roles
IF NOT EXISTS (SELECT 1 FROM Roles)
BEGIN
    INSERT INTO Roles (Nombre, Descripcion)
    VALUES
        ('USER',  'Comprador/Vendedor'),
        ('ADMIN', 'Administrador');
END
GO

-- 4.2 Monedas
IF NOT EXISTS (SELECT 1 FROM Monedas)
BEGIN
    INSERT INTO Monedas (Codigo, Nombre)
    VALUES
        ('PEN', 'Sol'),
        ('USD', 'Dolar'),
        ('EUR', 'Euro'),
        ('JPY', 'Yen Japones'),
        ('GBP', 'Libra Esterlina');
END
GO

-- 4.3 MetodosPago
IF NOT EXISTS (SELECT 1 FROM MetodosPago)
BEGIN
    INSERT INTO MetodosPago (Nombre)
    VALUES
        ('YAPE'),
        ('PLIN'),
        ('TRANSFERENCIA'),
        ('WALLET_INTERNA');
END
GO

-- 4.4 Bancos
IF NOT EXISTS (SELECT 1 FROM Bancos)
BEGIN
    INSERT INTO Bancos (Nombre)
    VALUES
        ('BCP'),
        ('BBVA'),
        ('INTERBANK'),
        ('SCOTIABANK');
END
GO

-- ============================================================
-- 5. USUARIO ADMINISTRADOR
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE Correo = 'admin@exchange-pro.com')
BEGIN
    -- Insertar admin
    INSERT INTO Usuarios (IdRol, NombreCompleto, Correo, Telefono, DocumentoIdentidad, PasswordHash)
    VALUES (2, 'Admin', 'admin@exchange-pro.com', '999999999', '00000000', '$2a$11$KHz7c3tYzCwKY5bEcc4Bk.7W.VlZbJvBa0aBVL9VggOGhzbHWf9.O');

    -- Crear wallet para admin
    INSERT INTO Wallets (IdUsuario)
    VALUES (SCOPE_IDENTITY());

    -- Crear saldos para cada moneda
    DECLARE @AdminWalletId BIGINT = (SELECT IdWallet FROM Wallets WHERE IdUsuario = (SELECT IdUsuario FROM Usuarios WHERE Correo = 'admin@exchange-pro.com'));

    INSERT INTO WalletSaldos (IdWallet, IdMoneda, SaldoDisponible, SaldoRetenido)
    SELECT @AdminWalletId, IdMoneda, 0, 0 FROM Monedas;
END
GO

PRINT '============================================';
PRINT 'SCRIPT COMPLETO EJECUTADO EXITOSAMENTE';
PRINT '============================================';
PRINT 'Usuario admin: admin@exchange-pro.com / Admin123';
PRINT '============================================';
GO
