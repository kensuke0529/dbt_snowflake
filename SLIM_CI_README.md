# dbt Slim CI Setup

## Overview
This repository uses **dbt Slim CI** to run only modified models in pull requests, saving time and compute costs.

## How It Works

1. **Production State**: The `ecommerce_pipeline/state/manifest.json` file contains a snapshot of production
2. **PR Triggers**: When you create a PR, GitHub Actions compares your changes to production
3. **Smart Selection**: Only runs `dbt run --select state:modified+` (changed models + downstream)
4. **Fast Feedback**: PRs complete in minutes instead of running everything

## Workflow File
`.github/workflows/slim_ci.yml` - Automatically runs on PRs to main branch

## GitHub Secrets Required

Add these to: **Settings → Secrets and variables → Actions**

- `SNOWFLAKE_ACCOUNT`
- `SNOWFLAKE_USER`  
- `SNOWFLAKE_PASSWORD`
- `SNOWFLAKE_ROLE`
- `SNOWFLAKE_DATABASE`
- `SNOWFLAKE_WAREHOUSE`

## Testing Locally

Before creating a PR, test state selectors locally:

```bash
# See what would run
dbt list --select state:modified+ --state ./state

# Run only modified models
dbt run --select state:modified+ --defer --state ./state

# Test only modified models
dbt test --select state:modified+ --defer --state ./state
```

## Creating a Test PR

```bash
# Create test branch
git checkout -b test-slim-ci

# Make a change to any model
# (e.g., add a comment to a SQL file)

# Commit and push
git add .
git commit -m "Test: Slim CI workflow"
git push origin test-slim-ci

# Create PR on GitHub
# Watch the workflow run only changed models!
```

## Updating Production State

When merging to main, update the manifest:

```bash
git checkout main
git pull
cd ecommerce_pipeline
dbt compile
cp target/manifest.json state/manifest.json
git add state/manifest.json
git commit -m "Update production manifest"
git push
```

## Troubleshooting

**No models run in CI?**
- Check if manifest.json exists in main branch
- Verify your changes actually modified a model

**All models run instead of slim?**
- Manifest might be missing from main branch
- Check CI logs for "No production manifest" warning

**CI fails with credential errors?**
- Verify all GitHub secrets are set correctly
- Check warehouse/database names match

## Benefits

- ⚡ **Faster PRs**: Run only what changed
- 💰 **Lower costs**: Less warehouse compute
- 🐛 **Easier debugging**: Smaller test scope
- ✅ **Better reviews**: Clear what's affected
