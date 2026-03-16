---
description: View full Jira ticket details
argument-hint: "<TICKET-KEY>"
allowed-tools: AskUserQuestion, mcp__claude_ai_Atlassian__getAccessibleAtlassianResources, mcp__claude_ai_Atlassian__getJiraIssue
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

If no ticket key was provided in `$ARGUMENTS`, tell the user:
"Usage: `/jira:ticket <KEY>` (e.g., `/jira:ticket PROJ-123`)" and stop.

Extract the ticket key from arguments. The key should match the pattern `[A-Z]+-\d+` (e.g., PROJ-123, ENG-45).

### 2. Fetch Ticket

Call `mcp__claude_ai_Atlassian__getJiraIssue` with:
- `cloudId`: the cloudId from step 0.5
- `issueIdOrKey`: the ticket key
- `responseContentFormat`: `"markdown"`

Request all available fields including:
- Summary, description, status, priority, type, labels
- Assignee, reporter
- Sprint, story points/estimate
- Subtasks
- Linked issues (blocks, is blocked by, relates to, etc.)
- Comments (most recent 5)
- Custom fields (especially acceptance criteria if available)

If the ticket is not found, tell the user: "Ticket {KEY} not found. Check the key and try again." and stop.

If the call fails with an authentication error, tell the user: "Jira session may have expired. Run `/jira:setup` to re-authenticate." and stop.

### 3. Display Ticket

Format the ticket as readable markdown:

```markdown
# {KEY}: {summary}

**Status:** {status} | **Priority:** {priority} | **Type:** {type}
**Assignee:** {assignee} | **Reporter:** {reporter}
**Labels:** {labels or "None"}
**Sprint:** {sprint or "None"} | **Points:** {points or "—"}

---

## Description

{description converted from Jira markup/ADF to markdown}

## Acceptance Criteria

{extracted from description or custom field, if present}

## Subtasks

| Key | Summary | Status |
|-----|---------|--------|
| {subtask key} | {summary} | {status} |

_(or "No subtasks" if none)_

## Linked Issues

- {relationship type}: {key} — {summary} ({status})

_(or "No linked issues" if none)_

## Recent Comments

**{author}** ({date}):
> {comment body}

_(or "No comments" if none)_
```

### 4. Offer Actions

Use `AskUserQuestion` to ask what to do next:

- **Question**: "What would you like to do with {KEY}?"
- **Options**:
  - label: "Plan this ticket", description: "Create a spec via /workflow:plan"
  - label: "Implement this ticket", description: "Find or create spec, then implement"
  - label: "Done", description: "Exit"

Handle the response:
- **Plan this ticket**: Invoke the Skill tool with skill `"jira-sync:plan"` and args `"{KEY}"`
- **Implement this ticket**: Invoke the Skill tool with skill `"jira-sync:implement"` and args `"{KEY}"`
- **Done**: End with "Run `/jira:ticket {KEY}` anytime to view this ticket again."
