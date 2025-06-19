# 🗂️ Vibesia - Documentation Folder

> Centralized technical and functional documentation for the **Vibesia Database System**, part of the final project for the Database Course.

---

## 📌 Overview

This folder contains all supporting materials for understanding, implementing, and maintaining the **Vibesia music database system**. It includes installation guides, data models, SQL references, and normalization documentation.

---

## ✨ Features

- 📖 Full technical manuals (installation, complex queries)
- 🧠 Conceptual, logical, and physical data models
- 🧩 Normalization and data dictionary spreadsheets
- 📂 Visual diagrams (ERD, LDM, PDM)
- 📌 Organized and production-ready structure for academic or real use

---

## 🧱 Folder Structure

```bash
docs/
├── Manual_de_Instalacion_y_Configuracion.pdf      # Setup and DB configuration guide
├── Manual_Consultas_Complejas_Vibesia.pdf         # Guide with 10 complex SQL queries
├── Instalacion_PostgreSQL_v17.0.pdf               # PostgreSQL installation reference
├── Normalizacion-G3-AD ASTRA.xlsx                 # Normalization process (1NF to 3NF)
├── diccionario_datos.xlsx                         # Complete data dictionary
└── models/
    ├── ERD/                                       # Entity-Relationship Diagram
    ├── LDM/                                       # Logical Data Model
    └── PDM/                                       # Physical Data Model
```

---

## 📚 Documentation Index

### 📘 Manuals

| File                                      | Description                                                                          |
|-------------------------------------------|--------------------------------------------------------------------------------------|
| `Manual_de_Instalacion_y_Configuracion.pdf` | Step-by-step database setup and trigger configuration                              |
| `Manual_Consultas_Complejas_Vibesia.pdf`  | Contains advanced analytical queries using SQL (CTEs, windows, filters)             |
| `Instalacion_PostgreSQL_v17.0.pdf`       | Guide to install PostgreSQL 17 on Windows                                           |

---

### 📊 Spreadsheets

| File                              | Purpose                                                     |
|-----------------------------------|-------------------------------------------------------------|
| `Normalizacion-G3-AD ASTRA.xlsx` | Design normalization (1NF, 2NF, 3NF)                        |
| `diccionario_datos.xlsx`         | Field definitions, data types, constraints, and references  |

---

### 🧩 Models

| Directory  | Description                                                                      |
|------------|----------------------------------------------------------------------------------|
| `ERD/`     | High-level conceptual model (entities & relationships)                          |
| `LDM/`     | Logical model with full attributes, PKs/FKs, and relationship cardinality        |
| `PDM/`     | Physical schema ready for SQL implementation (includes types and constraints)    |

---

## 🚀 Usage Recommendations

- ✅ Read the installation guide before deploying any scripts.
- 🔍 Use the data dictionary and logical models when altering or extending the schema.
- 🧪 Complex queries require a fully populated database. See `sql/dml/data/`.

---

## 📄 License

This project and its documentation are released for academic and educational purposes only.

---

## 📈 Project Status

**Status**: ✅ Completed – Final delivery (June 2025)  
**Repository**: [ProyectoFinal-BD](https://github.com/JuanDavidJR/ProyectoFinal-BD)
