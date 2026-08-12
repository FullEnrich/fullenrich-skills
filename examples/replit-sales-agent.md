# Replit zero-FullEnrich-credit, read-only sales-agent check

Use this recipe after adding FullEnrich from the Replit install badge and completing FullEnrich OAuth. It verifies connection, tool discovery, a search preview that uses zero FullEnrich credits, and an unchanged FullEnrich credit balance. Replit plan or Agent usage may still consume Replit credits.

## Copy/paste prompt

```text
Use only FullEnrich MCP for this check.

1. Call `get_credits` and report the starting balance.
2. Call `list_industries` and select the official Software Development industry value.
3. Call `search_people` once as a free preview for up to five VP Sales profiles in that industry and in France. Show only name, title, company, and location in chat.
4. Call `get_credits` again, compare it with the starting balance, and stop if the balance changed.

Do not run enrichment, export, contact lookup, CRM, or file-write tools. Do not copy returned people or contact data into project files. Do not commit personal data.

If I later request any paid action, state the exact tool, scope, and estimated credit cost, then wait for my explicit confirmation before calling it.
```

## Expected result

- Replit completes FullEnrich OAuth and discovers the MCP tools.
- The search returns a small preview in chat.
- The ending credit balance matches the starting balance.
- No contact output is written to the Replit project or committed to source control.

Stop the check if authentication fails, a tool outside the four-step sequence is proposed, or the credit balance changes.
