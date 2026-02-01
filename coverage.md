# dbt Analytics Engineering Certification - Coverage & Implementation Guide




## ✅ What I've Implemented

### 1. Core dbt Models ✓

**Status**: Strong foundation established

#### Evidence in My Project:
- ✅ **View materialization**: [`stg_events.sql`](ecommerce_pipeline/models/staging/stg_events.sql)
- ✅ **Table materialization**: [`fct_orders.sql`](ecommerce_pipeline/models/marts/fct_orders.sql)
- ✅ **Incremental materialization**: [`raw_events_from_s3.sql`](ecommerce_pipeline/models/staging/raw_events_from_s3.sql)
  - Using unique_key strategy
  - File tracking with `metadata$filename`
  - Conditional logic with `is_incremental()`

---

### 2. Configuration Management ✓

**Status**: Configurations in place

#### dbt_project.yml:
```yaml
models:
  ecommerce_pipeline:
    +materialized: view
    staging:
      +materialized: view
    marts:
      +materialized: table
```

#### Source Configuration:
[`source_data.yml`](ecommerce_pipeline/models/staging/source/source_data.yml) - S3 bucket source with freshness checks

---

### 3. dbt Packages ✓

**Status**: Using community packages

#### Current Packages:
```yaml
# packages.yml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.3.3
  - package: metaplane/dbt_expectations
    version: 0.10.10
```

---

### 4. Testing ✓

**Status**: Generic, singular, and custom tests implemented

#### Generic Tests:
- `not_null` on event_at, event_id, session_id, customer_id, total_orders, total_spent, last_order_date
- `unique` on event_id, session_id, customer_id

#### Singular Tests:
- [`order_is_positive.sql`](ecommerce_pipeline/tests/order_is_positive.sql) - Order validation

#### Custom Generic Tests:
- ✅ [`event_at_is_valid.sql`](ecommerce_pipeline/tests/generic/event_at_is_valid.sql) - Date validation test
- ✅ Doc blocks: [`event_at_validatoin.md`](ecommerce_pipeline/tests/docs/event_at_validatoin.md)

---

### 5. Model Governance ✓ (Partial)

**Status**: Contracts implemented, versions and access controls pending

#### Model Contracts:
- ✅ [`stg_events`](ecommerce_pipeline/models/staging/schema.yml) - Contract enforced with data types and constraints

---

### 6. Source Freshness ✓

**Status**: Freshness monitoring configured

#### Freshness Configuration:
- ✅ [`source_data.yml`](ecommerce_pipeline/models/staging/source/source_data.yml)
  - warn_after: 1 hour
  - error_after: 1 day

---

### 7. Documentation ✓ (Partial)

**Status**: Partial documentation in place

#### Documentation:
- ✅ Model descriptions for intermediate models
- ✅ Column descriptions for [`int_customer_purchase_history`](ecommerce_pipeline/models/intermediate/schema.yml)
- ✅ Project overview: [`overview.md`](ecommerce_pipeline/models/overview.md)
- ✅ Doc blocks for custom tests
- ✅ **dbt docs generated and served** (currently running)

---

### 8. SQL Transformations ✓

**Status**: Business logic properly implemented

- JSON parsing from S3 events
- Data flattening and type casting
- Customer dimension building
- Order aggregations
- Intermediate models for purchase history

---

## ❌ What's Missing

### 1. Model Governance (1/3) � HIGH PRIORITY

| Feature | Status | Exam Weight |
|---------|--------|-------------|
| Contracts | ✅ Implemented (stg_events) | HIGH |
| Model Versions | ❌ Not implemented | HIGH |
| Access Controls | ❌ Not implemented | MEDIUM |

**Impact**: Need versions and access controls to complete governance

---

### 2. Python Models (0/1) 🔴 CRITICAL

| Feature | Status | Exam Weight |
|---------|--------|-------------|
| Python model | ❌ Not implemented | HIGH |

**Impact**: Required certification topic

---

