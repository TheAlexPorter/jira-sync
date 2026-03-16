---
description: Fetch Jira ticket and create a workflow spec
argument-hint: "<TICKET-KEY>"
allowed-tools: Read, Glob, Grep, AskUserQuestion, mcp__claude_ai_Atlassian__getAccessibleAtlassianResources, mcp__claude_ai_Atlassian__getJiraIssue
---

<instructions>
$ARGUMENTS
</instructions>

## Process

### 1. Check Workflow Plugin

Before proceeding, verify the workflow plugin is available by checking if the `workflow:plan` command exists.

Use the Glob tool to check multiple possible install locations:
- `~/.claude/plugins/cache/*/workflow/*/commands/plan.md`
- `~/.claude/plugins/*/commands/plan.md`

If not found in any location, display this error and stop:

```
The workflow plugin is required for /jira:plan but was not found.

Install it, then run /jira:plan again.

Alternatively, use /jira:ticket {KEY} to view the ticket details without workflow integration.
```

### 1.5. Verify Jira Connection

Check if the Atlassian MCP tools are available (tools starting with `mcp__claude_ai_Atlassian__`).

If NOT available:
- Tell the user: "Jira is not connected. Run `/jira:setup` to authenticate."
- Stop.

### 1.75. Get Cloud ID

First, try to read `~/.claude/jira-sync.local.md`. If it exists and has a `cloudId` in the YAML frontmatter, use that value as `cloudId` and skip to step 2.

Otherwise, call `mcp__claude_ai_Atlassian__getAccessibleAtlassianResources` to get the list of Jira sites.

If only one site, use its `id` as `cloudId`.
If multiple sites, tell the user: "Multiple Jira sites found. Run `/jira:setup` to set a default." Then use the first site's `id` as `cloudId`.
If no sites are returned, tell the user: "No accessible Jira sites found. Check your Atlassian permissions." and stop.

### 2. Validate Input

If no ticket key was provided in `$ARGUMENTS`, tell the user:
"Usage: `/jira:plan <KEY>` (e.g., `/jira:plan PROJ-123`)" and stop.

Extract the ticket key from arguments. The key should match the pattern `[A-Z]+-\d+`.

### 3. Fetch Ticket from Jira

Call `mcp__claude_ai_Atlassian__getJiraIssue` with:
- `cloudId`: the cloudId from step 1.75
- `issueIdOrKey`: the ticket key
- `responseContentFormat`: `"markdown"`

Request all available fields including:
- Summary, description, status, priority, type
- Labels, sprint, story points
- Subtasks with their summaries and statuses
- Linked issues with relationship types
- Recent comments (last 5)
- Acceptance criteria (custom field or extracted from description)
- Reporter

If the ticket is not found, tell the user: "Ticket {KEY} not found. Check the key and try again." and stop.

If the call fails with an authentication error, tell the user: "Jira session may have expired. Run `/jira:setup` to re-authenticate." and stop.

### 4. Format as Requirements

Read the template at `${CLAUDE_PLUGIN_ROOT}/templates/ticket-to-requirements.md` to understand the format.

Build the requirements text by filling in the template fields from the fetched ticket data:

```markdown
## Jira Ticket: {KEY}
<!-- jira-ticket: {KEY} -->
**Summary:** {summary}
**Priority:** {priority} | **Type:** {type} | **Sprint:** {sprint or "None"}

### Description
{description — convert Jira markup/ADF to clean markdown:
 - Convert Jira headings (h1. h2. etc.) to markdown headings
 - Convert {code} blocks to fenced code blocks
 - Convert Jira lists to markdown lists
 - Convert Jira links to markdown links
 - Convert Jira tables to markdown tables
 - Strip Jira-specific markup like {noformat}, {panel}, etc.}

### Acceptance Criteria
{Extract from:
 1. A dedicated "Acceptance Criteria" custom field if present
 2. A section in the description labeled "Acceptance Criteria", "ACs", or "Criteria"
 3. If neither exists, note: "No explicit acceptance criteria found in ticket. The workflow planning phase will derive criteria from the description."}

### Subtasks
{For each subtask:
 - [{status}] {subtask-key}: {summary}
 If no subtasks: "None"}

### Linked Issues
{For each linked issue:
 - {relationship}: {key} - {summary} ({status})
 If no linked issues: "None"}

### Additional Context
- Reporter: {reporter}
- Labels: {comma-separated labels or "None"}
{Include last 2-3 relevant comments if they add context, prefixed with author and date}
```

### 5. Invoke Workflow Plan

Tell the user: "Fetched **{KEY}: {summary}**. Piping into `/workflow:plan`..."

Invoke the Skill tool:
- skill: `"workflow:plan"`
- args: the formatted requirements text from step 4

The workflow plugin will take over from here — entering plan mode, exploring the codebase, and producing a spec file. The `<!-- jira-ticket: {KEY} -->` marker in the requirements text will be preserved in the spec, enabling `/jira:implement` to find it later.
