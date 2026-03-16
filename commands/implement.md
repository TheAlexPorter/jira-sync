---
description: Find spec for Jira ticket and start implementation
argument-hint: "<TICKET-KEY>"
allowed-tools: Read, Glob, Grep, AskUserQuestion
---

<instructions>
$ARGUMENTS
</instructions>

## Process

### 1. Check Workflow Plugin

Verify the workflow plugin is available by checking if the `workflow:implement` skill exists.

Use the Glob tool to check:
- Glob for `~/.claude/plugins/cache/lendio/workflow/*/commands/implement.md`

If not found, display this error and stop:

```
The workflow plugin is required for /jira:implement but was not found.

Install it with:
  claude plugin install workflow@lendio --scope user

Once installed, run /jira:implement again.
```

### 2. Validate Input

If no ticket key was provided in `$ARGUMENTS`, tell the user:
"Usage: `/jira:implement <KEY>` (e.g., `/jira:implement PROJ-123`)" and stop.

Extract the ticket key from arguments. The key should match the pattern `[A-Z]+-\d+`.

### 3. Find Existing Spec

Search for a spec file that contains the Jira ticket marker.

Use the Grep tool to search `~/.claude/docs/specs/` for the marker:
- Pattern: `jira-ticket: {KEY}` (where {KEY} is the extracted ticket key)
- Path: `~/.claude/docs/specs/`

### 4. Handle Results

**If a spec file is found:**

1. Read the spec file to extract the feature name and status
2. Tell the user: "Found spec for **{KEY}**: `{spec-path}`\n**Feature:** {feature name}\n**Status:** {status}"
3. Invoke the Skill tool:
   - skill: `"workflow:implement"`
   - args: `"{spec-path}"`

**If no spec file is found:**

Tell the user:

```
No spec found for {KEY}.

A spec must be created before implementation. Run:
  /jira:plan {KEY}

This will fetch the ticket from Jira and create a spec via /workflow:plan.
```

Then use `AskUserQuestion`:
- **Question**: "Create a spec now?"
- **Options**:
  - label: "Yes, run /jira:plan {KEY}", description: "Fetch ticket and create a spec"
  - label: "No", description: "I'll do it later"

Handle the response:
- **Yes**: Invoke the Skill tool with skill `"jira:plan"` and args `"{KEY}"`
- **No**: Stop.
