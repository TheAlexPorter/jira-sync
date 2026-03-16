---
description: Jira-Sync command reference
allowed-tools: ""
---

# Jira-Sync Plugin

Connect to Jira Cloud via the Atlassian MCP server, pull tickets, and pipe them into the workflow plugin for planning and implementation.

## Setup

Run `/jira:setup` to connect your Atlassian account. This triggers an OAuth flow in your browser — no API tokens needed. Run it again anytime to verify your connection status.

## Commands

| Command | Usage | Requires Workflow Plugin |
|---------|-------|--------------------------|
| `/jira:setup` | Verify or establish Jira connection | No |
| `/jira:mine` | List Jira tickets assigned to you | No |
| `/jira:ticket <KEY>` | View full ticket details | No |
| `/jira:search <query>` | Search tickets by JQL or text | No |
| `/jira:plan <KEY>` | Fetch ticket and create a workflow spec | Yes |
| `/jira:implement <KEY>` | Find spec for ticket and start implementation | Yes |
| `/jira:help` | Show this help message | No |

## How It Works

1. **Read-only commands** (`/jira:mine`, `/jira:ticket`, `/jira:search`) fetch data from Jira via the Atlassian MCP server and display it. These work standalone.

2. **Workflow commands** (`/jira:plan`, `/jira:implement`) bridge Jira tickets into the `/workflow:plan` and `/workflow:implement` commands. These require the workflow plugin to be installed.

## Typical Flow

```
/jira:setup                   # Verify connection (first time only)
/jira:mine                    # See your assigned tickets
/jira:plan PROJ-123           # Fetch ticket → create spec via /workflow:plan
/jira:implement PROJ-123      # Find spec → implement via /workflow:implement
```

## Install

```
claude plugin install jira-sync@lendio --scope user
```
