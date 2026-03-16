<p align="center">
  <img src="https://github.com/user-attachments/assets/c77a18ef-cef0-4e8a-bfe4-11d35e8b3c84" alt="Jira for Claude Code" width="800">
</p>

# jira

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin that brings Jira into your terminal. Browse your team's board, view tickets, manage assignments, and pipe work directly into planning and implementation — without leaving Claude Code. All commands are `/jira:*`.

Mention a ticket key anywhere in conversation and the plugin automatically fetches its details and adjusts its guidance based on ticket type.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed and working
- A Jira Cloud instance (Server/Data Center is not supported — the plugin uses Atlassian's hosted MCP server)
- An Atlassian account with access to your team's Jira project(s)

No API tokens or service accounts needed. Authentication is handled via OAuth 2.1 through the [Atlassian MCP server](https://mcp.atlassian.com/v1/mcp).

## Install

### 1. Add the marketplace (one-time)

```sh
claude plugin marketplace add TheAlexPorter/claude-plugins
```

### 2. Install the plugin

```sh
claude plugin install jira-sync@thealexporter --scope user
```

Restart Claude Code. Commands will be `/jira:*`.

### Updating

```sh
claude plugin marketplace update thealexporter
claude plugin install jira-sync@thealexporter --scope user
```

## Setup

Once installed, start a new Claude Code session and run:

```
/jira:setup
```

This will:

1. **Authenticate** — If the Atlassian MCP server isn't connected yet, you'll be prompted to run `/mcp` and authenticate in your browser. This is a one-time OAuth flow.
2. **Select your site** — If your Atlassian account has access to multiple Jira sites, you'll pick a default.
3. **Select your team projects** — Pick the project(s) your team works in. This scopes searches and board views so you don't see the entire company's tickets.

Your preferences are saved to `~/.claude/jira-sync.local.md` and shared across sessions. Run `/jira:setup` again anytime to change your default site or team projects.

## How It Works

### Smart context

Mention a ticket key (e.g., `ENG-123`) anywhere in conversation — even while using other plugins like workflow or GSD — and the plugin automatically fetches its details:

```
ENG-123 — Fix payment timeout on retry
Bug | High | In Progress | Assigned: Jane Smith | Sprint: Sprint 24
```

It also adjusts guidance based on ticket type:

- **Bug** — frames work around reproduction and root cause
- **Story** — focuses on acceptance criteria and implementation
- **Epic** — suggests breaking down into smaller issues
- **Task** — straightforward execution guidance
- **Spike** — focuses on investigation and documentation

No need to run a command first. Just mention the ticket.

### Project scoping

Searches and board views are scoped to the team projects you selected during `/jira:setup`. This means "show me open bugs" returns your team's bugs, not every bug across the company.

To search outside your team projects, use explicit JQL:

```
/jira:search project = OTHER AND type = Bug
```

## Commands

| Command | Description |
|---------|-------------|
| `/jira:setup` | Connect to Jira, pick default site and team projects |
| `/jira:mine` | List tickets assigned to you |
| `/jira:board [PROJECT]` | Browse team board / active sprint by status lanes |
| `/jira:ticket <KEY>` | View full ticket details with type-aware context |
| `/jira:search <query>` | Search by plain text or JQL |
| `/jira:transition <KEY>` | Change ticket status (e.g., To Do → In Progress) |
| `/jira:assign <KEY>` | Assign a ticket to yourself or a teammate |
| `/jira:comment <KEY> [text]` | Add a comment to a ticket |
| `/jira:plan <KEY>` | Fetch ticket and create a spec via `/workflow:plan` |
| `/jira:implement <KEY>` | Find spec and start implementation via `/workflow:implement` |
| `/jira:help` | Show command reference |

### Workflow integration

`/jira:plan` and `/jira:implement` bridge Jira tickets into the [workflow plugin](https://github.com/LendioDevs/claude_plugins)'s planning and implementation commands. They require the workflow plugin to be installed separately. All other commands work standalone.

## Typical Flows

### Start your day

```
/jira:mine                      # See what's assigned to you
```

Pick a ticket from the interactive list, then choose to view details, plan, or start implementing.

### Pick up team work

```
/jira:board                     # Browse the team's active sprint
/jira:board unassigned          # See only unassigned tickets
/jira:assign ENG-456            # Claim a ticket
/jira:plan ENG-456              # Create a spec from the ticket
```

### Implement a ticket end-to-end

```
/jira:plan ENG-123              # Fetch ticket → create spec
/jira:implement ENG-123         # Implement from the spec
/jira:comment ENG-123 Fixed in PR #42
/jira:transition ENG-123        # Move to Done
```

### Quick updates

```
/jira:comment ENG-123 Blocked on API access, pinged #platform
/jira:transition ENG-789        # Move ticket to a new status
```

### Natural language

You can also just talk naturally. The plugin picks up on context:

- "Let me work on ENG-123" → offers to plan or implement, suggests moving to In Progress
- "What's on the board?" → shows the team's sprint
- "What am I working on?" → lists your assigned tickets
- "I'm done with ENG-123" → suggests transitioning to Done

## Troubleshooting

**"Jira is not connected"** — Run `/mcp` in Claude Code, find the Atlassian server, and authenticate in your browser. Then run `/jira:setup` again.

**"No accessible Jira sites found"** — Your Atlassian account may not have Jira access. Check your permissions at [admin.atlassian.com](https://admin.atlassian.com).

**Search returns too many results** — Run `/jira:setup` and select your team project(s) to scope searches. Or use explicit JQL with a project filter.

**MCP server not appearing** — Make sure the plugin is installed correctly. The `.mcp.json` file in the plugin directory registers the Atlassian MCP server automatically.

## Updating

```sh
claude plugin marketplace update thealexporter
claude plugin install jira-sync@thealexporter --scope user
```

Start a new Claude Code session to pick up changes.

## License

MIT
