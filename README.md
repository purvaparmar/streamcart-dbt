# 🛒 StreamCart dbt Project

> Turning messy retail data into clean, analytics-ready insights with **dbt + Snowflake** ❄️

---

## 🚀 About the Project

StreamCart is an end-to-end analytics pipeline built using **dbt Core** and **Snowflake**.

The project transforms raw JSON event data into business-ready models through a layered architecture while applying data quality checks, snapshots, documentation, and automated hooks.

### ✨ Highlights

- 📦 Raw JSON ingestion
- 🧹 Staging models for data cleaning & standardization
- ⚙️ Intermediate business transformations
- 📊 Star-schema marts
- 📈 Reporting models
- 🕒 Slowly Changing Dimensions (Snapshots)
- ✅ Data quality testing
- 📚 Auto-generated documentation & lineage
- 🔐 Audit logging using dbt hooks

---

# 🏗️ Project Architecture

```text
RAW
 │
 ▼
STAGING
 │
 ▼
INTERMEDIATE
 │
 ▼
CORE MARTS
 │
 ▼
REPORTING MARTS
```

---

# 🛠️ Tech Stack

| Tool | Purpose |
|------|---------|
| ❄️ Snowflake | Data Warehouse |
| 🌱 dbt Core | Data Transformation |
| SQL | Transformations |
| Git & GitHub | Version Control |

---

# 📂 Project Structure

```
models/
 ├── staging/
 ├── intermediate/
 └── marts/
      ├── core/
      └── reporting/

macros/
snapshots/
tests/
seeds/
```

---

# ▶️ Running the Project

Install dependencies

```bash
dbt deps
```

Run models

```bash
dbt run
```

Run snapshots

```bash
dbt snapshot
```

Run tests

```bash
dbt test
```

Generate documentation

```bash
dbt docs generate
dbt docs serve
```

---

# 📊 Data Quality

The project includes:

- ✔️ Generic Tests
- ✔️ Singular Tests
- ✔️ Custom Generic Test Macro
- ✔️ dbt_expectations Tests
- ✔️ Source Freshness Checks

---

# 📸 Features

- Incremental Fact Model
- SCD Type 2 Snapshots
- Audit Logging Hooks
- Automated Permissions
- Documentation Coverage
- Interactive Lineage Graph

---

# 📁 Core Models

### ⭐ Core

- `dim_customers`
- `fct_orders`

### 📈 Reporting

- `monthly_revenue_summary`
- `channel_performance_summary`
- `category_revenue_pivot`
- `product_performance`

---

# 👩‍💻 Author

**Purva Parmar**

Built as part of the **StreamCart dbt Practical Assignment** using dbt Core & Snowflake.