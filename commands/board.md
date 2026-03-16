---
description: Browse team board and active sprint
argument-hint: "[PROJECT-KEY] [unassigned]"
allowed-tools: Read, AskUserQuestion, mcp__claude_ai_Atlassian__getAccessibleAtlassianResources, mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql, mcp__claude_ai_Atlassian__getVisibleJiraProjects
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

First, try to read `~/.claude/jira-sync.local.md`. If it exists and has a `cloudId` in the YAML frontmatter, use that value as `cloudId`. Also read the `teamProjects` field — this is an array of project keys (e.g., `["ENG", "PLAT"]`).

If the file doesn't exist, call `mcp__claude_ai_Atlassian__getAccessibleAtlassianResources` to get the list of Jira sites.

If only one site, use its `id` as `cloudId`.
If multiple sites, tell the user: "Multiple Jira sites found. Run `/jira:setup` to set a default." Then use the first site's `id` as `cloudId`.
If no sites are returned, tell the user: "No accessible Jira sites found. Check your Atlassian permissions." and stop.

### 1. Parse Arguments

Parse `$ARGUMENTS` for:
- **Project key** — an uppercase string (e.g., `PROJ`, `ENG`). If provided, scope the board to this project.
- **"unassigned"** — if this word appears, filter to only unassigned tickets.

If no project key is provided:
1. Check `teamProjects` from `~/.claude/jira-sync.local.md`.
   - If it contains exactly **one** project, use that automatically.
   - If it contains **multiple** projects, use `AskUserQuestion` with the question "Which project board?" and options for each team project: label = "{key}".
   - If it's empty or missing, fall back to calling `mcp__claude_ai_Atlassian__getVisibleJiraProjects` and let the user pick from all visible projects (up to 15): label = "{key}: {name}".

### 2. Fetch Sprint Tickets

Call `mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql` with:
- `cloudId`: the cloudId from step 0.5
- `jql`: Build the JQL based on arguments:
  - Base: `project = {PROJECT} AND sprint in openSprints() ORDER BY status ASC, priority DESC, updated DESC`
  - If "unassigned" filter: add `AND assignee is EMPTY` before ORDER BY
- `fields`: `["key", "summary", "status", "priority", "issuetype", "assignee", "updated"]`
- `maxResults`: 50
- `responseContentFormat`: `"markdown"`

If the sprint query returns no results (project may not use sprints), fall back to:
- `project = {PROJECT} AND status != Done ORDER BY status ASC, priority DESC, updated DESC`

If the call fails with an authentication error, tell the user: "Jira session may have expired. Run `/jira:setup` to re-authenticate." and stop.

### 3. Display Board

Group tickets by status and display as a board view:

```markdown
## {PROJECT} — Active Sprint

### To Do (5)
| # | Key | Type | Summary | Priority | Assignee |
|---|-----|------|---------|----------|----------|
| 1 | PROJ-101 | Story | Add user search | High | — |
| 2 | PROJ-102 | Bug | Login timeout | Medium | Jane |

### In Progress (3)
| # | Key | Type | Summary | Priority | Assignee |
|---|-----|------|---------|----------|----------|
| 3 | PROJ-103 | Task | Update CI config | Low | Alex |

### In Review (1)
| # | Key | Type | Summary | Priority | Assignee |
|---|-----|------|---------|----------|----------|
| 4 | PROJ-104 | Story | Payment flow | High | Sam |

### Done (2)
_(2 tickets completed — not shown)_
```

Notes:
- Group by the actual status values returned (they vary by project workflow).
- Show Done as a collapsed count, not full listing.
- Show "—" for unassigned tickets.
- Include the Type column (Bug, Story, Task, etc.).

If no tickets found, tell the user: "No tickets found in the active sprint for {PROJECT}." and stop.

### 4. Interactive Selection

Use `AskUserQuestion` to let the user pick a ticket:

- **Question**: "Pick a ticket or action"
- **Options**:
  - For each non-Done ticket (up to 15): label = "{KEY}: {summary}" (truncated to 60 chars), description = "{type} | {status} | {assignee or 'Unassigned'}"
  - Option: label = "Filter: Unassigned only", description = "Show only tickets without an assignee" (only if not already filtered)
  - Final option: label = "Done", description = "Exit board view"

### 5. Handle Selection

If the user selected "Filter: Unassigned only":
- Re-run the search with the unassigned filter and re-display.

If the user selected a ticket:
- Use `AskUserQuestion` again:
  - **Question**: "What would you like to do with {KEY}?"
  - **Options**:
    - label: "View details", description: "Show full ticket details"
    - label: "Plan", description: "Create a spec from this ticket"
    - label: "Implement", description: "Find spec and implement"
    - label: "Assign to me", description: "Claim this ticket"
    - label: "Transition", description: "Change ticket status"
    - label: "Back", description: "Go back to board"

- Handle the action:
  - **View details**: Invoke the Skill tool with skill `"jira:ticket"` and args `"{KEY}"`
  - **Plan**: Invoke the Skill tool with skill `"jira:plan"` and args `"{KEY}"`
  - **Implement**: Invoke the Skill tool with skill `"jira:implement"` and args `"{KEY}"`
  - **Assign to me**: Invoke the Skill tool with skill `"jira:assign"` and args `"{KEY}"`
  - **Transition**: Invoke the Skill tool with skill `"jira:transition"` and args `"{KEY}"`
  - **Back**: Re-display the board and ask again

If the user selected "Done", end with: "Run `/jira:board` anytime to browse the team board."
