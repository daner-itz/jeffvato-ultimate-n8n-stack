# Jeffvato Ultimate n8n Stack

A production-ready n8n automation platform with integrated AI services, vector databases, and Model Context Protocol (MCP) servers for Claude Code integration.

## 🌟 Features

### Core Services
- **n8n** (v1.123.5) - Workflow automation platform with custom ImageMagick support
- **PostgreSQL 16** - Primary database with pgAdmin for management
- **RedisStack** - In-memory data store with RediSearch, RedisJSON, RedisGraph, and RedisTimeSeries modules
- **Ollama** - Local LLM inference engine
- **Open WebUI** - Modern chat interface for Ollama with RAG capabilities
- **Qdrant** - Vector database for semantic search and embeddings
- **SearXNG** - Privacy-respecting metasearch engine

### MCP Servers (Claude Code Integration)
- **n8n-docs-mcp** - Comprehensive n8n documentation and workflow management (20+ tools)
- **playwright-mcp** - Browser automation with headless Chromium
- **postgres-mcp** - Secure PostgreSQL database access with read-only mode

### Additional Utilities
- **ImageMagick** - Advanced image processing in a dedicated container
- **pgAdmin** - Web-based PostgreSQL administration

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       Docker Network                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐   ┌──────────┐   ┌────────────┐   ┌──────────┐  │
│  │   n8n    │   │PostgreSQL│   │ RedisStack │   │  Qdrant  │  │
│  │  :5678   │──▶│  :5432   │   │   :6379    │   │  :6333   │  │
│  └──────────┘   └──────────┘   └────────────┘   └──────────┘  │
│       │              │                                          │
│       ▼              ▼                                          │
│  ┌──────────┐   ┌──────────┐   ┌────────────┐   ┌──────────┐  │
│  │  Ollama  │   │  Open    │   │  SearXNG   │   │ pgAdmin  │  │
│  │  :11434  │──▶│  WebUI   │──▶│   :8080    │   │  :5050   │  │
│  └──────────┘   │  :3000   │   └────────────┘   └──────────┘  │
│                 └──────────┘                                   │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              MCP Servers (Claude Code)                   │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  n8n-docs-mcp  │  playwright-mcp  │  postgres-mcp       │  │
│  │  (stdio)       │  (stdio)         │  (stdio)            │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────┐                                                  │
│  │ImageMagick│ (utility container)                             │
│  └──────────┘                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## 📋 Prerequisites

- **Docker** 20.10+ and **Docker Compose** 2.0+
- **Git** for cloning the repository
- **Minimum 8GB RAM** (16GB recommended)
- **20GB free disk space**
- **Linux, macOS, or WSL2 on Windows**

