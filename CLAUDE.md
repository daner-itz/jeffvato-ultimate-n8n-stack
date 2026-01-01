# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Production n8n environment with integrated AI and database services. All services defined in @n8n/docker-compose.yml

## Quick Start

```bash
cd ~/n8n

# Build custom n8n image (includes ImageMagick)
docker compose build n8n

# Start all services
docker compose up -d

# View logs
docker compose logs -f n8n
docker compose logs -f postgres
```

## Service Access

- **n8n**: http://localhost:5678 (Basic auth in .env)
- **n8n-docs-mcp**: MCP server (stdio, accessed via Claude Code)
- **playwright-mcp**: MCP server (stdio, browser automation via Claude Code)
- **postgres-mcp**: MCP server (stdio, database access via Claude Code)
- **Open WebUI**: http://localhost:3000
- **pgAdmin**: http://localhost:5050
- **PostgreSQL**: localhost:5432
- **RedisStack**: localhost:6379 (includes RediSearch, RedisJSON, RedisGraph, RedisTimeSeries)
- **Qdrant**: http://localhost:6333
- **Ollama API**: http://localhost:11434

## Key Details

**File paths in n8n workflows:**
- Use `/web_images` inside containers (maps to your host path, configure in docker-compose.yml)
- Mounted in: n8n, postgres, ollama, imagemagick containers
- **Note:** Update `/mnt/e/web_images` in docker-compose.yml to your preferred host directory

**Ollama models:**
```bash
docker exec ollama ollama pull llama3.2
docker exec ollama ollama list
```

**ImageMagick utility:**
- Available via Execute Command node in n8n
- Direct access: `docker exec imagemagick magick ...`

## MCP Server Integration

**n8n-docs-mcp** (czlonkowski/n8n-mcp):
- Comprehensive n8n documentation and workflow management via Claude Code
- 20+ tools: search nodes, create/update workflows, validate, deploy templates, manage executions
- Auto-configured in docker-compose.yml, accessible via stdio transport
- Requires `N8N_API_KEY` in .env (generate at Settings > API in n8n UI)

**Available n8n MCP Tools:**
- `search_nodes`, `get_node`, `validate_node` - Node documentation
- `n8n_create_workflow`, `n8n_update_full_workflow`, `n8n_update_partial_workflow` - Workflow management
- `n8n_deploy_template` - Deploy templates from n8n.io
- `n8n_executions` - Execution management
- `n8n_autofix_workflow` - Auto-fix common issues
- And more...

**playwright-mcp** (Microsoft Official):
- Browser automation capabilities via Playwright
- Interact with web pages, take screenshots, fill forms, click elements
- Headless Chromium mode for automated web testing
- Auto-configured in docker-compose.yml, accessible via stdio transport

**Available Playwright MCP Tools:**
- Navigate to URLs and interact with web pages
- Take screenshots and extract page content
- Fill forms and click buttons
- Execute JavaScript in browser context
- Structured accessibility snapshots for LLM interaction

**postgres-mcp** (Postgres MCP Pro by crystaldba):
- Secure PostgreSQL database access with read-only mode (restricted)
- Query execution, schema inspection, and database management
- Connects to existing PostgreSQL container (database name from .env)
- Security-hardened alternative to deprecated official MCP server
- Auto-configured in docker-compose.yml, accessible via stdio transport

**Available PostgreSQL MCP Tools:**
- Execute SQL queries with parameter binding (read-only in restricted mode)
- Inspect database schemas, tables, and columns
- View indexes, constraints, and relationships
- Performance analysis and query optimization
- Database metadata and statistics

## Workflow Optimizations

### Example: E-commerce Catalog Import Workflows

This is an example of workflow optimizations for catalog import workflows. The following patterns have been optimized for:

**Rate Limit Handling:**
- Login workflow has retry logic (2 retries with 60s wait)
- Main workflow retries login calls with 2 minute exponential backoff
- Caching variables created: `chattanooga_product_feed_url`, `chattanooga_feed_last_updated`

**Resource Optimization:**
- Batch size reduced from 500 to 100 items
- Batch delay increased from 100ms to 2 seconds (2000ms)
- Database upsert uses query batching and split mode
- CSV file cleanup after processing to free disk space

**Error Handling:**
- Continue on fail for database operations
- Detailed error logging for failed items
- Validation at each step (login, download, CSV parsing)

These optimizations prevent API rate limiting (18-minute cooldown) and reduce memory/CPU usage during large catalog imports.
