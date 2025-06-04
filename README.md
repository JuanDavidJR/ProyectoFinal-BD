# ProyectoFinal-BD
# Proyecto: MusicApp-Vibesia 💳 💸

**Developers**: Oscar Alejandro Prasca Chacón, Carlos Julio Vergel Wilches, Karen Silvana Duque Leal, Duvan Arley Ramirez Duran, Juan David Jaimes Rojas  
**Source Directory**: `https://github.com/JuanDavidJR/ProyectoFinal-BD.git`  
**Created**: 31-Mayo-2025 🗓️  
**Last Update**: 1-Junio-2025 ✨  

## Project Structure

### [docs/](./docs/)
**Purpose**: It is responsible for containing all necessary documentation for the project structure, making it easier for administrators and developers to understand it.

**Content**:
- `Instalacion_PostgreSQL_v17.0.pdf`: realization of how to correctly install postgreSQL.
- `Manual_de_Intalacion_y_Configuracion.pdf`: Contains how to create the final project step by step.
- `Normalización_tablas.xlsx`: Document containing the detailed normalization of all tables in the data dictionary.
- `Diccionario_Datos.xlsx`: Detailed data dictionary.

**Subfolders**:
- [models/](./docs/models/): It stores the database models in their different stages: ERD (Entity-Relationship), LDM (Logical Model) and PDM (Physical Model).

**Subfolders**:
- [ERD/](./models/ERD/): Entity-Relationship diagram that represents the initial design.
- [LDM/](./models/LDM/): Logical models that define relationships and attributes without physical details.
- [PDM/](./models/PDM/): Physical models with concrete definitions for implementation.

### [sql/](./sql/)
**Purpose**: Contains all SQL scripts and automation files.

**Subcarpetas**:
- [ddl/](./sql/ddl/): Structure definition scripts (e.g., `CREATE TABLE`, `CREATE INDEX`).
- [dml/](./sql/dml/): Data manipulation scripts, such as inserts, updates, and deletes.
- [queries](./sql/queries): Contains all the queries that need to be made at work.
- [pipelines](./sql/pipelines): Automation scripts to load data and run batch scripts..


**pipelines scripts used from**: `https://github.com/Doc-UP-AlejandroJaimes/sql-101-mastering.git`


---