### 3. Documentation (4/6) � GOOD PROGRESS

| Feature | Status | Exam Weight |
|---------|--------|-------------|
| Model descriptions | ✅ Implemented (intermediate) | HIGH |
| Column descriptions | ✅ Implemented (intermediate) | HIGH |
| Source descriptions | ❌ Not implemented | MEDIUM |
| Doc blocks | ✅ Implemented (tests) | MEDIUM |
| dbt docs generated | ✅ Running | HIGH |
| Project overview | ✅ Created | MEDIUM |

**Impact**: Need to add staging and marts descriptions

---

### 4. Source Freshness (1/1) ✅ COMPLETE

| Feature | Status | Exam Weight |
|---------|--------|-------------|
| Freshness config | ✅ Implemented | HIGH |
| Freshness tests | ✅ Can run | MEDIUM |

**Status**: ✅ Complete

---

### 5. Advanced Testing (4/5) � GOOD PROGRESS

| Feature | Status | Exam Weight |
|---------|--------|-------------|
| Generic tests | ✅ Implemented | - |
| Singular tests | ✅ Implemented | - |
| Custom generic tests | ✅ Implemented (event_at_is_valid) | MEDIUM |
| Source tests | ❌ Not implemented | MEDIUM |
| Relationship tests | ❌ Not implemented | MEDIUM |

**Impact**: Need relationship tests for FK validation

---

### 6. Exposures (0/1) 🟡 MEDIUM PRIORITY

| Feature | Status | Exam Weight |
|---------|--------|-------------|
| Exposure definitions | ❌ Not implemented | MEDIUM |

---

### 7. dbt State (0/3) 🔴 CRITICAL

| Feature | Status | Exam Weight |
|---------|--------|-------------|
| State selectors | ❌ Not used | HIGH |
| dbt retry | ❌ Not used | HIGH |
| Slim CI | ❌ Not implemented | MEDIUM |

**Impact**: Essential for production workflows

---

### 8. Other Gaps 🟢 LOW PRIORITY

- ❌ Grants configuration
- ❌ Custom macros (DRY improvements)
- ❌ dbt clone usage
- ❌ Snapshots (directory empty)
- ❌ Seeds (directory empty)

---

## 🛠️ Implementation Suggestions

### Priority 1: Model Contracts (HIGH)

**What**: Enforce data types and column presence

**Implementation**:

1. Update [`models/marts/schema.yml`](ecommerce_pipeline/models/marts/) (create if needed):

```yaml
version: 2

models:
  - name: dim_customers
    description: "Customer dimension table"
    config:
      contract:
        enforced: true
    columns:
      - name: customer_id
        data_type: integer
        description: "Unique customer identifier"
        constraints:
          - type: not_null
          - type: primary_key
      - name: customer_email
        data_type: varchar
        constraints:
          - type: not_null
      - name: total_orders
        data_type: integer
      - name: total_spent
        data_type: float

  - name: fct_orders
    description: "Order fact table"
    config:
      contract:
        enforced: true
    columns:
      - name: order_id
        data_type: varchar
        constraints:
          - type: not_null
          - type: primary_key
      - name: customer_id
        data_type: integer
        constraints:
          - type: not_null
          - type: foreign_key
            to: ref('dim_customers')
            to_columns: [customer_id]
      - name: revenue
        data_type: float
      - name: ordered_at
        data_type: timestamp_ntz
```

**Test**: Run `dbt run --select dim_customers fct_orders` - should enforce schema

---

### Priority 2: Model Versions (HIGH)

**What**: Create versioned models with deprecation

**Implementation**:

1. Create [`models/marts/fct_orders_v1.sql`](ecommerce_pipeline/models/marts/fct_orders_v1.sql):
   - Rename current `fct_orders.sql` to `fct_orders_v1.sql`

2. Create [`models/marts/fct_orders_v2.sql`](ecommerce_pipeline/models/marts/fct_orders_v2.sql):

