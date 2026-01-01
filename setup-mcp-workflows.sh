#!/bin/bash

# MCP Workflow Setup Script for n8n
# This script helps you complete the MCP server setup

set -e

echo "========================================="
echo "Claude Code MCP Server Setup for n8n"
echo "========================================="
echo ""

# Check if n8n is running
if ! curl -s http://localhost:5678/healthz > /dev/null 2>&1; then
    echo "❌ Error: n8n is not running or not accessible at http://localhost:5678"
    echo "   Please start n8n with: cd ~/n8n && docker compose up -d"
    exit 1
fi

echo "✓ n8n is running and healthy"
echo ""

# Check if credentials were imported
CRED_COUNT=$(docker exec postgres psql -U postgres -d gunretail -t -c "SELECT COUNT(*) FROM credentials_entity WHERE name LIKE '%MCP%';" 2>/dev/null | tr -d ' ')

if [ "$CRED_COUNT" -eq "2" ]; then
    echo "✓ MCP credentials already imported (2 found)"
else
    echo "⚠ MCP credentials not found. Importing now..."
    docker exec n8n n8n import:credentials --input=/tmp/mcp-credentials.json --userId=f98426e2-ad0a-4aa0-a3ad-20f43554ab02
    echo "✓ Credentials imported successfully"
fi

echo ""
echo "========================================="
echo "Next Steps - Manual Import Required"
echo "========================================="
echo ""
echo "The credentials have been created, but workflows need to be"
echo "imported through the n8n web interface due to formatting requirements."
echo ""
echo "Please follow these steps:"
echo ""
echo "1. Open n8n in your browser:"
echo "   http://localhost:5678"
echo ""
echo "2. Import Workflow #1 (MCP Webhook):"
echo "   - Click 'Workflows' → '+ New Workflow'"
echo "   - Click the '⋮' menu (three dots) → 'Import from File'"
echo "   - Select: ~/n8n/workflows/claude-mcp-webhook.json"
echo "   - Click on the 'Webhook' node"
echo "   - Under 'Credentials', select 'MCP Bearer Token'"
echo "   - Click 'Save' and toggle 'Active' to ON"
echo ""
echo "3. Import Workflow #2 (MCP HTTP Server):"
echo "   - Click '+ New Workflow' again"
echo "   - Click '⋮' → 'Import from File'"
echo "   - Select: ~/n8n/workflows/claude-mcp-http.json"
echo "   - Click on the 'MCP HTTP Webhook' node"
echo "   - Under 'Credentials', select 'MCP HTTP Bearer Token'"
echo "   - Click 'Save' and toggle 'Active' to ON"
echo ""
echo "4. Verify the workflows are active:"
echo "   - Both should show with a green/blue 'Active' indicator"
echo ""
echo "5. Test the MCP connections:"
echo "   Run this command to test:"
echo "   curl -X POST http://localhost:5678/webhook-test/2a801a68-3d60-479a-ba95-831efcf52af2 \\"
echo "     -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmOTg0MjZlMi1hZDBhLTRhYTAtYTNhZC0yMGY0MzU1NGFiMDIiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzY2MzY3MTY5LCJleHAiOjE3Njg4ODg4MDB9.SK-niq-X2L7KlmNRM7ChHzX_et6nvYuHx-oOXGoo8V' \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d '{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{\"protocolVersion\":\"2024-11-05\",\"capabilities\":{},\"clientInfo\":{\"name\":\"test\",\"version\":\"1.0\"}}}'"
echo ""
echo "6. Restart Claude Code to connect to MCP servers:"
echo "   - Exit Claude Code if running"
echo "   - Run: claude"
echo "   - Check status: /mcp list"
echo ""
echo "========================================="
echo "Files Created:"
echo "========================================="
echo "  ~/n8n/workflows/claude-mcp-webhook.json"
echo "  ~/n8n/workflows/claude-mcp-http.json"
echo "  ~/n8n/workflows/MCP_SETUP_GUIDE.md"
echo "  ~/n8n/workflows/mcp-credentials.json"
echo ""
echo "For detailed documentation, see:"
echo "  ~/n8n/workflows/MCP_SETUP_GUIDE.md"
echo ""
