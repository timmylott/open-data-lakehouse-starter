# Data Platform Notebooks

This directory contains operational notebooks organized by purpose.

## Directory Structure

```
notebooks/
├── runbooks/          # Incident response and troubleshooting
├── playbooks/         # Scheduled operational procedures
├── examples/          # Customer-facing query examples
├── customer-support/  # Customer issue investigation tools
├── development/       # Prototype and testing notebooks
└── 01-storage-layer-test.ipynb  # Phase 1 validation
```

## Runbooks (Incident Response)

**Purpose**: Quick response guides for production issues

**When to use**: 
- Customer reports a problem
- Alert fires
- Data quality issue detected
- System behavior is unexpected

**Available runbooks**:
- `investigate-missing-data.ipynb` - When data doesn't appear in pipeline
- `schema-drift-detection.ipynb` - Check for unexpected schema changes

**Usage**:
1. Open the relevant runbook
2. Fill in PARAMETERS section at the top
3. Run cells sequentially
4. Document findings in the Resolution section
5. Save notebook with incident details

## Playbooks (Scheduled Operations)

**Purpose**: Regular operational tasks and audits

**When to use**:
- Monthly/quarterly reviews
- Scheduled reconciliations
- Routine maintenance
- Performance analysis

**Available playbooks**:
- `monthly-reconciliation.ipynb` - Compare source vs warehouse data

**Usage**:
1. Schedule to run on specific dates
2. Can be automated with Papermill
3. Results can be exported as reports
4. Track trends over time

## Examples (Customer Reference)

**Purpose**: Show customers how to use their data

**When to use**:
- Customer onboarding
- Training materials
- Documentation
- Self-service analytics

**Examples**:
- Query patterns
- Common analytics tasks
- API usage
- Best practices

## Customer Support

**Purpose**: Investigate specific customer issues

**When to use**:
- Customer reports data discrepancy
- Customer requests data validation
- Account-specific troubleshooting

**Features**:
- Customer-specific queries
- Data validation tools
- Issue documentation
- Resolution tracking

## Development

**Purpose**: Prototype new features and test transformations

**When to use**:
- Testing new dbt models
- Exploring new data sources
- Prototype APIs
- Performance testing

**Not for**: Production code (move to proper scripts/dbt when ready)

## Best Practices

### 1. Always Use PARAMETERS Sections
```python
# PARAMETERS - Update these
CUSTOMER_ID = "ABC123"
START_DATE = "2024-01-01"
TABLE_NAME = "orders"
```

### 2. Document as You Go
Use markdown cells to explain:
- What you're checking
- What you found
- What you did to fix it

### 3. Name Notebooks Descriptively
- ✅ `investigate-missing-orders-2024-02.ipynb`
- ❌ `untitled-notebook-1.ipynb`

### 4. Version Control
- Commit completed runbooks with findings
- Template runbooks should have empty findings
- Use `.gitignore` for temporary notebooks

### 5. Keep Spark Sessions Clean
```python
# At start of notebook
spark = SparkSession.builder.appName("DescriptiveName").getOrCreate()

# At end (optional for long-running investigations)
spark.stop()
```

### 6. Security
- Never commit credentials
- Use environment variables or Vault
- Mask sensitive customer data in screenshots

## Converting Notebooks to Production

When a notebook proves a solution:

1. **Extract the logic** to proper Python modules
2. **Move SQL to dbt** if it's a transformation
3. **Create Airflow DAG** if it needs scheduling
4. **Document** in runbook how to monitor
5. **Keep notebook** as reference/troubleshooting guide

## Automation with Papermill

Playbooks can be automated:

```python
import papermill as pm

pm.execute_notebook(
    'playbooks/monthly-reconciliation.ipynb',
    'output/reconciliation-2024-02.ipynb',
    parameters=dict(
        RECONCILIATION_MONTH='2024-02',
        TABLES_TO_CHECK=['customers', 'orders', 'transactions']
    )
)
```

## Tools Integration

These notebooks work with:
- **Spark** - Query Iceberg tables
- **Nessie** - Access different branches/versions
- **MinIO** - Read/write to object storage
- **Airflow** - Can trigger notebook execution
- **Grafana** - Link to notebooks from alerts

## Support

For questions about:
- **Runbook usage** - Ask the data engineering team
- **Adding new runbooks** - Submit PR with template
- **Customer access** - Contact platform admin
- **Automation** - See Airflow documentation

## Contributing

To add a new runbook/playbook:

1. Copy existing template
2. Update metadata and parameters
3. Test with real data
4. Document in this README
5. Commit with descriptive message

## Jupyter Tips

**Keyboard Shortcuts**:
- `Shift + Enter` - Run cell
- `Esc + A` - Insert cell above
- `Esc + B` - Insert cell below
- `Esc + DD` - Delete cell
- `Esc + M` - Convert to markdown
- `Esc + Y` - Convert to code

**Magic Commands**:
- `%time` - Time single statement
- `%%time` - Time entire cell
- `%matplotlib inline` - Display plots
- `!ls` - Run shell command

**Restart Kernel**: Kernel → Restart Kernel (when things get stuck)

---

**Last Updated**: February 2026  
**Maintained By**: Data Engineering Team
