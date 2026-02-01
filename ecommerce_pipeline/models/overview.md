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