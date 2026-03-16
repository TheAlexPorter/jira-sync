---
description: Set up and verify Jira connection
allowed-tools: AskUserQuestion, mcp__claude_ai_Atlassian__atlassianUserInfo, mcp__claude_ai_Atlassian__getAccessibleAtlassianResources
---

<instructions>
$ARGUMENTS
</instructions>

## Process

### 1. Check Atlassian MCP Tools

Check if the Atlassian MCP tools are available in this session (tools starting with `mcp__claude_ai_Atlassian__`).

If NO Atlassian MCP tools are available, display this message and stop:

```
Jira is not connected. The Atlassian MCP server needs authentication.

To connect:
1. Run /mcp in Claude Code
2. Find the Atlassian server and click to authenticate
3. A browser window will open — sign in to your Atlassian account and authorize access
4. Come back and run /jira:setup again to verify

If you're running in dev mode, make sure .mcp.json is in your plugin directory.
```

### 2. Get User Info

Call `mcp__claude_ai_Atlassian__atlassianUserInfo` to get the current user's identity.

If the call fails, tell the user: "Authentication may have expired. Run `/mcp` to re-authenticate with Atlassian." and stop.

### 3. Get Accessible Sites

Call `mcp__claude_ai_Atlassian__getAccessibleAtlassianResources` to list available Jira/Confluence sites.

### 4. Display Connection Status

Format the output as:

```markdown
## Jira Connection

**User:** {displayName} ({email})
**Sites:**
{For each accessible resource:}
- {name} — `{url}` (ID: {id})

All `/jira:*` commands are ready. Run `/jira:help` to see available commands.
```

If no sites are returned, tell the user: "Your Atlassian account has no accessible Jira sites. Check your Atlassian permissions."
