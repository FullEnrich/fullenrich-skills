---
name: full-sequence
description: "Designs a multi-step, multi-channel outreach sequence (timing, channels, branches, all messages) and loads it into the user's connected sequencer after confirmation. For one-off messages use full-outreach."
---

# Full Sequence

See [references/fullenrich-reference.md](references/fullenrich-reference.md) for MCP tool names, response schema, statuses, and business rules.

## Rules

- Always visualize the sequence structure (flowchart + timeline) and get approval before writing messages.
- Never less than 2 days between touches (feels desperate); never more than 10 (they forget).
- Every sequence needs a breakup email as the final touch — it consistently converts the highest.
- Personalization degrades over a sequence: deep personalization on touch 1, lighter on touch 4–5.
- Before any sequencer mutation, exclude every contact with an explicit opt-out, suppression, or do-not-contact signal.
- Before any sequencer mutation, require one final explicit confirmation that names the sequencer, exact post-suppression contact count, and scheduling mode.
- Scheduling mode must be either draft/paused (no send scheduled) or timed with an exact first-send date/time and timezone.
- Draft/paused mode must not require a fictitious send time and must never activate or schedule the sequence.
- Never activate or schedule a sequence implicitly.

## Workflow

### 1. Prerequisites

Need: enriched contacts (from prospecting, CSV, or user-provided) and either existing messages from full-outreach or enough context to create from scratch.

### 2. Sequence design intake

Ask:
1. Goal (book meeting, get reply, drive to landing page).
2. Target audience (seniority, role type — affects channel mix and tone).
3. Aggressiveness: light (3–4 emails, 2 weeks), standard (5 touches multi-channel, 3 weeks), or heavy (6–7 with phone, 4 weeks).

Probe: do they actually make cold calls? Targeting C-level (fewer touches, phone earlier)? Deadline?

### 3. Detect sequencer

Check which sequencer MCP is connected by scanning available tools. Read the sequencer's capabilities and field mapping. If none connected, design everything in chat for copy-paste.

If the sequencer MCP returns an auth error, stop and ask the user to reconnect.

### 4. Design the sequence architecture

Present two visuals:
- **Flowchart**: touchpoints as nodes with channel + day, branches for reply/open/no-open/bounce, breakup as terminal node.
- **Timeline**: each touchpoint on a time axis with channel and message type.

Default channel ordering: Email → Email → LinkedIn → Email/Phone → Breakup email.

Wait for confirmation before writing messages.

### 5. Write all messages

For each touchpoint, write in the appropriate format (email/LinkedIn DM/call script). Follow the personalization degradation rule: touch 1 deep, touch 2–3 medium, touch 4–5 lighter.

Include a stop rule reminder: if the prospect replies, the sequence stops.

### 6. Push to sequencer

Before presenting the final deployment summary, recheck and exclude all opted-out, suppressed, and do-not-contact contacts; use the remaining eligible count.
Before any sequencer mutation, require one final explicit confirmation that names the sequencer, exact post-suppression contact count, and scheduling mode.

Immediately before the first sequencer mutation, run the suppression and do-not-contact check again.
If the eligible contact count changes, stop and require a new exact confirmation before any mutation.

Create the sequence in draft/paused state. Map fields (subject, body, delay, channel). Add exactly the post-suppression contact count confirmed by the user.

In timed mode only, activate or schedule at the confirmed first-send date/time and timezone.

Report: sequencer name, sequence name, touchpoints, channels, contacts added, scheduling mode.

## Gotchas

- Email-only sequences plateau at touch 3. Push the user to add at least one non-email touchpoint.
- The breakup email is mandatory — if the user says "no breakup", explain that it consistently converts the highest because it triggers loss aversion.
- If no sequencer is connected, present everything cleanly in chat so the user can copy-paste.
- Add exactly the post-suppression contact count confirmed by the user.
