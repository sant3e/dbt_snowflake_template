# DBT Project - Developer Setup Instructions

**If you're joining an existing project, follow these steps to get up and running:**

## Prerequisites

Before starting, ensure you have the following installed on your local machine:
- **Docker Desktop** (for containerization)
- **VSCode** with the "Dev Containers" extension
- **Git** (for version control)

### Check if Git is installed and configured:

```bash
git --version
```

```bash
git config --global user.name
```

```bash
git config --global user.email
```

If Git is not installed or configured, follow these steps:

**Install Git:**
- **Windows**: Download from [git-scm.com](https://git-scm.com/download/win)
- **macOS**: `brew install git` or download from [git-scm.com](https://git-scm.com/download/mac)
- **Linux**: `sudo apt-get install git` (Ubuntu/Debian) or equivalent for your distribution

**Configure Git:**

```bash
git config --global user.name "Your Name"
```

```bash
git config --global user.email "your.email@booking.com"
```

## Setup Instructions

### 1. Clone the Repository

```bash
git clone git@gitlab.com:..url../project_name.git
```

```bash
cd project_name
```

**Note**: Once your request for GIT Passport Policy is approved, you should receive a link to your project's repo. Using the `Code` button, copy the "Clone with HTTPS" url and replace in the clone command.

If SSH doesn't work, use HTTPS with Personal Access Token:

```bash
git clone https://gitlab.com/booking-com/personal/username/project_name.git
```

### 2. Open in VSCode and Setup Container

```bash
code .
```

- VSCode will detect the `.devcontainer` configuration
- Click "Reopen in Container" when prompted
- VSCode will automatically build the container and install all extensions
- Wait for the container to build (this may take a few minutes on first run)

### 3. Create Your Personal Environment File

```bash
cp .env.example .env
```

### 4. Configure Your Snowflake Credentials

**This is the most critical step!** Edit your `.env` file with your actual Snowflake credentials:

```bash
nano .env
```

**Required Configuration:**
Replace the placeholder values with your actual Snowflake information:

```env
# === Snowflake Base Configuration ===
SF_BASE_ACCOUNT=your_actual_snowflake_account_locator
SF_BASE_WAREHOUSE=your_default_compute_warehouse

# === Local Development Configuration ===
SF_USER_USERNAME=your_snowflake_username
SF_USER_ROLE=your_snowflake_development_role
SF_USER_DATABASE=your_development_database_name
SF_USER_SCHEMA=PUBLIC

**Choose ONE authentication method:**

#### Option A: Password Authentication (Simplest)
###Uncomment and fill in:
# SF_USER_PASSWORD=your_snowflake_password

#### Option B: SSO Authentication (Recommended for Enterprise)
### No additional variables needed for basic SSO

#### Option C: Key-Pair Authentication (Most Secure)
### Uncomment and fill in:
SF_USER_PRIVATE_KEY_PATH=/app/keys/your_private_key_filename.p8
SF_USER_PRIVATE_KEY_PASSPHRASE=your_key_passphrase_if_encrypted
```

**Important Notes:**
- Your `.env` file and `keys/` folder contains sensitive credentials - never commit it to Git
- Ask your team lead for the correct values for your environment

### 5. Set the Correct Target in profiles.yml

Edit the target setting in `dbt_project/profiles.yml` to match your chosen authentication method:

```bash
nano dbt_project/profiles.yml
```

Change the `target:` line at the top to one of:
- `target: local_password` (for password auth)
- `target: local_sso` (for SSO auth)
- `target: local_keypair` (for key-pair auth)
    + place your private key file inside the `keys/` folder

### 6. Install DBT Packages

```bash
cd /app/dbt_project
```

```bash
dbt deps
```

This installs all required dbt packages including:
- dbt_utils (utility macros)
- dbt_expectations (data quality tests)
- dbt_artifacts (execution metadata)
- codegen (code generation helpers)

### 7. Test Your Connection

```bash
dbt debug
```

**Expected Output:**
```
Configuration:
    profiles.yml file [OK found and valid]
    dbt_project.yml file [OK found and valid]

Required dependencies:
    - git [OK found]

Connection:
    account: your_account
    user: your_username
    database: your_database
    schema: your_schema
    warehouse: your_warehouse
    role: your_role
    All checks passed!
```

**If you see errors:**
- Double-check your `.env` file values
- Verify your Snowflake access permissions
- Ensure the target in `profiles.yml` matches your authentication method
- Ask your team lead for help with Snowflake credentials

### 8. Start Developing

```bash
# Run all models - automatically creates schemas and collects metadata
dbt run
```

```bash
# Run tests to validate data quality
dbt test
```

```bash
# Run for different environments (if you have access)
dbt run --target qa
```

```bash
dbt run --target prod
```

```bash
# Run only your project models (excludes dbt_artifacts)
dbt run --exclude package:dbt_artifacts
```

```bash
# Compile models without running them
dbt compile
```

```bash
# Generate documentation
dbt docs generate
```

```bash
# Serve documentation locally
dbt docs serve
```

## Project Structure

Once set up, you'll be working with this structure:

```
project_name/
├── .env (your personal credentials - not in Git)
├── .env.example (template)
├── keys/ (your private keys - not in Git)
├── dbt_project/
│   ├── profiles.yml (Snowflake connections)
│   ├── dbt_project.yml (main project config)
│   ├── packages.yml (dbt dependencies)
│   ├── models/
│   │   ├── staging/ (raw data transformations)
│   │   ├── marts/ (core business logic)
│   │   └── reports/ (final outputs)
│   ├── macros/ (custom SQL functions)
│   ├── seeds/ (static data files)
│   ├── snapshots/ (historical data tracking)
│   └── tests/ (data quality tests)
└── [Docker and VSCode config files]
```

## Available VSCode Extensions

The dev container automatically installs these helpful extensions:
- **Cody AI**: AI coding assistant for dbt development
- **dbt Extensions**: Syntax highlighting, formatting, shortcuts
- **dbt Power User**: Advanced dbt development features
- **Python Extension Pack**: For Python models and analysis
- **Jupyter**: For data exploration notebooks

## Common Commands

### Development Workflow
```bash
# Work on specific models
dbt run --select model_name
dbt run --select staging.*
dbt run --select marts.dim_table_name+

# Test specific models
dbt test --select model_name
dbt test --select staging.*

# Fresh start (clean and rebuild)
dbt clean
dbt deps
dbt run
```

### Model Development
```bash
# Generate model boilerplate
dbt run-operation generate_model_yaml --args '{"model_names": ["model_name"]}'

# Generate source boilerplate
dbt run-operation generate_source --args '{"schema_name": "raw_schema", "database_name": "database"}'
```

### Documentation
```bash
# Generate and serve docs
dbt docs generate
dbt docs serve --port 8001
```

## Troubleshooting

### Connection Issues
1. **"Could not connect to Snowflake"**
     - Verify your `.env` file has correct values
     - Check that your Snowflake user is active
     - Ensure your role has proper permissions

2. **"Database/Schema does not exist"**
     - Ask your team lead to verify your database access
     - Check if you're using the correct database name in `.env`

3. **"Authentication failed"**
     - For password auth: verify your password is correct (deprecating auth method)
     - For SSO: ensure you're logged into your SSO provider
     - For key-pair: verify your private key file path and passphrase

### SSH/Git Issues
```bash
# Test SSH connection to GitLab
ssh -T git@gitlab.com

# If SSH fails, try HTTPS with Personal Access Token
git remote set-url origin https://gitlab.com/path/to/repo.git
```

### Container Issues
- If the container won't start: Try "Dev Containers: Rebuild Container" in VSCode
- If extensions aren't loading: Check the "Extensions" tab in VSCode
- If you get permission errors: Ensure Docker Desktop is running

## Getting Help

1. **Check the logs**: Look in `dbt_project/logs/` for detailed error messages
2. **Ask your team**: Your team lead can help with Snowflake credentials and permissions
3. **Use Cody AI**: The AI assistant can help with dbt syntax and best practices
4. **DBT Documentation**: [docs.getdbt.com](https://docs.getdbt.com/)

## Next Steps

After successful setup:
1. **Explore the existing models** in `models/staging/` and `models/marts/`
2. **Review the documentation** by running `dbt docs serve`
3. **Check out the sources** defined in `models/staging/sources.yml`
4. **Start with small changes** to understand the project structure
5. **Ask questions** - your team is here to help!

---

**Remember**: Never commit your `.env` file or `keys/` folder to Git. These contain sensitive credentials and are automatically ignored by Git.
