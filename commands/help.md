---
description: Jira-Sync command reference
allowed-tools: []
---

# Jira-Sync Plugin

Connect to Jira Cloud via the Atlassian MCP server. Browse boards, manage tickets, and pipe them into the workflow plugin for planning and implementation.

## Setup

Run `/jira:setup` to connect your Atlassian account. This triggers an OAuth flow in your browser — no API tokens needed. Run it again anytime to verify your connection or switch your default site.

## Commands

| Command | Usage | Requires Workflow Plugin |
|---------|-------|--------------------------|
| `/jira:setup` | Verify or establish Jira connection, set default site | No |
| `/jira:mine` | List Jira tickets assigned to you | No |
| `/jira:board [PROJECT]` | Browse team board / active sprint | No |
| `/jira:ticket <KEY>` | View full ticket details | No |
| `/jira:search <query>` | Search tickets by JQL or text | No |
| `/jira:transition <KEY>` | Change ticket status | No |
| `/jira:assign <KEY>` | Assign a ticket to yourself or someone | No |
| `/jira:comment <KEY>` | Add a comment to a ticket | No |
| `/jira:plan <KEY>` | Fetch ticket and create a workflow spec | Yes |
| `/jira:implement <KEY>` | Find spec for ticket and start implementation | Yes |
| `/jira:help` | Show this help message | No |

## How It Works

1. **Smart context** — Mention a ticket key (e.g., PROJ-123) anywhere in conversation and the plugin auto-fetches its details. It also adjusts guidance based on ticket type (bug, story, epic, etc.).

2. **Board browsing** (`/jira:board`) — View the team's active sprint grouped by status lanes. Filter to unassigned tickets, claim work, and start planning — all without leaving Claude Code.

3. **Read-only commands** (`/jira:mine`, `/jira:ticket`, `/jira:search`) fetch data from Jira via the Atlassian MCP server and display it.

4. **Management commands** (`/jira:transition`, `/jira:assign`, `/jira:comment`) let you update tickets directly from Claude Code.

5. **Workflow commands** (`/jira:plan`, `/jira:implement`) bridge Jira tickets into the `/workflow:plan` and `/workflow:implement` commands. These require the workflow plugin to be installed.

## Typical Flows

### Solo work
```
/jira:mine                    # See your assigned tickets
/jira:plan PROJ-123           # Fetch ticket → create spec via /workflow:plan
/jira:implement PROJ-123      # Find spec → implement via /workflow:implement
/jira:transition PROJ-123     # Move ticket to Done
```

### Pick up team work
```
/jira:board                   # Browse the team's sprint
/jira:board unassigned        # See only unassigned tickets
/jira:assign PROJ-456         # Claim a ticket
/jira:plan PROJ-456           # Start planning
```

### Quick updates
```
/jira:comment PROJ-123 Fixed in PR #42    # Leave a note
/jira:transition PROJ-123                  # Move to Done
```
