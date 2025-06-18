# 📊 Audit Log Table — `vibesia_schema.audit_log`

<p align="center">
  A PostgreSQL audit log table designed to track CRUD operations on system tables — built for data traceability, security auditing, and compliance in a university final project.
</p>

---

## 📁 Schema: `vibesia_schema`

This audit table is part of the `vibesia_schema` in a larger academic database system project developed to simulate enterprise-grade observability and accountability within critical data environments.

---

## 📌 Purpose

The `audit_log` table serves as a centralized tracking system for all **INSERT**, **UPDATE**, and **DELETE** operations performed on key system tables. It provides essential metadata such as user identity, timestamps, request context, and before/after values to ensure full traceability and compliance.

---

## 🧩 Table Structure

| Column             | Type           | Description |
|--------------------|----------------|-------------|
| `audit_id`         | `SERIAL`       | Unique identifier for each audit entry (Primary Key). |
| `db_user_name`     | `VARCHAR(100)` | Database session user (default: `SESSION_USER`). |
| `app_user_id`      | `INTEGER`      | Application-level user ID. |
| `app_user_email`   | `VARCHAR(255)` | User email from the app layer. |
| `app_user_role`    | `VARCHAR(50)`  | Role of the application user. |
| `action_type`      | `VARCHAR(10)`  | Type of operation: `INSERT`, `UPDATE`, or `DELETE`. |
| `timestamp`        | `TIMESTAMP`    | Date and time of the action (default: `CURRENT_TIMESTAMP`). |
| `table_name`       | `VARCHAR(50)`  | Name of the affected table. |
| `record_id`        | `INTEGER`      | ID of the affected record. |
| `old_values`       | `JSONB`        | Previous values before the change. |
| `new_values`       | `JSONB`        | New values after the change. |
| `connection_ip`    | `INET`         | Client IP address. |
| `user_agent`       | `TEXT`         | HTTP user agent string from request. |
| `api_endpoint`     | `VARCHAR(255)` | API endpoint used. |
| `request_id`       | `VARCHAR(100)` | Unique request identifier. |
| `application_name` | `VARCHAR(50)`  | Name of the app (default: `vibesia_app`). |
| `environment`      | `VARCHAR(20)`  | Environment type (`production`, `staging`, etc.). |

---

## 📈 Indexes

To improve query performance, the following indexes are created:

| Index Name                        | Description |
|----------------------------------|-------------|
| `idx_audit_log_app_user_id`      | Speeds up queries filtered by application user ID. |
| `idx_audit_log_timestamp`        | Optimizes queries over time ranges. |
| `idx_audit_log_table_name`       | Accelerates filtering by table. |
| `idx_audit_log_action_type`      | Efficient filtering by operation type. |
| `idx_audit_log_record_id`        | Composite index for `(table_name, record_id)` queries. |

---

## 💡 Usage Examples

### 1️⃣ View all actions on a specific record

```sql
SELECT * FROM vibesia_schema.audit_log 
WHERE table_name = 'users' AND record_id = 1 
ORDER BY timestamp DESC;
```

### 2️⃣ View all actions by a specific user

```sql
SELECT * FROM vibesia_schema.audit_log 
WHERE app_user_id = 1
ORDER BY timestamp DESC;
```

### 3️⃣ Retrieve all operations within a specific date range

```sql
SELECT * FROM vibesia_schema.audit_log 
WHERE timestamp BETWEEN '2025-01-01' AND '2025-12-31'
ORDER BY timestamp DESC;
```

### 4️⃣ Fetch deleted records and their last known state

```sql
SELECT table_name, record_id, old_values, timestamp
FROM vibesia_schema.audit_log 
WHERE action_type = 'DELETE'
ORDER BY timestamp DESC;
```

### 5️⃣ Track changes to a specific field

```sql
SELECT table_name, record_id, 
       old_values->>'field_name' AS old_value,
       new_values->>'field_name' AS new_value,
       timestamp
FROM vibesia_schema.audit_log 
WHERE action_type = 'UPDATE' 
  AND (old_values->>'field_name' IS DISTINCT FROM new_values->>'field_name');
```

---

## 🔐 Security & Best Practices

* 🔒 **Access Control:** Ensure only privileged users can query this table.
* 🧼 **Retention Policy:** For performance, implement periodic archival or cleanup of old entries.
* 🛡️ **Anomaly Detection:** Integrate with monitoring tools to detect suspicious behaviors or policy violations.

---

## 📡 Integration Potential

This table can be connected with:

* 📊 Admin dashboards (e.g., Metabase, Grafana)
* 🔍 Forensic tools and audit trails
* 🔔 Alerting systems for abnormal user behavior
* 📑 Compliance reporting systems

---

## 📘 Project Context

This table is part of the **"Vibesia Database Monitoring Layer"**, developed as part of a final university project focused on building robust and observable database systems with real-world auditing capabilities.
