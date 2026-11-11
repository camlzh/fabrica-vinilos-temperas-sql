-- =============================================================================
-- ARCHIVO 04: CONSULTAS ANALÍTICAS Y REPORTES DE NEGOCIO (DQL)
-- PROYECTO: FÁBRICA DE VINILOS Y TÉMPERAS
-- =============================================================================

-- =============================================================================
-- REPORTE 1: COMPARATIVO DE PRODUCTIVIDAD MENSUAL (2025 vs 2026)
-- OBJETIVO: Evaluar la eficiencia de cada línea de producción comparando el 
-- volumen de unidades reales contra la meta planteada mes a mes.
-- =============================================================================

SELECT 
    lp.codigo_linea AS maquina,
    EXTRACT(MONTH FROM rot.fecha)::INT AS mes,
    
    -- Métricas Año 2025
    SUM(CASE WHEN EXTRACT(YEAR FROM rot.fecha) = 2025 THEN rph.unidades_producidas ELSE 0 END) AS prod_real_2025,
    SUM(CASE WHEN EXTRACT(YEAR FROM rot.fecha) = 2025 THEN rot.meta_produccion_unidades ELSE 0 END) AS meta_2025,
    ROUND(
        (SUM(CASE WHEN EXTRACT(YEAR FROM rot.fecha) = 2025 THEN rph.unidades_producidas ELSE 0 END)::NUMERIC / 
        NULLIF(SUM(CASE WHEN EXTRACT(YEAR FROM rot.fecha) = 2025 THEN rot.meta_produccion_unidades ELSE 0 END), 0)) * 100, 2
    ) AS pct_productividad_2025,

    -- Métricas Año 2026
    SUM(CASE WHEN EXTRACT(YEAR FROM rot.fecha) = 2026 THEN rph.unidades_producidas ELSE 0 END) AS prod_real_2026,
    SUM(CASE WHEN EXTRACT(YEAR FROM rot.fecha) = 2026 THEN rot.meta_produccion_unidades ELSE 0 END) AS meta_2026,
    ROUND(
        (SUM(CASE WHEN EXTRACT(YEAR FROM rot.fecha) = 2026 THEN rph.unidades_producidas ELSE 0 END)::NUMERIC / 
        NULLIF(SUM(CASE WHEN EXTRACT(YEAR FROM rot.fecha) = 2026 THEN rot.meta_produccion_unidades ELSE 0 END), 0)) * 100, 2
    ) AS pct_productividad_2026

FROM linea_produccion lp
JOIN registro_orden_turno rot ON lp.linea_id = rot.linea_id
JOIN registro_produccion_hora rph ON rot.registro_turno_id = rph.registro_turno_id
WHERE rot.fecha BETWEEN '2025-01-01' AND '2026-12-31'
GROUP BY lp.codigo_linea, EXTRACT(MONTH FROM rot.fecha)
ORDER BY mes, maquina;


-- =============================================================================
-- REPORTE 2: PARETO DE TIEMPOS INPRODUCTIVOS (POR CÓDIGO DE PARO)
-- OBJETIVO: Identificar las causas principales de pérdida de tiempo en la planta 
-- y calcular el porcentaje de impacto de cada categoría sobre el total global.
-- =============================================================================

WITH TotalTiempoParos AS (
    -- Subconsulta CTE para calcular el total acumulado de minutos perdidos
    SELECT SUM(duracion_minutos) AS tiempo_total_global
    FROM registro_paro_detalle
)
SELECT 
    cp.codigo AS codigo_paro,
    cp.descripcion AS motivo_principal,
    cp.categoria,
    COUNT(rpd.paro_id) AS cantidad_eventos,
    SUM(rpd.duracion_minutos) AS minutos_totales_paro,
    ROUND(
        (SUM(rpd.duracion_minutos) / (SELECT tiempo_total_global FROM TotalTiempoParos)) * 100, 2
    ) AS pct_participacion_tiempo
FROM registro_paro_detalle rpd
JOIN subcodigo_paro sp ON rpd.subcodigo_paro_id = sp.subcodigo_paro_id
JOIN codigo_paro cp ON sp.codigo_paro_id = cp.codigo_paro_id
GROUP BY cp.codigo, cp.descripcion, cp.categoria
ORDER BY minutos_totales_paro DESC;


