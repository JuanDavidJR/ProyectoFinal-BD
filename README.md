<h1 align="center">🎓 Final University Project — MusicApp Vibesia</h1>
<p align="center">
  💳 A full-featured database project for a digital music application. Includes schema design, normalization, optimization, automation, and auditing using PostgreSQL.
</p>

---

## 🧠 General Information

- 📁 **Repository**: [`ProyectoFinal-BD`](https://github.com/JuanDavidJR/ProyectoFinal-BD.git)
- 🛠️ **Project Name**: `MusicApp - Vibesia`
- 🧑‍💻 **Developers**:
  - Oscar Alejandro Prasca Chacón
  - Carlos Julio Vergel Wilches
  - Karen Silvana Duque Leal
  - Duvan Arley Ramírez Durán
  - Juan David Jaimes Rojas
- 📅 **Created**: 31-May-2025  
- 🛠️ **Last Updated**: 1-Jun-2025

---

## 📂 Project Structure

### 📄 [`docs/`](./docs/)

> Contains essential documentation for system understanding and implementation.

#### 📚 Contents:
- `Instalacion_PostgreSQL_v17.0.pdf`: Guide for installing PostgreSQL.
- `Manual_de_Instalacion_y_Configuracion.pdf`: Step-by-step project setup instructions.
- `Normalización_tablas.xlsx`: Full normalization of tables.
- `Diccionario_Datos.xlsx`: Complete data dictionary.
- `Manual_Optimizacion_Actualizado_Vibesia.pdf`: Performance optimization and indexing strategies.

#### 📁 Subfolders:
##### 🔷 [`models/`](./docs/models/)
Stores all database modeling stages:

- [`ERD/`](./docs/models/ERD/): Entity-Relationship Diagram (high-level conceptual view).
- [`LDM/`](./docs/models/LDM/): Logical Data Model (structure & relationships).
- [`PDM/`](./docs/models/PDM/): Physical Data Model (implementation-ready).

---

### 🧾 [`sql/`](./sql/)

> Contains all SQL files for schema creation, data manipulation, queries, and automation.

#### 📁 Subfolders:

- [`ddl/`](./sql/ddl/): DDL scripts for schema creation (`CREATE TABLE`, indexes, etc.).
- [`dml/`](./sql/dml/): DML scripts for inserting and modifying data.
- [`queries/`](./sql/queries): Complex and analytical SQL queries required by the project.
- [`pipelines/`](./sql/pipelines): Data loading and batch execution automation.

#### 🔁 Pipeline Source:
Scripts adapted from: [`sql-101-mastering`](https://github.com/Doc-UP-AlejandroJaimes/sql-101-mastering.git)

---

## ✅ Features Covered

- ✅ PostgreSQL 17 support
- ✅ Normalization up to 3NF
- ✅ Data dictionary + ERD, LDM, PDM
- ✅ Optimized indexes and performance tuning
- ✅ Batch execution via SQL pipelines
- ✅ Full CRUD audit log (`audit_log` in `vibesia_schema`)

---

## 📌 Notable Module: Audit Log

> See [`docs/audit_log_README.md`](./docs/audit_log_README.md) for full documentation of the audit table tracking all INSERT, UPDATE, and DELETE operations across system tables.

---

## 🏁 Objective

This project is developed as a demonstrate practical application of:

- Database theory and modeling
- SQL scripting and query building
- Schema normalization and optimization
- Real-world data auditing and system monitoring

---

## 📬 Contact

For questions or academic inquiries, contact any of the listed team members or visit the GitHub repository for issue tracking and feedback.

---