### Optional
- **Claude Code CLI** - For MCP server integration ([Installation Guide](https://code.claude.com/docs/en/installation))

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/jeffvato-ultimate-n8n-stack.git
cd jeffvato-ultimate-n8n-stack
```

### 2. Configure Environment

Copy the example environment file and configure your credentials:

```bash
cp .env.example .env
```

Edit `.env` and set your credentials:

```env
# Required: PostgreSQL
POSTGRES_USER=your_postgres_username
POSTGRES_PASSWORD=your_postgres_password
POSTGRES_DB=your_database_name

# Required: n8n
N8N_BASIC_AUTH_USER=your_n8n_username
N8N_BASIC_AUTH_PASSWORD=your_n8n_password

# Required: pgAdmin
PGADMIN_DEFAULT_EMAIL=your_email@example.com
PGADMIN_DEFAULT_PASSWORD=your_pgadmin_password

# Optional: SearXNG
SEARXNG_SECRET=your_random_secret_key
```

### 3. Update File Paths (Optional)

If you want to use a shared volume for images/files:

1. Open `docker-compose.yml`
2. Find all instances of `/mnt/e/web_images`
3. Replace with your preferred host directory path

### 4. Build Custom n8n Image

```bash
docker compose build n8n
```

### 5. Start Services

```bash
docker compose up -d
```

### 6. Verify Deployment

```bash
# Check all services are healthy
docker compose ps

# View logs
docker compose logs -f n8n
```

## 🔧 Service Configuration

### Access URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| n8n | http://localhost:5678 | From `.env` (N8N_BASIC_AUTH_*) |
| Open WebUI | http://localhost:3000 | Create on first visit |
| pgAdmin | http://localhost:5050 | From `.env` (PGADMIN_DEFAULT_*) |
| SearXNG | http://localhost:8080 | No auth required |
| PostgreSQL | localhost:5432 | From `.env` (POSTGRES_*) |
| RedisStack | localhost:6379 | No auth required |
| Qdrant | http://localhost:6333 | No auth required |
| Ollama API | http://localhost:11434 | No auth required |

### n8n Configuration

1. **First Login**: Navigate to http://localhost:5678
2. **API Key** (for MCP servers):
   - Go to Settings → API
   - Click "Create API Key"
   - Copy the key
   - Add to `.env`: `N8N_API_KEY=your_api_key_here`
   - Restart services: `docker compose restart`

### Ollama Models

Pull your desired models:

```bash
# Example: Pull Llama 3.2
docker exec ollama ollama pull llama3.2

# List installed models
docker exec ollama ollama list
```

## 🤖 MCP Server Setup (Claude Code Integration)

The stack includes three MCP servers for Claude Code integration:

### Prerequisites

1. Install Claude Code: https://code.claude.com/docs/en/installation
2. Generate n8n API key (see n8n Configuration above)

### Automatic Configuration

The MCP servers are pre-configured in `docker-compose.yml` and will start automatically with the stack. They use **stdio transport** via Docker exec.

### Claude Code Configuration

Add to your `~/.claude.json` (create if it doesn't exist):

```json
{
  "projects": {
    "/path/to/your/project": {
      "mcpServers": {
        "n8n-docs": {
          "type": "stdio",
          "command": "docker",
          "args": ["exec", "-i", "n8n-docs-mcp", "node", "dist/mcp/index.js"],
          "env": {}
        },
        "playwright": {
          "type": "stdio",
          "command": "docker",
          "args": ["exec", "-i", "playwright-mcp", "node", "/mcp/build/index.js"],
          "env": {}
        },
        "postgres": {
          "type": "stdio",
          "command": "docker",
          "args": ["exec", "-i", "postgres-mcp", "postgres-mcp", "--access-mode=restricted"],
          "env": {}
        }
      }
    }
  }
}
```

### Verify MCP Servers

In Claude Code:

```
/mcp
```

You should see all three MCP servers connected.

### MCP Server Capabilities

#### n8n-docs-mcp
- Search n8n nodes and documentation
- Create, update, delete workflows
- Validate workflow configurations
- Deploy templates from n8n.io
- Manage workflow executions
- Auto-fix common issues

#### playwright-mcp
- Navigate to URLs
- Take screenshots
- Fill forms and click buttons
- Execute JavaScript in browser
- Extract page content

#### postgres-mcp
- Execute SQL queries (read-only mode)
- Inspect database schemas
- View table structures
- Performance analysis
- Database metadata

## 🎯 Common Operations

### Manage Services

```bash
# Start all services
docker compose up -d

# Stop all services
docker compose down

# View logs
docker compose logs -f [service_name]

# Restart a service
docker compose restart [service_name]

# Rebuild a service
docker compose build [service_name]
docker compose up -d [service_name]
```

### Update Services

```bash
# Pull latest images
docker compose pull

# Rebuild and restart
docker compose up -d --build
```

### Database Backup

```bash
# Backup PostgreSQL
docker exec postgres pg_dump -U $POSTGRES_USER $POSTGRES_DB > backup.sql

# Restore PostgreSQL
cat backup.sql | docker exec -i postgres psql -U $POSTGRES_USER -d $POSTGRES_DB
```

### Image Processing

```bash
# Use ImageMagick
docker exec imagemagick magick input.jpg -resize 800x600 output.jpg
```

## 🧪 Testing

### Test n8n Workflow

1. Go to http://localhost:5678
2. Create a new workflow
3. Add a "Manual Trigger" node
4. Add an "HTTP Request" node
5. Configure and execute

### Test MCP Servers (Claude Code)

```
# In Claude Code
Search for HTTP Request nodes in n8n

# Or
Navigate to example.com and take a screenshot

# Or
Show me the schema of my database
```

## 🔒 Security Considerations

1. **Change Default Credentials**: Update all passwords in `.env`
2. **API Keys**: Never commit `.env` or credential files to Git
3. **Network Isolation**: Services communicate via Docker network
4. **MCP Access**: PostgreSQL MCP is in read-only mode by default
5. **Firewall**: Consider restricting external access to ports

## 🐛 Troubleshooting

### Service Won't Start

```bash
# Check logs
docker compose logs [service_name]

# Check service health
docker compose ps

# Restart service
docker compose restart [service_name]
```

### Database Connection Issues

```bash
# Check PostgreSQL is healthy
docker compose ps postgres

# Verify credentials in .env
cat .env | grep POSTGRES

# Test connection
docker exec -it postgres psql -U $POSTGRES_USER -d $POSTGRES_DB
```

### MCP Servers Not Connecting

1. Verify services are running: `docker compose ps`
2. Check n8n API key is set in `.env`
3. Restart MCP containers: `docker compose restart n8n-docs-mcp playwright-mcp postgres-mcp`
4. Verify Claude Code configuration in `~/.claude.json`

### Out of Memory

Increase Docker memory allocation or reduce `NODE_OPTIONS` in `.env`:

```env
NODE_OPTIONS=--max-old-space-size=2048
```

## 📁 Project Structure

```
jeffvato-ultimate-n8n-stack/
├── docker-compose.yml          # Main Docker Compose configuration
├── n8n.Dockerfile             # Custom n8n image with ImageMagick
├── .env.example               # Environment variables template
├── .gitignore                 # Git ignore rules
├── README.md                  # This file
├── CLAUDE.md                  # Claude Code instructions
└── workflows/                 # n8n workflow templates
    ├── MCP_SETUP_GUIDE.md
    ├── claude-mcp-webhook.json
    ├── claude-mcp-http.json
    └── mcp-credentials.example.json
```

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

MIT License - feel free to use this stack for personal or commercial projects.

## 🙏 Credits

Created by **Jeffvato**

Built with:
- [n8n](https://n8n.io/) - Workflow automation
- [PostgreSQL](https://www.postgresql.org/) - Database
- [Redis Stack](https://redis.io/docs/stack/) - In-memory data store
- [Ollama](https://ollama.ai/) - Local LLM inference
- [Qdrant](https://qdrant.tech/) - Vector database
- [Playwright](https://playwright.dev/) - Browser automation
- [SearXNG](https://github.com/searxng/searxng) - Metasearch engine
- [Open WebUI](https://github.com/open-webui/open-webui) - LLM interface

MCP Server implementations:
- [n8n-mcp](https://github.com/czlonkowski/n8n-mcp) by czlonkowski
- [playwright-mcp](https://github.com/microsoft/playwright-mcp) by Microsoft
- [postgres-mcp](https://github.com/crystaldba/postgres-mcp) by crystaldba

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/your-username/jeffvato-ultimate-n8n-stack/issues)
- **n8n Community**: https://community.n8n.io/
- **Claude Code Docs**: https://code.claude.com/docs

---

**⭐ If you find this stack helpful, please star the repository!**
