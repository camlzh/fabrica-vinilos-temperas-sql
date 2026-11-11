-- =============================================================================
-- ARCHIVO 03: PRUEBAS DE OPERACIÓN Y RESTRICCIONES (DML)
-- PROYECTO: FÁBRICA DE VINILOS Y TÉMPERAS
-- =============================================================================

-- FASE 1: ACTUALIZACIONES VÁLIDAS (UPDATE)
-- Simula un ajuste técnico en el día a día. La base de datos lo permitirá 
-- siempre y cuando el nuevo valor cumpla con las reglas (ej: capacidad > 0).
UPDATE linea_produccion 
SET capacidad_nominal_hora = 1250.00 
WHERE codigo_linea = 'Vinilos_1';


-- FASE 2: ELIMINACIONES VÁLIDAS (DELETE)
-- Al borrar un turno principal, el motor eliminará en cascada todos sus detalles 
-- (producción por hora y paros registrados) gracias a la regla "ON DELETE CASCADE" 
-- que configuramos en el esquema original para no dejar datos huérfanos.
DELETE FROM registro_orden_turno 
WHERE registro_turno_id = 3;


-- =============================================================================
-- FASE 3: AUDITORÍA Y CONTROL DE ERRORES (PRUEBAS DE RECHAZO)
-- El verdadero poder de una base de datos es evitar que entre "basura".
-- Las siguientes consultas están comentadas. Si quitas los símbolos /* y */ 
-- e intentas ejecutarlas, PostgreSQL las rechazará para proteger tu información.
-- =============================================================================

-- PRUEBA A: Violación de lógica de tiempo y valores negativos (Regla CHECK)
-- Falla por dos razones: la hora de fin (07:30) es ANTERIOR a la hora de inicio (08:00),
-- y el tiempo negativo (-30.00) rompe nuestra restricción de (duracion_minutos > 0).

/*
INSERT INTO registro_paro_detalle (
    registro_turno_id, subcodigo_paro_id, hora_inicio_paro, hora_fin_paro, duracion_minutos
)
VALUES (
    4, 1, '2026-05-10 08:00:00', '2026-05-10 07:30:00', -30.00
);
*/


-- PRUEBA B: Violación de Integridad Referencial (Llaves Foráneas)
-- Falla porque intenta asignar la producción a la línea '999', la cual NO EXISTE 
-- en nuestro catálogo de "linea_produccion". 

/*
INSERT INTO registro_orden_turno (
    linea_id, turno_id, operaria_id, fecha
)
VALUES (
    999, 1, 1, '2026-05-11'
);
*/