-- =============================================================================
-- REPORTE 3: DESGLOSE DETALLADO DE CÓDIGOS CRÍTICOS (01, 03 Y 05)
-- OBJETIVO: Analizar las causas específicas (subcódigos) de las fallas mecánicas, 
-- falta de insumos y limpiezas de boquillas para priorizar mantenimiento.
-- =============================================================================

SELECT 
    cp.codigo AS codigo_principal,
    cp.descripcion AS descripcion_codigo,
    sp.subcodigo,
    sp.descripcion AS detalle_subcodigo,
    COUNT(rpd.paro_id) AS frecuencia_paro,
    SUM(rpd.duracion_minutos) AS minutos_acumulados,
    ROUND(AVG(rpd.duracion_minutos), 2) AS tiempo_promedio_falla_min,
    ROUND(
        (SUM(rpd.duracion_minutos) / SUM(SUM(rpd.duracion_minutos)) OVER(PARTITION BY cp.codigo)) * 100, 2
    ) AS pct_participacion_dentro_del_codigo
FROM registro_paro_detalle rpd
JOIN subcodigo_paro sp ON rpd.subcodigo_paro_id = sp.subcodigo_paro_id
JOIN codigo_paro cp ON sp.codigo_paro_id = cp.codigo_paro_id
WHERE cp.codigo IN ('01', '03', '05')
GROUP BY cp.codigo, cp.descripcion, sp.subcodigo, sp.descripcion
ORDER BY cp.codigo, minutos_acumulados DESC;


-- =============================================================================
-- REPORTE 4: RENDIMIENTO PRODUCTIVO Y TIEMPOS MUERTOS POR TURNO
-- OBJETIVO: Comparar la productividad y los tiempos de paro entre los 3 turnos de 
-- trabajo (Turno 1, Turno 2, Turno 3) para identificar variaciones operativas.
-- =============================================================================

SELECT 
    t.nombre_turno,
    COUNT(DISTINCT rot.registro_turno_id) AS total_turnos_evaluados,
    SUM(rph.unidades_producidas) AS total_unidades_producidas,
    ROUND(AVG(rph.unidades_producidas), 0) AS promedio_unidades_hora,
    COALESCE(SUM(rpd.duracion_minutos), 0) AS total_minutos_paro_acumulados,
    ROUND(
        COALESCE(SUM(rpd.duracion_minutos), 0) / NULLIF(COUNT(DISTINCT rot.registro_turno_id), 0), 2
    ) AS promedio_minutos_paro_por_turno
FROM turno t
JOIN registro_orden_turno rot ON t.turno_id = rot.turno_id
LEFT JOIN registro_produccion_hora rph ON rot.registro_turno_id = rph.registro_turno_id
LEFT JOIN registro_paro_detalle rpd ON rot.registro_turno_id = rpd.registro_turno_id
GROUP BY t.turno_id, t.nombre_turno
ORDER BY t.turno_id;


-- =============================================================================
-- REPORTE 5: TIEMPO MEDIO ENTRE FALLAS MECÁNICAS (INDICADOR MTBF)
-- OBJETIVO: Calcular el indicador industrial MTBF (Mean Time Between Failures) 
-- por cada línea para medir la confiabilidad de la maquinaria.
-- =============================================================================

SELECT 
    lp.codigo_linea AS maquina,
    COUNT(rpd.paro_id) AS total_fallas_mecanicas,
    COALESCE(SUM(rpd.duracion_minutos), 0) AS tiempo_total_paros_min,
    ROUND(
        (COUNT(DISTINCT rot.registro_turno_id) * 8 * 60 - COALESCE(SUM(rpd.duracion_minutos), 0)) / 
        NULLIF(COUNT(rpd.paro_id), 0), 2
    ) AS mtbf_minutos_operacion
FROM linea_produccion lp
JOIN registro_orden_turno rot ON lp.linea_id = rot.linea_id
LEFT JOIN registro_paro_detalle rpd ON rot.registro_turno_id = rpd.registro_turno_id
LEFT JOIN subcodigo_paro sp ON rpd.subcodigo_paro_id = sp.subcodigo_paro_id
LEFT JOIN codigo_paro cp ON sp.codigo_paro_id = cp.codigo_paro_id AND cp.categoria = 'Mantenimiento Mecánico'
GROUP BY lp.codigo_linea
ORDER BY mtbf_minutos_operacion ASC;    