```sql
{{config(
    materialized='table',
    version=2
)}}

-- v2: Added calculated fields and improved performance
with orders as (
    select * from {{ ref('stg_events') }}
    where event_type = 'order_fulfilled'
),

sessions as (
    select * from {{ ref('int_session_events') }}
),

final as (
    select
        o.order_id,
        o.customer_id,
        o.event_at as ordered_at,
        o.total_amount as revenue,
        o.tax_amount,
        o.shipping_amount,
        -- NEW in v2: calculated fields
        o.total_amount - o.tax_amount - o.shipping_amount as net_revenue,
        round(o.tax_amount / nullif(o.total_amount, 0), 4) as tax_rate,
        s.session_id,
        s.acquisition_channel,
        s.device_type,
        current_timestamp() as dbt_updated_at
    from orders o
    left join sessions s on o.session_id = s.session_id
)

select * from final
```

3. Update [`models/marts/schema.yml`](ecommerce_pipeline/models/marts/schema.yml):

```yaml
models:
  - name: fct_orders
    latest_version: 2
    description: "Order fact table"
    
    versions:
      - v: 1
        deprecated_at: 2026-02-01
        description: "Original version - deprecated"
      
      - v: 2
        description: "Enhanced with calculated fields"
        columns:
          - name: net_revenue
            description: "Revenue minus taxes and shipping"
          - name: tax_rate
            description: "Tax as percentage of total"
```

---

### Priority 3: Model Access Controls (HIGH)

**What**: Define which models can reference others

**Implementation**:

Update [`models/staging/schema.yml`](ecommerce_pipeline/models/staging/schema.yml):

```yaml
version: 2

models:
  - name: stg_events
    access: public  # Can be referenced by any model
    description: "Cleaned and parsed event data from S3"
    
  - name: raw_events_from_s3
    access: private  # Only accessible within staging
    description: "Raw S3 ingestion - internal use only"
```

Update [`models/intermediate/schema.yml`](ecommerce_pipeline/models/intermediate/schema.yml):

```yaml
models:
  - name: int_session_events
    access: protected  # Only for same project
    
  - name: int_customer_purchase_history
    access: public  # Available to marts
```

---

### Priority 4: Source Freshness (HIGH)

**What**: Monitor data freshness from S3

**Implementation**:

Update [`models/staging/src_events.yml`](ecommerce_pipeline/models/staging/src_events.yml):

```yaml
version: 2

sources:
  - name: s3_bucket
    description: "E-commerce event data from S3"
    database: DBT_DEMO_SNOWFLAKE
    schema: DBT
    
    # Freshness configuration
    freshness:
      warn_after: {count: 6, period: hour}
      error_after: {count: 12, period: hour}
    
    tables:
      - name: RAW_EVENTS
        description: "Raw event stream from Lambda to S3"
        loaded_at_field: loaded_at  # timestamp column
        
        freshness:
          warn_after: {count: 3, period: hour}
          error_after: {count: 6, period: hour}
        
        columns:
          - name: event_data
            description: "JSON payload with event details"
            tests:
              - not_null
          
          - name: source_file
            description: "S3 file name"
          
          - name: loaded_at
            description: "Timestamp when data was loaded"
            tests:
              - not_null
```

**Test**: Run `dbt source freshness`

---

### Priority 5: Python Model (HIGH)

**What**: Create ML features or data quality checks in Python

**Implementation**:

Create [`models/marts/py_customer_segmentation.py`](ecommerce_pipeline/models/marts/py_customer_segmentation.py):

