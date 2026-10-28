---
name: full-meeting
description: "Builds a pre-meeting brief on a person and their company from FullEnrich profile data plus web search: background, talking points, questions to ask. Use when the user has a call or meeting with someone."
---

# Full Meeting Prep

See [references/fullenrich-reference.md](references/fullenrich-reference.md) for MCP tool names, response schema, statuses, and business rules.

## Rules

- Always ask the meeting type and objective before building the brief — they shape the talking points and strategy.
- Talking points must reference specific details from the person's profile or company, not generic advice.
- Questions must show homework — anything Google-able in 5 seconds is a wasted question.
- Never fabricate data. "No recent news found" is better than inventing context.
- If the meeting is imminent (< 15 minutes), skip web search and build the brief from FullEnrich data only.

## Workflow

### 1. Identify the contact

Accept: name, name + company, LinkedIn URL, email, or calendar event reference. If ambiguous (just a name), ask for company or LinkedIn URL.

### 2. Ask meeting context

Before pulling data, ask:
1. What type of meeting? (sales, partnership, investor, customer check-in, hiring, other)
2. What is the specific objective?
3. Anything specific to prepare for?

### 3. Pull contact data

Call `fullenrich:search_people` with `include_descriptions: true` and the person's LinkedIn URL, or their name plus company domain. Resolve ambiguous matches before continuing. Extract: name, title, seniority, work history, education, skills, LinkedIn URL.

Call `fullenrich:search_companies` with `include_descriptions: true` for company context: industry, headcount, HQ, description, specialties.

### 4. Supplement with web search (if needed and time allows)

Search for: recent company news, funding, the person's recent public posts, industry trends relevant to the meeting.

### 5. Present the brief

Structure:
- **Person**: name, title, company, seniority, location, LinkedIn, email/phone if available
- **Career path**: positions from current to oldest, with company and tenure
- **Education**: university, degree, field
- **Key skills**: professional competencies
- **Company context**: what they do, industry, headcount, HQ, recent signals
- **Meeting strategy**: how to open (specific to this person), their likely priority, the user's angle
- **Talking points**: 3 points tailored to the person's profile + the user's objective
- **Questions to ask**: 4 questions that reference specific profile/company details
- **Quick tips**: 2–3 tactical tips based on seniority and meeting type

### 6. Offer enrichment if needed

If email or phone is missing: call `fullenrich:get_credits` first. Show: "I don't have [field] for this person. Enriching will cost ~1 credit (email) or ~10 (phone). You have [balance]. Proceed?" — credits are the user's money and enrichment cannot be undone. Only after explicit "yes", call `fullenrich:enrich_search_contact` once with the same identifiers and filters that selected the person in step 3, and `limit` set to 1 (a single contact). If those filters do not identify exactly that person, clarify before submitting. Omitting limit uses the default (10000).

## Gotchas

- Career path is often the best source for personalized openers. A VP who spent 10 years as an IC tells a story.
- Adapt depth to seniority: C-level briefs should be short and strategic; director briefs can go deeper on tactics.
- The meeting strategy section (opener, likely priority, angle) is the most valuable part of the brief.
