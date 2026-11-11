# 🏭 Fábrica de Vinilos y Témperas — Sistema de Control de Producción, Paros y KPIs (PostgreSQL)

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-13%2B-blue?logo=postgresql)
![VS Code](https://img.shields.io/badge/IDE-VS%20Code-007ACC?logo=visualstudiocode)
![Status](https://img.shields.io/badge/Status-Completed-success)

Este repositorio contiene la solución técnica integral de base de datos relacional para el monitoreo de líneas de envasado y mezclado de pinturas, la gestión del tiempo muerto (paros de planta) y la generación automatizada de indicadores clave de rendimiento (KPIs).

---

## 📌 Tabla de Contenidos
1. [Descripción del Proyecto](#-descripción-del-proyecto)
2. [Arquitectura del Modelo Relacional](#-arquitectura-del-modelo-relacional)
3. [Secuencia de Ejecución de Scripts](#-secuencia-de-ejecución-de-scripts)
4. [Detalle de los Archivos SQL](#-detalle-de-los-archivos-sql)
5. [Resultados Analíticos y KPIs](#-resultados-analíticos-y-kpis)
6. [Requisitos e Instalación](#-requisitos-e-instalación)

---

## 📖 Descripción del Proyecto

El sistema responde a las necesidades operativas de una planta industrial de vinilos y témperas que requiere registrar en tiempo real la producción realizada por turno, controlar las pérdidas por paradas no programadas (fallas mecánicas, eléctricas, logísticas) y evaluar la confiabilidad de su maquinaria.

### Objetivos Clave:
* **Normalización:** Diseño relacional en Tercera Forma Normal (3FN) con 9 tablas interconectadas.
* **Integridad de Datos:** Restricciones de dominio (`CHECK`), integridad referencial (`FOREIGN KEY ON DELETE CASCADE/RESTRICT`) y unicidad (`UNIQUE`).
* **Rendimiento:** Creación de índices estratégicos para acelerar reportes analíticos sobre millones de registros transaccionales.
* **Analítica de Negocio:** Cálculo automatizado de Productividad, Diagrama de Pareto de Tiempos Muertos e Indicador de Confiabilidad MTBF.

---

## 📐 Arquitectura del Modelo Relacional

El esquema de la base de datos se distribuye en 3 capas operativas:

```
+-----------------------------------------------------------------------+
|                            CATÁLOGOS BASE                             |
|  [cargo]  [linea_produccion]  [turno]  [codigo_paro]  [subcodigo_paro] |
+------------------------------------+----------------------------------+
                                     |
                                     v
+------------------------------------+----------------------------------+
|                          TABLAS MAESTRAS                              |
|                       [empleado]                                      |
+------------------------------------+----------------------------------+
                                     |
                                     v
+------------------------------------+----------------------------------+
|                       TABLAS TRANSACCIONALES                          |
|  [registro_orden_turno]  [registro_produccion_hora]  [registro_paro_detalle] |
+-----------------------------------------------------------------------+
```

---

## 🔄 Secuencia de Ejecución de Scripts

Para garantizar el cumplimiento de las llaves foráneas y evitar errores de dependencias, los scripts deben ejecutarse estrictamente en el siguiente orden:

```bash
01_ddl_esquema.sql ──► 02_dml_catalogos.sql ──► 03_dml_pruebas.sql ──► 04_consultas.sql
```

---

## 📁 Detalle de los Archivos SQL

### 1️⃣ `01_ddl_esquema.sql` — Estructura y Vistas
* **Lógica:** Implementa la rutina de limpieza previa (`DROP TABLE IF EXISTS ... CASCADE`), define el esquema relacional completo (9 tablas), establece llaves primarias/foráneas y restricciones `CHECK`.
* **Optimizaciones:**
  * Índices B-Tree: `idx_orden_turno_fecha`, `idx_paro_detalle_registro`, `idx_produccion_hora_registro`.
  * Vista analítica: `vista_resumen_paros` para simplificar la consulta de causas de fallas.

### 2️⃣ `02_dml_catalogos.sql` — Poblamiento y Transacciones
* **Lógica:** Inserta la parametrización de planta (cargos de personal, líneas de producción de vinilos y témperas, turnos de trabajo y tabla jerárquica de motivos de parada).
* **Transacciones:** Registra eventos reales de producción horaria e historial de detenciones por mantenimiento y operación.

### 3️⃣ `03_dml_pruebas.sql` — Validaciones de Integridad
* **Lógica:** Realiza pruebas de actualización masiva (`UPDATE`) y borrado en cascada (`DELETE`), comprobando la robustez de las restricciones `CHECK` e integridad referencial ante modificaciones transaccionales.

### 4️⃣ `04_consultas.sql` — Reportes DQL y KPIs
* **Lógica:** Contiene 5 consultas analíticas avanzadas utilizando funciones de agregación (`SUM`, `COUNT`), uniones de tablas (`JOIN`), manejo de nulos (`NULLIF`) y ordenamiento jerárquico.

---

## 📊 Resultados Analíticos y KPIs

### 📈 1. Productividad por Línea de Producción
Compara las metas nominales programadas frente a las unidades reales terminadas por turno:

| Línea | Mes | Producción Real (2025) | Meta (2025) | % Productividad | Producción Real (2026) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Vinilos_1** | 5 | 0 | 0 | *N/A* | 883 unidades |

### 📉 2. Análisis de Pareto de Tiempos Muertos
Jerarquiza las causales de paro para identificar los principales cuellos de botella de la planta:

| Código | Motivo Principal | Categoría | Eventos | Tiempo Total |
| :---: | :--- | :--- | :---: | :---: |
| **02** | Falla Eléctrica / Electrónica | Mantenimiento Eléctrico | 1 | **45.00 min** |
| **01** | Falla Mecánica en Envasadora | Mantenimiento Mecánico | 1 | **30.00 min** |
| **05** | Limpieza y Desinfección | Operativa | 1 | **25.00 min** |
| **03** | Falta de Materia Prima | Logística | 1 | **20.00 min** |

### ⚙️ 3. Confiabilidad Operativa — MTBF (Mean Time Between Failures)
Calcula el Tiempo Medio Entre Fallas por maquinaria para planificar el mantenimiento preventivo antes de que ocurran averías críticas.

---

## 🛠️ Requisitos e Instalación

### Requisitos Previos
* PostgreSQL 13.0 o superior
* VS Code con extensión *PostgreSQL Explorer* (opcional)

### Despliegue en Servidor Local

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/camlzh/fabrica-vinilos-temperas-sql.git
   cd fabrica-vinilos-temperas-sql
   ```

2. **Ejecutar desde terminal `psql`:**
   ```bash
   psql -U postgres -d postgres -f 01_ddl_esquema.sql
   psql -U postgres -d postgres -f 02_dml_catalogos.sql
   psql -U postgres -d postgres -f 03_dml_pruebas.sql
   psql -U postgres -d postgres -f 04_consultas.sql
   ```

---

## 👤 Autor
* **Camilo H.** — *Desarrollo de Base de Datos & SQL Analytics* — [GitHub](https://github.com/camlzh)