```python
import pandas as pd
import numpy as np

def model(dbt, session):
    """
    Customer segmentation using RFM (Recency, Frequency, Monetary) analysis
    """
    # Config
    dbt.config(
        materialized="table",
        packages=["pandas", "numpy"]
    )
    
    # Load customer purchase history
    customer_history_df = dbt.ref("int_customer_purchase_history").to_pandas()
    
    # Calculate RFM scores
    customer_history_df['recency_days'] = (
        pd.Timestamp.now() - pd.to_datetime(customer_history_df['last_order_date'])
    ).dt.days
    
    # Quartile-based scoring (1-4, where 4 is best)
    customer_history_df['r_score'] = pd.qcut(
        customer_history_df['recency_days'], 
        q=4, 
        labels=[4, 3, 2, 1]  # Reverse: lower recency = better
    )
    
    customer_history_df['f_score'] = pd.qcut(
        customer_history_df['total_orders'].rank(method='first'), 
        q=4, 
        labels=[1, 2, 3, 4]
    )
    
    customer_history_df['m_score'] = pd.qcut(
        customer_history_df['total_spent'].rank(method='first'), 
        q=4, 
        labels=[1, 2, 3, 4]
    )
    
    # Create RFM segment
    customer_history_df['rfm_score'] = (
        customer_history_df['r_score'].astype(str) + 
        customer_history_df['f_score'].astype(str) + 
        customer_history_df['m_score'].astype(str)
    )
    
    # Assign segment labels
    def assign_segment(row):
        score_sum = int(row['r_score']) + int(row['f_score']) + int(row['m_score'])
        if score_sum >= 10:
            return 'Champions'
        elif score_sum >= 8:
            return 'Loyal Customers'
        elif score_sum >= 6:
            return 'Potential Loyalists'
        elif score_sum >= 5:
            return 'At Risk'
        else:
            return 'Lost'
    
    customer_history_df['segment'] = customer_history_df.apply(assign_segment, axis=1)
    
    return customer_history_df[[
        'customer_id',
        'recency_days',
        'r_score',
        'f_score', 
        'm_score',
        'rfm_score',
        'segment'
    ]]
```

---

### Priority 6: Complete Documentation (HIGH)

**Implementation**:

1. **Add comprehensive descriptions** to all existing schema files

2. **Create project overview**: [`models/overview.md`](ecommerce_pipeline/models/overview.md)

```markdown
{% docs __overview__ %}

# E-commerce Analytics Pipeline

## Project Overview
This dbt project processes e-commerce event data from S3/Lambda and builds
dimensional models for analytics.

## Data Flow
1. **Source**: Events stream from Lambda → S3
2. **Staging**: Parse JSON, clean, and type-cast
3. **Intermediate**: Session aggregation and customer history
4. **Marts**: Fact tables and dimensions for BI tools

## Key Models
- `dim_customers` - Customer dimension
- `fct_orders` - Order transactions
- `fct_order_items` - Line-item details

{% enddocs %}
```

3. **Create doc blocks for complex logic**: Add to models

```sql
{% docs incremental_strategy %}
This model uses incremental loading based on file tracking.
Only new files from S3 are processed on each run.
{% enddocs %}
```

4. **Generate and serve docs**:
```bash
dbt docs generate
dbt docs serve
```

---

### Priority 7: Custom Generic Test (MEDIUM)

**What**: Reusable test for data quality

**Implementation**:

Create [`tests/generic/test_valid_email.sql`](ecommerce_pipeline/tests/generic/test_valid_email.sql):

```sql
{% test valid_email(model, column_name) %}

select {{ column_name }}
from {{ model }}
where {{ column_name }} is not null
  and {{ column_name }} not like '%_@__%.__%'

{% endtest %}
```

**Usage**: Update schema file

```yaml
columns:
  - name: customer_email
    tests:
      - valid_email
```

---

### Priority 8: Relationship Tests (MEDIUM)

**Implementation**:

Update [`models/marts/schema.yml`](ecommerce_pipeline/models/marts/schema.yml):

```yaml
models:
  - name: fct_orders
    columns:
      - name: customer_id
        tests:
          - relationships:
              to: ref('dim_customers')
              field: customer_id
              severity: error
      
      - name: session_id
        tests:
          - relationships:
              to: ref('int_session_events')
              field: session_id
              severity: warn
```

---

### Priority 9: Exposures (MEDIUM)

**What**: Document downstream BI dashboards

**Implementation**:

