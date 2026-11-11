# 🏭 Fábrica de Vinilos y Témperas — Sistema de Control de Producción y Paros (PostgreSQL)

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-13%2B-blue.svg)](https://www.postgresql.org/)
[![VS Code](https://img.shields.io/badge/VS%20Code-Supported-007ACC.svg)](https://code.visualstudio.com/)
[![License](https://img.shields.io/badge/Status-Completed-success.svg)]()

Este repositorio contiene la solución técnica completa de base de datos relacional para el monitoreo de la producción industrial, la gestión de tiempos muertos (paros de planta) y el cálculo de indicadores clave de rendimiento (KPIs) para una fábrica de pinturas (vinilos y témperas).

---

## 🚀 Arquitectura del Proyecto y Orden de Ejecución

Los scripts deben ejecutarse estrictamente en orden secuencial en **PostgreSQL** para garantizar la integridad referencial de las llaves foráneas y catálogos:

| Secuencia | Archivo Script | Fase SQL | Descripción Técnica |
| :---: | :--- | :---: | :--- |
| **01** | `01_ddl_esquema.sql` | **DDL** | Limpieza previa (`DROP CASCADE`), creación de 9 tablas relacionales en 3FN, llaves primarias/foráneas, restricciones `CHECK`, índices de rendimiento y la vista `vista_resumen_paros`. |
| **02** | `02_dml_catalogos.sql` | **DML** | Poblamiento de catálogos maestras (cargos, turnos, líneas, códigos de fallo) e inserción de transacciones reales de producción y tiempos muertos. |
| **03** | `03_dml_pruebas.sql` | **DML** | Pruebas de validación de reglas de negocio, actualización de registros y verificación de borrado en cascada (`ON DELETE CASCADE`). |
| **04** | `04_consultas.sql` | **DQL** | 5 consultas analíticas avanzadas para el cálculo de Productividad por línea, Diagrama de Pareto de paros de planta y el indicador MTBF. |

---

## 📐 Modelo de Datos y Estructura Relacional (3FN)

El sistema consta de 9 tablas organizadas jerárquicamente en el esquema `public`:

* **Catálogos Base:** `cargo`, `linea_produccion`, `turno`, `codigo_paro`.
* **Tablas Maestras y Secundarias:** `empleado`, `subcodigo_paro`.
* **Tablas Transaccionales:** `registro_orden_turno`, `registro_produccion_hora`, `registro_paro_detalle`.
* **Vista Analítica:** `vista_resumen_paros` (consolida fallas con sus causas raíz y duraciones).

---

## 📊 Principales KPIs Calculados (`04_consultas.sql`)

### 1. Productividad por Línea y Turno
Compara las metas nominales de producción contra el volumen real de unidades fabricadas por hora y turno operativo (ejemplo: línea *Vinilos_1*).

### 2. Diagrama de Pareto — Tiempos Muertos
Agrupa y clasifica los minutos totales de detención por categoría y código de paro. Permite identificar que los mantenimientos eléctricos y mecánicos generan más del 60% de los cuellos de botella en la planta.

### 3. Confiabilidad Operativa — MTBF (Mean Time Between Failures)
Calcula el tiempo promedio (en horas) que transcurre entre fallas mecánicas y eléctricas continuas por cada línea de producción:

$$\text{MTBF} = \frac{\text{Horas Totales de Operación}}{\text{Número de Fallas Mecánicas/Eléctricas}}$$

---

## 🛠️ Guía de Ejecución en Servidor Local

### Prerrequisitos
* **PostgreSQL 13** o superior.
* **Visual Studio Code** con la extensión *PostgreSQL Explorer* o cliente `psql`.

### Opción A: Ejecución Manual desde VS Code
1. Conecta la extensión **PostgreSQL** a tu base de datos local `postgres`.
2. Abre y ejecuta los scripts individualmente en el editor en orden:
   * `01_ddl_esquema.sql`
   * `02_dml_catalogos.sql`
   * `03_dml_pruebas.sql`
   * `04_consultas.sql`

### Opción B: Ejecución por Terminal (`psql`)
```bash
psql -U postgres -d postgres -f 01_ddl_esquema.sql
psql -U postgres -d postgres -f 02_dml_catalogos.sql
psql -U postgres -d postgres -f 03_dml_pruebas.sql
psql -U postgres -d postgres -f 04_consultas.sql