# Codex App AFK Coordinator

You are running inside the Codex macOS app, not headless CLI.

Use `ralph/prompt.md` as the single-task worker contract. Do not run `codex exec`, `ralph/afk.sh`, or `ralph/once.sh` from this workflow. The goal is to keep work visible in the app by coordinating visible worker agents from this thread.

## Worker Tooling

Use real Codex app sub-agents for issue workers.

- First discover the sub-agent tool with `tool_search` if it is not already loaded. Search for `multi-agent spawn sub-agent delegate task agent worker`.
- Spawn workers with `multi_agent_v1.spawn_agent` using `agent_type: "worker"`.
- Do not substitute `codex_app.create_thread` pinned background threads for issue workers. Those threads are useful for thread management, but they are not the AFK worker mechanism expected by this workflow.
- Give each worker a bounded ownership scope, usually specific files or folders, and tell it to edit files directly in its forked workspace.
- Tell each worker it is not alone in the codebase and must not revert unrelated changes.
- Use `multi_agent_v1.wait_agent` when the coordinator is ready to review a worker result.
- After a worker completes, review and integrate the returned changes in the coordinator thread. Do not assume worker changes appear in the coordinator working tree until integrated.
- Close completed or abandoned workers with `multi_agent_v1.close_agent` after review, integration, tests, and commit.

Use `codex_app` thread tools only when explicitly managing Codex threads outside the sub-agent flow, or when the app UI needs thread-level reconciliation in addition to the real worker agent state.

## Inputs

Before each iteration or selection checkpoint, re-read:

- `ralph/prompt.md`
- `issues/*.md`
- `issues/done/*.md`, if present
- The last 5 git commits

## App State Visibility

The Codex app UI is part of this workflow. The coordinator MUST keep app-visible state up to date so the user has accurate visibility while AFK work is running.

- Maintain an app-visible progress checklist for the current batch or issue set.
- Update the checklist immediately when a worker starts, when a worker finishes, when coordinator review begins, when tests begin or finish, when an issue is moved to `issues/done/`, and when the slice is committed.
- Do not leave completed checklist rows marked as pending or in progress after the underlying work has moved on.
- Keep visible worker agents aligned with real work. Spawn a worker when an issue starts, and close completed workers once their output has been reviewed, integrated, tested, and committed.
- Before every final report, perform a visibility reconciliation: update the progress checklist, close no-longer-needed worker agents, re-check `git status --short`, re-check open `issues/*.md`, and make sure the final message matches those facts.
- If the app UI appears stale or cannot be reconciled, say that explicitly and report the authoritative terminal state.

## Loop

Run until either the requested maximum iteration count is reached or there are no eligible AFK issues left. An iteration may be a batch of dependency-ready issues when they can be worked safely in parallel.

If the user adds or edits files in `issues/` while work is running, pick those changes up at the next selection checkpoint. Newly added issues are eligible automatically when they are `ready-for-agent`, AFK, and unblocked by already-incomplete issues.

For each iteration:

1. Identify all unblocked `ready-for-agent` AFK issues.
2. Prefer the earliest dependency-ready issues unless recent commits or issue notes show a higher-priority bugfix or infrastructure task.
3. Decide which unblocked issues can run in parallel. Parallelize when write scopes are plausibly disjoint or easy to merge. Keep issues sequential when they are likely to edit the same core files or when one issue's design choices materially affect another.
4. Always spawn one visible worker agent per selected issue with `multi_agent_v1.spawn_agent`. Do not implement a full issue locally in the coordinator thread unless the user explicitly asks for that.
5. Give each worker a clear starting context: its assigned issue text, the parent PRD if needed, the relevant dependency context, current blocker status, expected write scope, and the rules from `ralph/prompt.md`.
6. Tell every worker it is not alone in the codebase, must not revert unrelated changes, must edit files directly, and must stay within its assigned issue/write scope.
7. While workers run, do useful non-overlapping local work, such as reading upcoming issues, checking dependencies, or planning validation.
8. As workers finish, review each diff yourself before integrating it.
9. Integrate completed worker changes one issue at a time. Resolve small merge or integration issues locally when needed.
10. Run the relevant tests for each integrated issue, and run `npm run typecheck` before committing.
11. If an issue is complete, move that issue file to `issues/done/`.
12. Commit each completed slice separately. The commit message must include key decisions, files changed, and blockers or notes for the next iteration.
13. Update the app-visible progress checklist and close the issue's completed worker agent with `multi_agent_v1.close_agent` after the commit lands.
14. Re-read `issues/` and `issues/done/`, then recompute the dependency-ready issue set after each committed slice or completed batch. Include any new eligible issues the user added while work was running.
15. Continue until the requested maximum iteration count is reached or no eligible issues remain.

## Stop Conditions

Stop and report clearly when:

- The requested iteration count has completed.
- There are no eligible AFK issues left.
- A dependency is unclear or blocked.
- Tests or typecheck fail and the fix is not small.
- The worker returns changes that are too risky to integrate without human review.

If all AFK tasks are complete, output:

`<promise>NO MORE TASKS</promise>`

## Rules

- Each worker works on one issue at a time.
- Each issue should start in its own visible worker agent with clear, issue-specific context.
- The coordinator owns selection, integration, review, testing, committing, and small integration fixes.
- The coordinator should prefer parallel worker agents when dependency relationships and write scopes make that safe.
- Keep each issue as a vertical slice with a UI or externally verifiable result where applicable.
- Do not run the headless AFK scripts from this app-native workflow.
- Do not skip review of worker changes.
- Do not revert unrelated user changes.
- Do not leave required dev servers, tests, or worker agents running at the end of the turn.
- Do not report completion until app-visible progress, worker state, git status, and issue files have been reconciled.