Create [`models/exposures.yml`](ecommerce_pipeline/models/exposures.yml):

```yaml
version: 2

exposures:
  - name: revenue_dashboard
    type: dashboard
    maturity: high
    owner:
      name: Analytics Team
      email: analytics@company.com
    
    description: |
      Executive revenue dashboard showing:
      - Daily/monthly revenue trends
      - Revenue by channel
      - Top customers
    
    depends_on:
      - ref('fct_orders')
      - ref('dim_customers')
    
    url: https://bi-tool.com/dashboards/revenue
    
  - name: customer_segmentation_report
    type: analysis
    maturity: medium
    owner:
      name: Marketing Team
      email: marketing@company.com
    
    description: "RFM customer segmentation for targeted campaigns"
    
    depends_on:
      - ref('py_customer_segmentation')
```

---

### Priority 10: dbt State & Selectors (CRITICAL)

**What**: Efficient CI/CD and selective runs

**Implementation**:

1. **Generate state artifacts**:
```bash
# Production run - save state
dbt run --target prod
dbt docs generate --target prod

# Copy manifest to state directory
mkdir -p ./state
cp target/manifest.json ./state/
```

2. **Use state selectors**:

```bash
# Run only modified models and downstream dependencies
dbt run --select state:modified+

# Test only modified models
dbt test --select state:modified

# Build new models only
dbt run --select state:new+
```

3. **Use dbt retry** after failures:

```bash
# After a failed run, retry only failed models
dbt retry
```

4. **Slim CI setup**: Create [`.github/workflows/slim_ci.yml`](.github/workflows/slim_ci.yml)

```yaml
name: dbt Slim CI

on:
  pull_request:
    branches: [main]

jobs:
  slim-ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Download production manifest
        run: |
          # Download from dbt Cloud or S3
          mkdir -p ./state
          # aws s3 cp s3://artifacts/manifest.json ./state/
      
      - name: Run dbt on changed models only
        run: |
          dbt run --select state:modified+ --defer --state ./state
          dbt test --select state:modified+ --defer --state ./state
```

---

### Priority 11: Grants Configuration (LOW)

**Implementation**:

```sql
-- In model config
{{ config(
    materialized='table',
    grants={
      'select': ['analyst_role', 'reporting_role'],
      'insert': ['etl_role']
    }
) }}
```

Or in `dbt_project.yml`:

```yaml
models:
  ecommerce_pipeline:
    marts:
      +grants:
        select: ['analyst_role']
```

---

### Priority 12: Custom Macros (LOW)

**What**: DRY principle improvements

**Implementation**:

Create [`macros/cents_to_dollars.sql`](ecommerce_pipeline/macros/cents_to_dollars.sql):

```sql
{% macro cents_to_dollars(column_name, precision=2) %}
    round({{ column_name }} / 100.0, {{ precision }})
{% endmacro %}
```

**Usage**:
```sql
select
    order_id,
    {{ cents_to_dollars('amount_cents') }} as amount_dollars
from orders
```

---

## 📅 Week-by-Week Plan

### Week 1: Governance & State (Critical Gaps)
- [ ] Day 1-2: Implement model contracts on 2 models
- [ ] Day 3: Create model version (v1 → v2)
- [ ] Day 4: Add access controls (public/private/protected)
- [ ] Day 5: Set up dbt state and practice selectors
- [ ] Day 6-7: Practice `dbt retry` and state:modified

**Deliverable**: Governance features working, state-based runs functional

---

### Week 2: Documentation & Freshness
- [ ] Day 1-2: Add descriptions to ALL models and columns
- [ ] Day 3: Add source descriptions and freshness config
- [ ] Day 4: Run `dbt source freshness` successfully
- [ ] Day 5: Generate and review `dbt docs`
- [ ] Day 6: Create doc blocks for complex logic
- [ ] Day 7: Create project overview.md

**Deliverable**: Complete, generated documentation

---

