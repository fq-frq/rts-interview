# RTS Interview – Take-Home Assessment

## 🔍 Overview

This repository contains my solution to the **Analytics Engineer Take-Home Assessment** for RTS, Switzerland. The objective was to build a modern data stack that transforms raw clickstream data into a well-modeled, analysis-ready format and to visualize insights using Power BI.

Key components:
- **Python + dbt (BigQuery)** for data transformation  
- **Google Cloud Platform** for data storage and processing  
- **Power BI** for reporting and visual storytelling

---

## 🚀 How to Run This Project

### If you just want to visualize Power BI dashoboards:
Open `pbi_rts_interview.pbix`usnig Power BI desktop.

### If your want to run it from scratch:
#### 1. Clone the Repository
#### 2. Set Up Python Environment  
Make sure Python 3.11.9 is installed (for compatibility with `dbt-bigquery`).
```bash
python -m venv dbt-env
source dbt-env/bin/activate  # Or `dbt-env\Scripts\activate` on Windows
pip install -r requirements.txt
```
#### 3. Google Cloud Setup  
Create a GCP project, e.g., `prj-yourname-rts-interview`  
Upload the raw CSV (`extract udp srf.csv`) to a GCS bucket, e.g., `bkt_yourname_rts_interview_raw`  
Create a BigQuery dataset `dts_rts_interview` in region `europe-west9`  
Create an external table in BigQuery using the provided `create_external_table.sql` script  
#### 4. Configure dbt Profile  
Create your service account key and save the JSON file at the root of the repository as `service_account_key.json`  
Update `dbt_prj_rts_interview/profiles.yml` file specifying your JSON file full path and your project name.  
#### 5. Run the dbt Project  
```bash
dbt deps      # Install dbt packages
dbt seed      # Load country/language codes
dbt run       # Build models
dbt snapshot  # Create SCD2 snapshot
dbt test      # Run tests
```
#### 6. Open Power BI Dashboard  
Use Power BI Desktop to connect to BigQuery and explore the final star schema:  
- fact_events
- dim_languages
- dim_locations
- dim_sessions
- dim_contents
- contents_snapshot

---

## 🧠 Approach & Key Decisions

### ✅ Tooling Choices
- **Python 3.11.9**: Ensures compatibility with the dbt-bigquery version used in this project.
- **GCP (BigQuery + GCS)**: Emulates a realistic cloud-based data architecture, based on what I have seen in my current Data Engineer position.
- **dbt-core + dbt-bigquery**: Used to structure transformations and create clean, reusable, and testable models.
- **Power BI**: Chosen for its user-friendly interface and ability to deliver rich insights quickly.

### 🧱 Data Modeling
The provided data is a single flat CSV file containing clickstream events from RTS's website. Given its volume, null values, and lack of metadata, I applied a Kimball-style STAR schema approach to organize the dataset with a few dimension tables and one fact table described below.  

### 🧪 Staging Layer
The `stg_extract_udp_srf` model handles:
- Column renaming for readability
- Casting to correct data types

### 🧰 Intermediate Models
For each final dimension and fact table, I created an intermediate model to:  
- Clean and deduplicate rows
- Enrich data with calculated columns
- Perform joins or mapping logic

### ⭐ Final Star Schema
- `fact_events`: One event per row, representing a user click or interaction. Excludes dimension attributes already modeled elsewhere.
- `dim_contents`: Unique contents defined by page type and title. Includes a generated content_modification_datetime which canis usefull for tracking changes.
- `dim_languages`: Enriched via dbt seeds using country and language code CSVs sourced externally.
- `dim_locations`: Based on country, region, and city — derived from user context.
- `dim_sessions`: Session-level data including:
    - session_duration_seconds
    - total_events (maximum rank in session)

### 📆 Snapshots
- `contents_snapshot`: Tracks content changes over time using dbt's SCD2 mechanism (dbt snapshot) and timestamp strategy.

### 📏 Tests & Contracts
To ensure data quality and model integrity, I added on every id field in final tables:
- `unique` tests: while dbt-bigquery doesn't support SQL-level unique constraints, dbt tests allow asserting uniqueness on model build.
- `not_null` constraints via dbt contracts to enforce strict schema integrity: this ensures that table builds will fail if required fields are missing or null.

These additions showcase how dbt can be used not just for transformation but also for validating and enforcing business logic and structure at runtime.

---

## 📊 Power BI Dashboard

Power BI was used in import mode to add `pbi_rts_interview.pbix` in the repository, allowing users to access dashboards without having to run the project from scratch.

### Relations
Power BI automatically detected relationships based on foreign keys due to the clean star schema structure.

### Key Insights & Visuals

#### 1. RTS - Overview of events data
- Total of events
- Total of sessions
- World map with visualization of number of sessions in every country
- Top 3 of content type

#### 2. Behavior in Switzerland
- Average duration of a session (did not manage to make it work in the given time, it does not change when we apply filters)
- Histogram giving the number of sessions in Switzerland for each hour of the day (extracted from the event_arrival_time_cet)
- Donut chart with the languages