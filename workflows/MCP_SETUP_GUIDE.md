# Claude Code MCP Server Setup Guide for n8n

This guide will help you set up the MCP (Model Context Protocol) servers in n8n so Claude Code can connect successfully.

## Prerequisites

- n8n running and accessible at http://localhost:5678
- Docker services healthy (postgres, redis, n8n)
- Two workflow templates created: `claude-mcp-webhook.json` and `claude-mcp-http.json`

## Step 1: Create Bearer Token Credentials in n8n

Before importing workflows, you need to create the authentication credentials.

### For Workflow #1 (claude-mcp-webhook.json):

1. Go to http://localhost:5678
2. Click **Settings** (gear icon) → **Credentials**
3. Click **Add Credential**
4. Search for "Header Auth" and select **Header Auth**
5. Configure:
   - **Credential Name**: `MCP Bearer Token`
   - **Name**: `Authorization`
   - **Value**: `Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmOTg0MjZlMi1hZDBhLTRhYTAtYTNhZC0yMGY0MzU1NGFiMDIiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzY2MzY3MTY5LCJleHAiOjE3Njg4ODg4MDB9.SK-niq-X2L7KlmNRM7ChHzX_et6nvYuHx-oOXGoo8V`
6. Click **Save**

### For Workflow #2 (claude-mcp-http.json):

1. Click **Add Credential** again
2. Select **Header Auth**
3. Configure:
   - **Credential Name**: `MCP HTTP Bearer Token`
   - **Name**: `Authorization`
   - **Value**: `Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmOTg0MjZlMi1hZDBhLTRhYTAtYTNhZC0yMGY0MzU1NGFiMDIiLCJpc3MiOiJuOG4iLCJhdWQiOiJtY3Atc2VydmVyLWFwaSIsImp0aSI6ImEwYmQ5YWFhLTJmZjktNDQyOS05NTI5LWM3NWU5Y2Q0ZWI0MCIsImlhdCI6MTc2NjcwNDk4NH0.UojV-QMSfthVacAVUgZuRKcdAslDPEmOPUnPtEgLVgk`
4. Click **Save**

## Step 2: Import the Workflows

### Import Workflow #1 (Webhook-based MCP):

1. In n8n, click **Workflows** in the left sidebar
2. Click **Import from File** (or the **+** button → **Import from File**)
3. Select `~/n8n/workflows/claude-mcp-webhook.json`
4. The workflow will open in the editor
5. Click on the **Webhook** node
6. Under **Credentials**, select `MCP Bearer Token` from the dropdown
7. Click **Save** (top right)

### Import Workflow #2 (MCP HTTP Server):

1. Click **Workflows** again
2. Click **Import from File**
3. Select `~/n8n/workflows/claude-mcp-http.json`
4. Click on the **MCP HTTP Webhook** node
5. Under **Credentials**, select `MCP HTTP Bearer Token` from the dropdown
6. Click **Save**

## Step 3: Activate the Workflows

For **each workflow**:

1. Open the workflow
2. Toggle the **Active** switch in the top right (should turn green/blue)
3. Verify the webhook URLs are registered:
   - Workflow #1: `http://localhost:5678/webhook-test/2a801a68-3d60-479a-ba95-831efcf52af2`
   - Workflow #2: `http://localhost:5678/webhook/mcp-server/http`

## Step 4: Test the MCP Connections

### Test from command line:

```bash
# Test MCP Webhook
curl -X POST http://localhost:5678/webhook-test/2a801a68-3d60-479a-ba95-831efcf52af2 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmOTg0MjZlMi1hZDBhLTRhYTAtYTNhZC0yMGY0MzU1NGFiMDIiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzY2MzY3MTY5LCJleHAiOjE3Njg4ODg4MDB9.SK-niq-X2L7KlmNRM7ChHzX_et6nvYuHx-oOXGoo8V" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}'

# Test MCP HTTP Server
curl -X POST http://localhost:5678/webhook/mcp-server/http \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmOTg0MjZlMi1hZDBhLTRhYTAtYTNhZC0yMGY0MzU1NGFiMDIiLCJpc3MiOiJuOG4iLCJhdWQiOiJtY3Atc2VydmVyLWFwaSIsImp0aSI6ImEwYmQ5YWFhLTJmZjktNDQyOS05NTI5LWM3NWU5Y2Q0ZWI0MCIsImlhdCI6MTc2NjcwNDk4NH0.UojV-QMSfthVacAVUgZuRKcdAslDPEmOPUnPtEgLVgk" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

Expected response should be a JSON-RPC 2.0 formatted response.

## Step 5: Restart Claude Code

Once the workflows are active:

1. Exit Claude Code (if running)
2. Start a new Claude Code session: `claude`
3. Check MCP server status: `claude mcp list`
4. Both servers should now show as connected

## Customizing the MCP Tools

### Adding Your Own Tools

Edit the workflow's **Code** node to add custom tools:

1. Open the workflow
2. Click on the **MCP Request Handler** or **MCP HTTP Handler** node
3. Find the `tools/list` case
4. Add your tool definitions following the MCP protocol schema
5. Add corresponding logic in the `tools/call` case
6. Save and the changes will be live immediately

### Example Custom Tool:

```javascript
{
  name: 'get_n8n_executions',
  description: 'Get recent workflow executions from n8n',
  inputSchema: {
    type: 'object',
    properties: {
      workflow_id: {
        type: 'string',
        description: 'The workflow ID to query'
      },
      limit: {
        type: 'number',
        description: 'Number of executions to return'
      }
    },
    required: ['workflow_id']
  }
}
```

## Troubleshooting

### "unknown webhook" errors:
- Ensure workflows are **Active** (green/blue toggle)
- Check webhook URLs match exactly
- Verify credentials are correctly assigned

### "Database is not ready" errors:
- These should be resolved with the updated docker-compose.yml
- Check `docker compose ps` - n8n should show as "healthy"

### Authentication errors:
- Verify Bearer tokens match in both n8n credentials and ~/.claude.json
- Check token expiration dates in the JWT

### Connection timeouts:
- Ensure n8n is fully started (check logs: `docker compose logs n8n`)
- Verify healthcheck is passing: `docker compose ps n8n`

## What These Workflows Do

### Workflow #1 (claude-mcp-webhook.json):
- Provides a basic MCP tool interface via webhook
- Handles MCP protocol messages (initialize, tools/list, tools/call)
- Example tool included for testing

### Workflow #2 (claude-mcp-http.json):
- Full MCP HTTP server implementation
- Includes example tools for n8n workflow management
- Supports resources and prompts (extendable)

## Next Steps

1. Customize the tools to your needs
2. Add n8n API calls to actually interact with workflows
3. Implement resource and prompt providers
4. Add error handling and logging

## Resources

- MCP Protocol Specification: https://spec.modelcontextprotocol.io/
- n8n Documentation: https://docs.n8n.io/
- Claude Code MCP Docs: https://code.claude.com/docs/en/mcp-servers
