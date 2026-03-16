# jira-sync

A Claude Code plugin that connects to Jira Cloud and pulls tickets into your workflow.

## Install

```sh
curl -sL https://raw.githubusercontent.com/thealexporter/jira-sync/main/install.sh | bash
```

Then install permanently:

```sh
claude plugin install --path ~/.claude/plugins/jira-sync --scope user
```

To update, run the curl command again.

## Setup

1. Start a Claude Code session
2. Run `/jira:setup`
3. If prompted, run `/mcp` and authenticate the Atlassian server in your browser
4. Run `/jira:setup` again to verify

Authentication is OAuth 2.1 via the [Atlassian MCP server](https://mcp.atlassian.com/v1/mcp) — no API tokens needed.

## Commands

| Command | Description |
|---------|-------------|
| `/jira:setup` | Verify or establish Jira connection |
| `/jira:mine` | List your assigned tickets |
| `/jira:ticket <KEY>` | View full ticket details |
| `/jira:search <query>` | Search by JQL or plain text |
| `/jira:plan <KEY>` | Fetch ticket and create a spec via `/workflow:plan` |
| `/jira:implement <KEY>` | Find spec and implement via `/workflow:implement` |
| `/jira:help` | Command reference |

`/jira:plan` and `/jira:implement` require the [workflow plugin](https://github.com/LendioDevs/claude_plugins). All other commands work standalone.

## Typical Flow

```
/jira:mine                    # See your assigned tickets
/jira:plan PROJ-123           # Fetch ticket, create a spec
/jira:implement PROJ-123      # Implement from the spec
```
