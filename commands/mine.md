---
description: List Jira tickets assigned to you
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

### 1. Fetch Assigned Tickets

Call `mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql` with:
- `cloudId`: the cloudId from step 0.5
- `jql`: `assignee = currentUser() AND status != Done ORDER BY updated DESC`
- `fields`: `["key", "summary", "status", "priority", "updated"]`
- `maxResults`: 20
- `responseContentFormat`: `"markdown"`

If the call fails with an authentication error, tell the user: "Jira session may have expired. Run `/jira:setup` to re-authenticate." and stop.

### 2. Display Results

Format the results as a markdown table:

```
| # | Key | Summary | Status | Priority | Updated |
|---|-----|---------|--------|----------|---------|
| 1 | PROJ-123 | Fix login bug | In Progress | High | 2024-03-15 |
| 2 | PROJ-456 | Add search feature | To Do | Medium | 2024-03-14 |
```

If no tickets are found, tell the user: "No tickets currently assigned to you (excluding Done status)."

### 3. Interactive Selection

If tickets were found, use `AskUserQuestion` to ask the user what they'd like to do:

- **Question**: "Pick a ticket or action"
- **Options**:
  - For each ticket (up to 10): label = "{KEY}: {summary}" (truncated to 60 chars), description = "{status} | {priority}"
  - Final option: label = "Done", description = "Exit without selecting a ticket"

### 4. Handle Selection

If the user selected a ticket:
- Use `AskUserQuestion` again with:
  - **Question**: "What would you like to do with {KEY}?"
  - **Options**:
    - label: "View details", description: "Show full ticket details (/jira:ticket {KEY})"
    - label: "Plan", description: "Create a spec from this ticket (/jira:plan {KEY})"
    - label: "Implement", description: "Find spec and implement (/jira:implement {KEY})"
    - label: "Back", description: "Go back to ticket list"

- Handle the action:
  - **View details**: Invoke the Skill tool with skill `"jira-sync:ticket"` and args `"{KEY}"`
  - **Plan**: Invoke the Skill tool with skill `"jira-sync:plan"` and args `"{KEY}"`
  - **Implement**: Invoke the Skill tool with skill `"jira-sync:implement"` and args `"{KEY}"`
  - **Back**: Re-display the table and ask again

If the user selected "Done", end with: "Run `/jira:mine` again anytime to see your tickets."
