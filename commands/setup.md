---
description: Set up and verify Jira connection
allowed-tools: Write, AskUserQuestion, mcp__claude_ai_Atlassian__atlassianUserInfo, mcp__claude_ai_Atlassian__getAccessibleAtlassianResources, mcp__claude_ai_Atlassian__getVisibleJiraProjects
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

If no sites are returned, tell the user: "Your Atlassian account has no accessible Jira sites. Check your Atlassian permissions." and stop.

### 4. Site Selection

**If only one site:**
Use that site automatically.

**If multiple sites:**
Use `AskUserQuestion` to let the user pick their default site:

- **Question**: "You have access to multiple Jira sites. Pick a default:"
- **Options**:
  - For each site: label = "{name}", description = "{url} (ID: {id})"

### 5. Select Team Projects

Call `mcp__claude_ai_Atlassian__getVisibleJiraProjects` with the selected `cloudId` to get the list of projects the user can see.

Use `AskUserQuestion` to let the user pick their team project(s):

- **Question**: "Which projects does your team work in? (Pick your primary project — you can add more by running `/jira:setup` again)"
- **Options**:
  - For each project (up to 20): label = "{key}: {name}", description = "{projectTypeKey}"
  - Final option: label = "All projects", description = "Don't scope — search across everything"

If the user selects "All projects", set `teamProjects` to an empty list (no scoping).
Otherwise, note the selected project key.

Then ask: "Add another project?"
- **Options**:
  - label: "Yes", description: "Pick another project"
  - label: "No, that's all", description: "Continue with setup"

If "Yes", show the project list again (excluding already selected projects). Repeat until the user says no or has selected 5 projects.

### 6. Save Preferences

Write the selected site and team projects to `~/.claude/jira-sync.local.md` using the Write tool:

```markdown
---
cloudId: "{selected site id}"
siteName: "{selected site name}"
siteUrl: "{selected site url}"
teamProjects: ["{PROJECT1}", "{PROJECT2}"]
---
```

If the user chose "All projects", write `teamProjects: []`.

This file is read by other `/jira:*` commands to scope searches and skip the site lookup step.

### 7. Display Connection Status

Format the output as:

```markdown
## Jira Connection

**User:** {displayName} ({email})
**Default site:** {siteName} — `{siteUrl}`
**Team projects:** {comma-separated project keys, or "All (no scoping)" if empty}

All `/jira:*` commands are ready. Run `/jira:help` to see available commands.
```

If there were multiple sites, add: "Run `/jira:setup` again to switch sites."
Add: "Searches and board views will be scoped to your team projects. Run `/jira:setup` again to change this."
