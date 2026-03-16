---
description: Search Jira tickets by JQL or text
argument-hint: "<JQL or search text>"
allowed-tools: AskUserQuestion, mcp__claude_ai_Atlassian__getAccessibleAtlassianResources, mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql
---

<instructions>
$ARGUMENTS
</instructions>

## Process

### 0. Verify Jira Connection

Check if the Atlassian MCP tools are available (tools starting with `mcp__claude_ai_Atlassian__`).

If NOT available:
- Tell the user: "Jira is not connected. Run `/jira:setup` to authenticate."
- Stop.

### 0.5. Get Cloud ID

Call `mcp__claude_ai_Atlassian__getAccessibleAtlassianResources` to get the list of Jira sites. Use the first site's `id` as `cloudId` for all subsequent calls.

If no sites are returned, tell the user: "No accessible Jira sites found. Check your Atlassian permissions." and stop.

### 1. Validate Input

If no search query was provided in `$ARGUMENTS`, tell the user:
"Usage: `/jira:search <query>`\nExamples:\n- `/jira:search payment processing bug`\n- `/jira:search project = PROJ AND status = \"In Progress\"`" and stop.

### 2. Detect Query Type

Analyze the query to determine if it's JQL or plain text:

**JQL indicators** (use as JQL directly):
- Contains JQL operators: `=`, `!=`, `~`, `IN`, `NOT IN`, `IS`, `IS NOT`, `AND`, `OR`, `ORDER BY`
- Contains JQL fields: `project`, `assignee`, `reporter`, `status`, `priority`, `type`, `labels`, `sprint`, `created`, `updated`, `resolved`
- Starts with a JQL field name

**Plain text** (wrap in JQL text search):
- Everything else — use: `text ~ "{query}" ORDER BY updated DESC`

### 3. Execute Search

Call `mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql` with:
- `cloudId`: the cloudId from step 0.5
- `jql`: the determined JQL query
- `fields`: `["key", "summary", "status", "priority", "assignee", "updated"]`
- `maxResults`: 20
- `responseContentFormat`: `"markdown"`

If the search fails (invalid JQL), tell the user the error and suggest correcting the query.

If the call fails with an authentication error, tell the user: "Jira session may have expired. Run `/jira:setup` to re-authenticate." and stop.

If no results, tell the user: "No tickets found for: {query}" and stop.

### 4. Display Results

Format as a markdown table:

```
Found {count} ticket(s):

| # | Key | Summary | Status | Priority | Assignee | Updated |
|---|-----|---------|--------|----------|----------|---------|
| 1 | PROJ-123 | Fix login bug | In Progress | High | John | 2024-03-15 |
```

### 5. Interactive Selection

Use `AskUserQuestion` to let the user pick a ticket:

- **Question**: "Pick a ticket or action"
- **Options**:
  - For each ticket (up to 10): label = "{KEY}: {summary}" (truncated to 60 chars), description = "{status} | {priority}"
  - Final option: label = "Done", description = "Exit search results"

### 6. Handle Selection

If the user selected a ticket:
- Use `AskUserQuestion` again:
  - **Question**: "What would you like to do with {KEY}?"
  - **Options**:
    - label: "View details", description: "Show full ticket details"
    - label: "Plan", description: "Create a spec from this ticket"
    - label: "Implement", description: "Find spec and implement"
    - label: "Back", description: "Go back to search results"

- Handle the action:
  - **View details**: Invoke the Skill tool with skill `"jira-sync:ticket"` and args `"{KEY}"`
  - **Plan**: Invoke the Skill tool with skill `"jira-sync:plan"` and args `"{KEY}"`
  - **Implement**: Invoke the Skill tool with skill `"jira-sync:implement"` and args `"{KEY}"`
  - **Back**: Re-display the table and ask again

If the user selected "Done", stop.
