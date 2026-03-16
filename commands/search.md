---
description: Search Jira tickets by JQL or text
argument-hint: "<JQL or search text>"
allowed-tools: Read, AskUserQuestion, mcp__claude_ai_Atlassian__getAccessibleAtlassianResources, mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql
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

### 0.5. Get Cloud ID and Team Projects

First, try to read `~/.claude/jira-sync.local.md`. If it exists and has a `cloudId` in the YAML frontmatter, use that value as `cloudId`. Also read the `teamProjects` field — this is an array of project keys (e.g., `["ENG", "PLAT"]`) used to scope searches. If the array is empty or missing, no project scoping is applied.

If the file doesn't exist, call `mcp__claude_ai_Atlassian__getAccessibleAtlassianResources` to get the list of Jira sites.

If only one site, use its `id` as `cloudId`.
If multiple sites, tell the user: "Multiple Jira sites found. Run `/jira:setup` to set a default." Then use the first site's `id` as `cloudId`.
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

### 2.5. Apply Project Scoping

If `teamProjects` was read from `~/.claude/jira-sync.local.md` and is a non-empty array, AND the query does not already contain a `project` filter:

- Prepend a project scope to the JQL: `project IN ({comma-separated project keys}) AND {original JQL}`
- Example: if `teamProjects: ["ENG", "PLAT"]` and query is `text ~ "payment bug" ORDER BY updated DESC`, the final JQL becomes: `project IN (ENG, PLAT) AND text ~ "payment bug" ORDER BY updated DESC`

If `teamProjects` is empty, missing, or the user's query already includes `project =` or `project IN`, do not add scoping — use the JQL as-is.

This ensures searches default to the user's team projects without blocking explicit cross-project searches.

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
    - label: "Transition", description: "Change ticket status"
    - label: "Back", description: "Go back to search results"

- Handle the action:
  - **View details**: Invoke the Skill tool with skill `"jira:ticket"` and args `"{KEY}"`
  - **Plan**: Invoke the Skill tool with skill `"jira:plan"` and args `"{KEY}"`
  - **Implement**: Invoke the Skill tool with skill `"jira:implement"` and args `"{KEY}"`
  - **Transition**: Invoke the Skill tool with skill `"jira:transition"` and args `"{KEY}"`
  - **Back**: Re-display the table and ask again

If the user selected "Done", stop.
