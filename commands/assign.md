---
description: Assign a Jira ticket to yourself or a teammate
argument-hint: "<TICKET-KEY> [username or 'me']"
allowed-tools: Read, AskUserQuestion, mcp__claude_ai_Atlassian__getAccessibleAtlassianResources, mcp__claude_ai_Atlassian__editJiraIssue, mcp__claude_ai_Atlassian__atlassianUserInfo, mcp__claude_ai_Atlassian__lookupJiraAccountId
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
- **Assignee hint** — everything after the ticket key (optional). Could be "me", a display name, or an email.

If no ticket key found, tell the user:
"Usage: `/jira:assign <KEY> [assignee]`\nExamples:\n- `/jira:assign PROJ-123` (assigns to you)\n- `/jira:assign PROJ-123 me` (assigns to you)\n- `/jira:assign PROJ-123 jane.smith@company.com` (assigns to Jane)" and stop.

### 2. Determine Assignee

**If no assignee hint provided, or hint is "me":**

Call `mcp__claude_ai_Atlassian__atlassianUserInfo` to get the current user's account ID and display name.

**If an assignee hint is provided (not "me"):**

Call `mcp__claude_ai_Atlassian__lookupJiraAccountId` with:
- `cloudId`: the cloudId from step 0.5
- `query`: the assignee hint

If multiple matches are returned, use `AskUserQuestion`:
- **Question**: "Multiple users found. Which one?"
- **Options**: For each match: label = "{displayName}", description = "{email or accountId}"

If no matches found, tell the user: "No user found matching '{hint}'. Try an email address or full name." and stop.

### 3. Confirm Assignment

Use `AskUserQuestion`:
- **Question**: "Assign {KEY} to {displayName}?"
- **Options**:
  - label: "Yes", description: "Assign the ticket"
  - label: "Someone else", description: "Pick a different person"
  - label: "Cancel", description: "Don't change assignment"

If "Someone else", ask for a name/email and go back to step 2.
If "Cancel", stop with "No changes made."

### 4. Assign

Call `mcp__claude_ai_Atlassian__editJiraIssue` with:
- `cloudId`: the cloudId from step 0.5
- `issueIdOrKey`: the ticket key
- `fields`: `{ "assignee": { "accountId": "{accountId}" } }`

If successful, tell the user: "**{KEY}** assigned to **{displayName}**."

Then offer a follow-up:
- Use `AskUserQuestion`:
  - **Question**: "What's next?"
  - **Options**:
    - label: "Move to In Progress", description: "Transition the ticket"
    - label: "Plan this ticket", description: "Create a spec via /workflow:plan"
    - label: "Done", description: "That's all"

Handle:
- **Move to In Progress**: Invoke the Skill tool with skill `"jira:transition"` and args `"{KEY}"`
- **Plan this ticket**: Invoke the Skill tool with skill `"jira:plan"` and args `"{KEY}"`
- **Done**: End.
