# S3 to Snowflake Incremental Ingestion Guide

## Overview

This pipeline incrementally loads event data from S3 into Snowflake using dbt. Data is written by Lambda every 5 minutes to `s3://ecommerce-streaming-data-0001/raw-events/` in gzipped JSON format.

## Architecture

```
S3 Bucket (raw-events/)
    ↓
External Stage (s3_raw_events_stage)
    ↓
dbt Model: raw_events_from_s3.sql
    ↓
RAW_EVENTS Table
    ↓
dbt Model: stg_events.sql
    ↓
STG_EVENTS Table (transformed)
```

## Setup (One-Time)

### 1. Run Snowflake Setup Script

Execute the SQL script to create the necessary Snowflake objects:

```bash
# In Snowflake UI or SnowSQL, run:
setup_s3_ingestion.sql
```

This creates:
- File format: `json_gzip_format`
- External stage: `s3_raw_events_stage`
- Table: `RAW_EVENTS`

### 2. Verify Setup

```sql
-- List files in S3 (should show your .gz files)
LIST @s3_raw_events_stage;

-- Test reading from S3
SELECT 
  $1 as event_data,
  metadata$filename as source_file
FROM @s3_raw_events_stage
LIMIT 5;
```

## Running the Pipeline

### Initial Load (First Time)

```bash
# Load all historical data from S3
dbt run --select raw_events_from_s3

# Transform the raw data
dbt run --select stg_events
```

### Incremental Loads (Ongoing)

Run this every 5-15 minutes (or however often you want to sync):

```bash
# Load only new files and transform new events
dbt run --select raw_events_from_s3 stg_events
```

Or simply:

```bash
dbt run
```

## How It Works

### Step 1: Load from S3 (`raw_events_from_s3.sql`)

- Reads from external stage `@s3_raw_events_stage`
- Tracks which files have been processed using `source_file` column
- Only loads files not yet in `RAW_EVENTS` table
- Stores raw JSON in `event_data` column

### Step 2: Transform (`stg_events.sql`)

- Reads from `RAW_EVENTS` table
- Parses JSON into structured columns
- Uses `append` strategy (no merge overhead)
- Filters for events with `event_at > max(event_at)` from existing data

## Data Flow Example

**S3 File Structure:**
```
s3://ecommerce-streaming-data-0001/raw-events/
  2026/01/29/01/events_001.json.gz
  2026/01/29/01/events_002.json.gz
  2026/01/29/02/events_003.json.gz
```

**First Run:**
- Loads all 3 files into `RAW_EVENTS`
- Transforms all events into `STG_EVENTS`

**Second Run (5 minutes later):**
- New file: `2026/01/29/02/events_004.json.gz`
- Only loads `events_004.json.gz` (others already in `RAW_EVENTS`)
- Only transforms events newer than existing max timestamp

## Scheduling

### Option 1: dbt Cloud
- Create a job that runs every 5-15 minutes
- Command: `dbt run --select raw_events_from_s3 stg_events`

### Option 2: Airflow/Cron
```python
# Airflow DAG example
from airflow import DAG
from airflow.operators.bash import BashOperator

dag = DAG('s3_to_snowflake', schedule_interval='*/5 * * * *')  # Every 5 min

load_task = BashOperator(
    task_id='load_from_s3',
    bash_command='cd /path/to/dbt && dbt run --select raw_events_from_s3 stg_events',
    dag=dag
)
```

### Option 3: Manual
```bash
# Run manually whenever you want to sync
dbt run
```

## Monitoring

### Check Load Status

```sql
-- How many files have been loaded?
SELECT COUNT(DISTINCT source_file) as files_loaded
FROM DBT_DEMO_SNOWFLAKE.DBT.RAW_EVENTS;

-- Latest file loaded
SELECT MAX(source_file) as latest_file, MAX(loaded_at) as loaded_at
FROM DBT_DEMO_SNOWFLAKE.DBT.RAW_EVENTS;

-- Event count by date
SELECT 
    DATE(event_at) as event_date,
    COUNT(*) as event_count
FROM DBT_DEMO_SNOWFLAKE.DBT.STG_EVENTS
GROUP BY 1
ORDER BY 1 DESC;
```

### Check for Gaps

```sql
-- Files in S3 vs files loaded
LIST @s3_raw_events_stage;  -- Compare with RAW_EVENTS.source_file
```

## Troubleshooting

### Issue: "Stage not found"
**Solution:** Run `setup_s3_ingestion.sql` first

### Issue: "No files found in stage"
**Solution:** 
- Verify S3 path: `LIST @s3_raw_events_stage;`
- Check storage integration permissions
- Verify Lambda is writing to correct S3 path

### Issue: "Duplicate key error"
**Solution:** 
- This means the same file is being loaded twice
- Check if `source_file` values are unique
- The primary key constraint prevents duplicates

### Issue: "JSON parsing errors"
**Solution:**
- Verify file format is correct (gzip + JSON)
- Check a sample file: `SELECT $1 FROM @s3_raw_events_stage LIMIT 1;`
- Adjust `stg_events.sql` JSON paths if structure changed

### Issue: "No new data loaded"
**Solution:**
- Check if Lambda is writing new files: `LIST @s3_raw_events_stage;`
- Verify incremental filter: `SELECT MAX(event_at) FROM STG_EVENTS;`
- Run with `--full-refresh` to reload everything

## Full Refresh

To reload all data from scratch:

```bash
# Clear existing data and reload everything
dbt run --select raw_events_from_s3 --full-refresh
dbt run --select stg_events --full-refresh
```

## Performance Tips

1. **Partition pruning**: S3 path includes date partitions (`/2026/01/29/`)
2. **File tracking**: Primary key prevents duplicate processing
3. **Append strategy**: Faster than merge for append-only data
4. **Timestamp filter**: Only processes new events in `stg_events`

## Next Steps

- Add data quality tests in `schema.yml`
- Create downstream mart models
- Set up alerting for failed runs
- Monitor costs (Snowflake compute + S3 API calls)
