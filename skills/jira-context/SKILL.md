---
name: jira-context
description: "This skill should be used when the user mentions a Jira ticket key (e.g., PROJ-123, ENG-45), asks about a Jira ticket or issue, says phrases like 'work on PROJ-123', 'what's PROJ-123?', 'pick up ENG-45', 'I'm done with PROJ-123', 'what should I work on', 'what's assigned to me', references a ticket while using other plugins like workflow or GSD, or when another plugin's output contains ticket keys."
---

The jira plugin is installed and provides Jira Cloud integration via the Atlassian MCP server.

## When a Ticket Key Appears in Conversation

When a Jira ticket key (pattern: `[A-Z]+-\d+`, e.g., PROJ-123) appears anywhere in the conversation — whether the user typed it, another plugin referenced it, or it appeared in command output — automatically fetch the ticket details to provide context.

**Deduplication:** If the user explicitly invokes a jira command for a ticket (e.g., `/jira:ticket`, `/jira:plan`), do not also auto-fetch that ticket's context — the command already handles it. If a ticket's details were already fetched earlier in this conversation, reuse that context rather than fetching again, unless the user explicitly asks to refresh.

### Fetch and Display

Call `mcp__claude_ai_Atlassian__getJiraIssue` with the ticket key to retrieve its details. Present a compact context block:

```
**PROJ-123** — Fix payment timeout on retry
Bug | High | In Progress | Assigned: Jane Smith | Sprint: Sprint 24
```

If the fetch fails (MCP not connected), fall back to: "Jira ticket {KEY} detected. Run `/jira:setup` to connect Jira for automatic context."

### Type-Aware Guidance

After displaying the ticket summary, adjust guidance based on the issue type:

- **Bug** — Frame the work around reproduction, root cause investigation, and fix verification. Suggest starting with understanding the bug before jumping to code changes.
- **Story** — Frame the work around implementing the feature described. Look for acceptance criteria to guide the implementation plan.
- **Epic** — Note that this is a large body of work. Suggest breaking it down into stories or checking linked child issues before starting.
- **Task** — Treat as a straightforward unit of work. Check the description for specific instructions.
- **Subtask** — Note the parent ticket. Consider fetching the parent for broader context if the subtask description is sparse.
- **Spike / Research** — Frame around investigation and documentation rather than code delivery.

### Contextual Action Suggestions

Based on the conversation context, suggest the most relevant next action — do not list all commands every time. Use judgment:

- User says "let me work on PROJ-123" or "I'll pick up PROJ-123" → Suggest `/jira:plan PROJ-123` to create a spec, or `/jira:implement PROJ-123` if a spec already exists. Offer to move the ticket to In Progress.
- User is mid-implementation and mentions a ticket → Just provide the context block, no action needed.
- User asks "what's PROJ-123?" → Show full details with `/jira:ticket PROJ-123`.
- User says "I'm done with PROJ-123" → Suggest `/jira:transition PROJ-123` to move it to Done.
- User says "assign PROJ-123 to me" → Run `/jira:assign PROJ-123`.

## When a User Asks About Their Work

**Disambiguation:** If the user asks about their *own* assigned work ("my tickets", "what's assigned to me", "what am I working on"), run `/jira:mine`. If they ask about team-level availability ("what's available", "what's in the sprint", "show me the board"), defer to the jira-board-context skill which routes to `/jira:board`.

## When a User Wants to Search

If the user asks about finding tickets, searching Jira, or looking up issues, run `/jira:search <query>`. Support both plain text and JQL. Searches are automatically scoped to the user's team projects (configured via `/jira:setup`) unless the user explicitly specifies a project in their query.

## Cross-Plugin Behavior

Activate even when the user is primarily working with other plugins (workflow, GSD, etc.). If a ticket key surfaces during `/workflow:plan`, `/workflow:implement`, `/gsd:execute-phase`, or any other context, provide the Jira context proactively. Do not wait for the user to explicitly ask about the ticket.

When piping into workflow commands, include the ticket type in the requirements context so the workflow plugin can adjust its approach (e.g., a bug spec should include reproduction steps, a story spec should focus on acceptance criteria).

## Quick Reference

For the full command reference, run `/jira:help`. Key commands: `/jira:ticket`, `/jira:plan`, `/jira:implement`, `/jira:mine`, `/jira:board`, `/jira:transition`, `/jira:assign`, `/jira:comment`.

## Connection

Authentication is via OAuth 2.1 through the Atlassian MCP server. If MCP tools starting with `mcp__claude_ai_Atlassian__` are not available, direct the user to run `/jira:setup`.
