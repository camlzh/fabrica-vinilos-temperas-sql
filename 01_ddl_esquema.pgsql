-- =============================================================================
-- ARCHIVO 01: ESTRUCTURA DE LA BASE DE DATOS (DDL)
-- PROYECTO: FÁBRICA DE VINILOS Y TÉMPERAS
-- =============================================================================

-- FASE 0: LIMPIEZA PREVIA
DROP TABLE IF EXISTS registro_paro_detalle CASCADE;
DROP TABLE IF EXISTS registro_produccion_hora CASCADE;
DROP TABLE IF EXISTS registro_orden_turno CASCADE;
DROP TABLE IF EXISTS subcodigo_paro CASCADE;
DROP TABLE IF EXISTS codigo_paro CASCADE;
DROP TABLE IF EXISTS empleado CASCADE;
DROP TABLE IF EXISTS cargo CASCADE;
DROP TABLE IF EXISTS turno CASCADE;
DROP TABLE IF EXISTS linea_produccion CASCADE;

-- FASE 1: CATÁLOGOS BASE
CREATE TABLE cargo (
    cargo_id SERIAL PRIMARY KEY,
    nombre_cargo VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE linea_produccion (
    linea_id SERIAL PRIMARY KEY,
    codigo_linea VARCHAR(20) NOT NULL UNIQUE,
    descripcion VARCHAR(100),
    capacidad_nominal_hora NUMERIC(10, 2) NOT NULL CHECK (capacidad_nominal_hora > 0)
);

CREATE TABLE turno (
    turno_id SERIAL PRIMARY KEY,
    nombre_turno VARCHAR(20) NOT NULL UNIQUE,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    duracion_horas NUMERIC(4, 2) NOT NULL CHECK (duracion_horas > 0)
);

CREATE TABLE codigo_paro (
    codigo_paro_id SERIAL PRIMARY KEY,
    codigo VARCHAR(10) NOT NULL UNIQUE,
    descripcion VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL
);

-- FASE 2: TABLAS MAESTRAS Y DEPENDIENTES
CREATE TABLE empleado (
    empleado_id SERIAL PRIMARY KEY,
    codigo_empleado VARCHAR(20) NOT NULL UNIQUE,
    nombre_hash VARCHAR(64) NOT NULL,
    cargo_id INT NOT NULL REFERENCES cargo(cargo_id) ON DELETE RESTRICT
);

CREATE TABLE subcodigo_paro (
    subcodigo_paro_id SERIAL PRIMARY KEY,
    codigo_paro_id INT NOT NULL REFERENCES codigo_paro(codigo_paro_id) ON DELETE CASCADE,
    subcodigo VARCHAR(10) NOT NULL UNIQUE,
    descripcion VARCHAR(150) NOT NULL
);

-- FASE 3: OPERACIÓN Y TRANSACCIONES
CREATE TABLE registro_orden_turno (
    registro_turno_id SERIAL PRIMARY KEY,
    linea_id INT NOT NULL REFERENCES linea_produccion(linea_id) ON DELETE RESTRICT,
    turno_id INT NOT NULL REFERENCES turno(turno_id) ON DELETE RESTRICT,
    operaria_id INT NOT NULL REFERENCES empleado(empleado_id) ON DELETE RESTRICT,
    fecha DATE NOT NULL,
    meta_produccion_unidades INT NOT NULL CHECK (meta_produccion_unidades > 0),
    CONSTRAINT uq_linea_turno_fecha UNIQUE (linea_id, turno_id, fecha)
);

CREATE TABLE registro_produccion_hora (
    produccion_hora_id SERIAL PRIMARY KEY,
    registro_turno_id INT NOT NULL REFERENCES registro_orden_turno(registro_turno_id) ON DELETE CASCADE,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    unidades_producidas INT NOT NULL CHECK (unidades_producidas >= 0)
);

CREATE TABLE registro_paro_detalle (
    paro_id SERIAL PRIMARY KEY,
    registro_turno_id INT NOT NULL REFERENCES registro_orden_turno(registro_turno_id) ON DELETE CASCADE,
    subcodigo_paro_id INT NOT NULL REFERENCES subcodigo_paro(subcodigo_paro_id) ON DELETE RESTRICT,
    tecnico_mto_id INT REFERENCES empleado(empleado_id) ON DELETE SET NULL,
    hora_inicio_paro TIMESTAMP NOT NULL,
    hora_fin_paro TIMESTAMP NOT NULL,
    duracion_minutos NUMERIC(8, 2) NOT NULL CHECK (duracion_minutos >= 0),
    observaciones TEXT,
    CONSTRAINT chk_horas_paro CHECK (hora_fin_paro >= hora_inicio_paro)
);

-- FASE 4: ÍNDICES DE RENDIMIENTO
CREATE INDEX idx_orden_turno_fecha ON registro_orden_turno(fecha);
CREATE INDEX idx_paro_detalle_registro ON registro_paro_detalle(registro_turno_id);
CREATE INDEX idx_produccion_hora_registro ON registro_produccion_hora(registro_turno_id);

-- FASE 5: VISTAS DEL NEGOCIO
CREATE VIEW vista_resumen_paros AS
SELECT 
    rpd.paro_id,
    rot.fecha,
    lp.codigo_linea,
    cp.codigo AS codigo_paro,
    cp.descripcion AS categoria_paro,
    sp.subcodigo,
    sp.descripcion AS detalle_paro,
    rpd.duracion_minutos
FROM registro_paro_detalle rpd
JOIN registro_orden_turno rot ON rpd.registro_turno_id = rot.registro_turno_id
JOIN linea_produccion lp ON rot.linea_id = lp.linea_id
JOIN subcodigo_paro sp ON rpd.subcodigo_paro_id = sp.subcodigo_paro_id
JOIN codigo_paro cp ON sp.codigo_paro_id = cp.codigo_paro_id;