### Week 3: Python Models & Testing
- [ ] Day 1-2: Create Python model (RFM segmentation)
- [ ] Day 3: Create custom generic test
- [ ] Day 4: Add relationship tests
- [ ] Day 5: Add source tests
- [ ] Day 6-7: Define exposures

**Deliverable**: Python model running, comprehensive test coverage

---

### Week 4: Production Readiness & Practice
- [ ] Day 1-2: Add grants configuration
- [ ] Day 3: Create custom macros
- [ ] Day 4: Practice dbt clone
- [ ] Day 5-6: Mock exam scenarios
- [ ] Day 7: Review all topics

**Deliverable**: Certification ready

---

## ✅ Completion Checklist

### Developing dbt Models
- [x] View, table, incremental materializations
- [x] Incremental strategies (file tracking)
- [x] dbt_project.yml configurations
- [x] Source configuration
- [x] dbt Packages (dbt_utils, dbt_expectations)
- [x] DAG structure (staging → intermediate → marts)
- [ ] **Custom macros**
- [ ] **Python models**
- [ ] **Grants configuration**

### Model Governance
- [x] **Model contracts** (stg_events)
- [ ] **Model versioning**
- [ ] **Model access controls**

### Testing
- [x] Generic tests (not_null, unique)
- [x] Singular tests (order_is_positive)
- [x] **Custom generic tests** (event_at_is_valid)
- [ ] **Source tests**
- [ ] **Relationship tests**

### Documentation
- [x] Some model descriptions (intermediate complete)
- [/] **Complete model descriptions** (staging and marts pending)
- [/] **Complete column descriptions** (intermediate done, others pending)
- [ ] **Source descriptions**
- [x] **dbt docs generate** (currently running)
- [x] **Doc blocks** (test documentation)
- [x] **Project overview**

### External Dependencies
- [x] **Source freshness**
- [ ] **Exposures**

### dbt State
- [ ] **State selectors**
- [ ] **dbt retry**
- [ ] **Slim CI**

### Other
- [ ] **dbt clone**
- [ ] Snapshots (optional)
- [ ] Seeds (optional)

---

## 🎯 Quick Wins (Do These Next!)

1. ✅ ~~**Source Freshness**~~ - Complete
2. ✅ ~~**Model Contracts**~~ - Complete (stg_events)
3. ✅ ~~**Custom Generic Test**~~ - Complete (event_at_is_valid)
4. **Relationship Tests** (15 min) - FK test from orders to customers
5. **Model Contracts for Marts** (30 min) - Add to `dim_customers` and `fct_orders`
6. **Model Versioning** (30 min) - Create v1 → v2 for one model
7. **Complete Documentation** (1 hour) - Add descriptions to staging and marts
8. **Exposure** (15 min) - Document 1 BI dashboard

**Estimated Time for Remaining Quick Wins**: ~2.5 hours → Will bring you to ~65% complete

---

## 📊 Progress Tracker

| Topic | Completion | Last Updated |
|-------|-----------|-----------------|
| Model Development | 70% | 2026-01-31 |
| Model Governance | 35% | 2026-01-31 |
| Testing | 80% | 2026-01-31 |
| Documentation | 65% | 2026-01-31 |
| External Dependencies | 50% | 2026-01-31 |
| dbt State | 0% | - |
| Python Models | 0% | - |
| **OVERALL** | **~55%** | **2026-01-31** |

---

## 🔗 Resources

- [dbt Docs](https://docs.getdbt.com)
- [dbt Contracts](https://docs.getdbt.com/docs/collaborate/govern/model-contracts)
- [dbt Versions](https://docs.getdbt.com/docs/collaborate/govern/model-versions)
- [dbt State](https://docs.getdbt.com/reference/node-selection/syntax)
- [dbt Python Models](https://docs.getdbt.com/docs/build/python-models)
- [Analytics Engineering Certification](https://www.getdbt.com/certifications/analytics-engineer)

---

**Next Action**: Add relationship tests and complete documentation for staging/marts models. Then implement Python models and model versioning!
