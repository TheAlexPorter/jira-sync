---
name: jira-board-context
description: "This skill should be used when the user mentions a team board, sprint, backlog, or swimlanes, asks about unassigned tickets, wants to see what the team is working on, asks 'what's available', 'what needs to be picked up', 'what's in the sprint', 'show me the board', 'what's in progress', 'what's blocked', 'sprint status', 'team status', or references Jira lanes or columns."
---

The jira plugin provides team board browsing via the `/jira:board` command.

## When to Activate

**Disambiguation with jira-context skill:** If the user asks about *their own* assigned work ("what am I working on?", "my tickets", "what's assigned to me"), prefer `/jira:mine` via the jira-context skill. This skill covers team-wide board browsing: the sprint as a whole, unassigned work, or status lanes.

Trigger on language that implies browsing the team's work rather than a specific ticket:

- "What's on the board?" / "Show me the board"
- "What's in the current sprint?" / "Show me the sprint"
- "Any unassigned tickets?"
- "What's available to pick up?"
- "What is the team working on?"
- "What's in the backlog?"
- "Show me what's in To Do" / "What's in progress?" / "What's blocked?"
- "Sprint status" / "Sprint progress"
- "What needs to be done?"

If the user asks about a specific status lane ("what's in review?", "what's blocked?"), run `/jira:board` — the output is grouped by status, so the relevant section will be visible.

## How to Respond

Run `/jira:board` to show the active sprint grouped by status. Optionally pass arguments:

- `/jira:board` — Active sprint for the user's default project
- `/jira:board PROJECT` — Active sprint for a specific project
- `/jira:board unassigned` — Only show unassigned tickets in the sprint

After displaying the board, the user can select tickets to view, plan, assign, or transition.

## Picking Up Work

When the user wants to claim unassigned work from the board:

1. Browse the board with `/jira:board`
2. Select an unassigned ticket
3. Assign it with `/jira:assign KEY`
4. Optionally transition it to In Progress
5. Start planning with `/jira:plan KEY`
