---
description: Add a comment to a Jira ticket
argument-hint: "<TICKET-KEY> [comment text]"
allowed-tools: Read, AskUserQuestion, mcp__claude_ai_Atlassian__getAccessibleAtlassianResources, mcp__claude_ai_Atlassian__addCommentToJiraIssue
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

First, try to read `~/.claude/jira-sync.local.md`. If it exists and has a `cloudId` in the YAML frontmatter, use that value as `cloudId` and skip to step 1.

Otherwise, call `mcp__claude_ai_Atlassian__getAccessibleAtlassianResources` to get the list of Jira sites.

If only one site, use its `id` as `cloudId`.
If multiple sites, tell the user: "Multiple Jira sites found. Run `/jira:setup` to set a default." Then use the first site's `id` as `cloudId`.
If no sites are returned, tell the user: "No accessible Jira sites found. Check your Atlassian permissions." and stop.

### 1. Parse Arguments

Extract from `$ARGUMENTS`:
- **Ticket key** — first token matching `[A-Z]+-\d+` (e.g., PROJ-123)
- **Comment text** — everything after the ticket key

If no ticket key found, tell the user:
"Usage: `/jira:comment <KEY> [comment text]`\nExamples:\n- `/jira:comment PROJ-123 Started working on this`\n- `/jira:comment PROJ-123` (will prompt for comment)" and stop.

### 2. Get Comment Text

If comment text was provided in the arguments, use it directly.

If no comment text was provided, use `AskUserQuestion`:
- **Question**: "What comment would you like to add to {KEY}?"
- Use the free-text response as the comment body.

### 3. Confirm

Display a preview to the user:

```
Adding comment to **{KEY}**:

> {comment text}
```

Use `AskUserQuestion`:
- **Question**: "Post this comment?"
- **Options**:
  - label: "Post", description: "Add this comment to {KEY}"
  - label: "Edit", description: "Change the comment text"
  - label: "Cancel", description: "Don't post"

If "Edit", ask for new text and re-confirm.
If "Cancel", stop with "Comment not posted."

### 4. Post Comment

Call `mcp__claude_ai_Atlassian__addCommentToJiraIssue` with:
- `cloudId`: the cloudId from step 0.5
- `issueIdOrKey`: the ticket key
- `body`: the comment text

If successful, tell the user: "Comment posted to **{KEY}**."
If the call fails, tell the user the error.
