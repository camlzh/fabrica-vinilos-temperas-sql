#  Fábrica de Vinilos y Témperas — Sistema de Control de Producción y Paros (PostgreSQL)

Este repositorio contiene la solución completa de base de datos relacional para el monitoreo de producción, gestión de tiempos muertos e indicadores industriales (KPIs) de una fábrica de pinturas.

---

## 🚀 Estructura del Proyecto y Orden de Ejecución

Los scripts deben ejecutarse secuencialmente en **PostgreSQL** para garantizar la integridad de las relaciones y datos:

1. `01_ddl_esquema.sql` — Creación de la base de datos (9 tablas, llaves foráneas, restricciones `CHECK`, índices de rendimiento y vistas de soporte).
2. `02_dml_catalogos.sql` — Poblamiento de catálogos maestras (cargos, turnos, líneas) y registros transaccionales de operación.
3. `03_dml_pruebas.sql` — Pruebas de actualización, borrado en cascada y validación de reglas de negocio.
4. `04_consultas.sql` — Consultas analíticas de negocio (Productividad 2025 vs 2026, Pareto de paros de planta y cálculo del tiempo medio entre fallas - MTBF).

---

## 📊 Principales KPIs Calculados

* **Productividad por Línea:** Eficiencia porcentual frente a la meta de producción.
* **Pareto de Tiempos Muertos:** Clasificación de causas principales de detención en planta.
* **MTBF (Mean Time Between Failures):** Confiabilidad operativa de los equipos de envasado y mezclado.

---

## 🛠️ Requisitos
* PostgreSQL 13+
* VS Code con extensión *PostgreSQL* (opcional para desarrollo local).
