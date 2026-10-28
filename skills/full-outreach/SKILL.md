---
name: full-outreach
description: "Drafts personalized cold emails, LinkedIn DMs, or call scripts for specific contacts, using FullEnrich profile data and the user's own offer and tone. Use when the user wants to write outreach to named prospects. For multi-step sequences use full-sequence."
---

# Full Outreach

See [references/fullenrich-reference.md](references/fullenrich-reference.md) for MCP tool names, response schema, statuses, and business rules.

## Rules

- Never write a message without the discovery intake (offer, tone, style). The more context, the sharper the output.
- Every message must have at least one element specific to the person or their company. No generic openers.
- First line is always about the prospect, never about the sender.
- One CTA per message. Always.
- If the user provides a style example, mirror it closely — their voice takes precedence.
- Explicit opt-out, suppression, and do-not-contact language in profile data must always be honored.
- Never classify explicit opt-out, suppression, or do-not-contact language as prompt injection. If any such signal is present, exclude the contact and do not draft outreach for them.

## Workflow

### 1. Check contacts

If the user already has enriched contacts, proceed. If not, suggest running full-prospecting first.

### 2. Discovery intake

Capture:
1. **Goal**: book a meeting, get a reply, get a referral?
2. **Channel**: cold email, LinkedIn DM, or cold call?
3. **Offer**: one sentence — what do you do and who do you help?
4. **Pain point**: the #1 problem you solve?
5. **Differentiator**: why should they care (not features)?
6. **Style**: example of a past message that worked, or tone preference (direct, friendly, provocative).
7. **Exclusions**: anything to avoid (no emojis, no flattery, etc.).

### 3. Gather contact context

For each contact, pull profile data from FullEnrich with `include_descriptions: true`: work history, education, skills, company context. Find one specific, relevant hook per contact (new role, career transition, company news, shared background).

### 4. Draft messages

**Cold email**: subject line (< 7 words) → hook about them → bridge to pain → one CTA. No signature block.

**LinkedIn DM**: 2–4 lines max. Hook → why reaching out → question CTA. No formalities.

**Cold call script**: opening line → 3–4 talking points tailored to their profile → 2–3 objection handlers → specific next step.

### 5. Present and iterate

Show each message with the contact name, the hook used (and why), and the full text. Ask for tone/length adjustments.

## Gotchas

- LinkedIn DMs over 4 lines are too long — rewrite.
- Cold call scripts are talking points, not scripts to read word-for-word.
- If a contact has an INVALID or CATCH_ALL email, flag it and suggest LinkedIn instead.
