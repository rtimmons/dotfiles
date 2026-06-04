---
name: eval-transcript
description: Evaluate a meeting transcript (.srt or .txt) for engineering performance — technical contributions, communication, leadership, estimated level, and growth areas. Use when the user wants to assess a recorded conversation between engineers.
---

# Transcript Evaluation Skill

Evaluate a meeting transcript for engineering performance and interpersonal dynamics.

## Invocation

The user will provide:

1. A path to a transcript file (`.srt`, `.txt`, or similar)
2. Speaker identity mappings (e.g., "SPEAKER_00 is Joe, SPEAKER_01 is Ryan")

If either is missing, ask before proceeding or try to infer the values from context.

## Step 1: Read the Transcript

Read the full transcript file. For `.srt` files, strip the timestamp and sequence lines — focus on the spoken content attributed to each speaker tag.

If the file is large (> 2000 lines), read it in pages using offset/limit until you have the full content.

## Step 2: Build a Speaker Model

For each named speaker, track:

- **Topics they introduce** vs. topics they respond to
- **How they communicate**: crisp and decisive vs. exploratory and hedging
- **Technical depth signals**: do they know implementation details, or stay at the conceptual level?
- **Decision behavior**: do they propose a recommendation, or present a menu of options?
- **Listening behavior**: do they ask clarifying questions that advance the conversation, or do they redirect prematurely?
- **Correction/concession patterns**: when pushed back on, do they defend with reasoning or simply agree?

## Step 3: Write the Summary

Produce a structured markdown document with these sections:

### Conversation Overview

One short paragraph: what the conversation was about, the overall dynamic, and whether it was productive.

### Condensed Conversation

Produce a very condensed version of the conversation with quotes that distills the essence.

Example:

```
Alice: "I went ... to [the store]"
Bob: "What did you [buy there]"
```

The summary should back up the overview, and quotes should be the most substantive points made by the speakers. Omit filler details or parts of the conversation that meander or don't contribute to the overall takeaways. Use bracketed quotes and ellipses (`went ... to [the store]`) liberally to condense, but maintain direct quotes when possible.


### Summary, Key Decisions, Action Items, and Unresolved Decisions
Produce bulleted lists for these items. These form a more public and shared view of the meeting. These notes should not focus on personal evaluation or leveling but should instead focus on the core business value(s) derived from the meeting.

### Per-Speaker Section (one per speaker)
- **Technical strengths**: specific, evidence-backed (quote or paraphrase moments from the transcript)
- **Weaknesses**: same standard — specific, not generic
- **Where they lead** vs. **where they follow**

### Where They Get Along / Differ
- Points of genuine agreement (not just politeness)
- Points of real tension or different instincts — name the underlying disagreement, not just the surface topic

### Estimated Levels
Assign an estimated engineering level for each speaker (e.g., SWE / Senior SWE / Staff / Tech Lead equivalent). Justify briefly.

### What Each Needs to Do More of
Two or three concrete, actionable behaviors for each person that would make the next similar conversation more effective.

### Closing Observation
One or two sentences on the overall health of the working relationship and the key dynamic to watch.

## Step 4: Save the Output

Save the evaluation to a `.md` file in the same directory as the transcript, named `<transcript-basename>-summary.md`. Tell the user the path.

## Tone and Standards

- Ground every claim in transcript evidence. No generic praise or generic criticism.
- Be direct about weaknesses. A growth-oriented evaluation is more useful than a polite one.
- Do not editorialize about personal style — only behaviors that affect engineering effectiveness.
- Estimated levels are approximate. Flag when the conversation doesn't provide enough signal.
- The output should be useful to the person being evaluated, not just the person who asked.
