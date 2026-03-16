---
description: Transition a Jira ticket to a new status
argument-hint: "<TICKET-KEY>"
allowed-tools: Read, AskUserQuestion, mcp__claude_ai_Atlassian__getAccessibleAtlassianResources, mcp__claude_ai_Atlassian__getTransitionsForJiraIssue, mcp__claude_ai_Atlassian__transitionJiraIssue
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

### 1. Validate Input

If no ticket key was provided in `$ARGUMENTS`, tell the user:
"Usage: `/jira:transition <KEY>` (e.g., `/jira:transition PROJ-123`)" and stop.

Extract the ticket key from arguments. The key should match the pattern `[A-Z]+-\d+`.

### 2. Get Available Transitions

Call `mcp__claude_ai_Atlassian__getTransitionsForJiraIssue` with:
- `cloudId`: the cloudId from step 0.5
- `issueIdOrKey`: the ticket key

If the call fails, tell the user the error and stop.

### 3. Present Transitions

Use `AskUserQuestion` to let the user pick a transition:

- **Question**: "Move {KEY} to which status?"
- **Options**:
  - For each available transition: label = "{transition name}", description = "→ {destination status name}"
  - Final option: label = "Cancel", description = "Don't change status"

### 4. Execute Transition

If the user selected a transition (not Cancel):

Call `mcp__claude_ai_Atlassian__transitionJiraIssue` with:
- `cloudId`: the cloudId from step 0.5
- `issueIdOrKey`: the ticket key
- `transitionId`: the selected transition's `id`

If successful, tell the user: "**{KEY}** moved to **{transition name}**."
If the call fails, tell the user the error.

If the user selected "Cancel", stop with: "No changes made to {KEY}."

### 5. Contextual Follow-Up

After a successful transition, offer a relevant next step based on the destination status. Use `AskUserQuestion`:

**If moved to "In Progress" (or similar active status):**
- **Question**: "Ticket is in progress. What's next?"
- **Options**:
  - label: "Plan this ticket", description: "Create a spec via /jira:plan {KEY}"
  - label: "Implement", description: "Start implementation via /jira:implement {KEY}"
  - label: "Done", description: "That's all for now"

**If moved to "Done" / "Closed" / "Resolved":**
- **Question**: "Ticket is done. Anything else?"
- **Options**:
  - label: "Add a comment", description: "Post implementation notes"
  - label: "View my tickets", description: "See remaining work"
  - label: "Done", description: "That's all"

**If moved to any other status:**
- No follow-up needed. End with the success message.

Handle the action:
- **Plan this ticket**: Invoke the Skill tool with skill `"jira:plan"` and args `"{KEY}"`
- **Implement**: Invoke the Skill tool with skill `"jira:implement"` and args `"{KEY}"`
- **Add a comment**: Invoke the Skill tool with skill `"jira:comment"` and args `"{KEY}"`
- **View my tickets**: Invoke the Skill tool with skill `"jira:mine"`
- **Done**: End.
