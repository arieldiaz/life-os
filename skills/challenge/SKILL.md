---
name: challenge
description: The counterweight check — the agent who didn't do the work challenges it from the opposite pole. Use at the close of any significant chunk of work (non-blocking, feeds /review) and before any one-way door or strategy change (blocking, gates /decide → /act).
---

# Challenge

## Overview

Every significant piece of work is done from a pole — ship-speed, tech depth, leverage, growth, systemization. The owner's lens structurally cannot see what that pole costs at its complement. The counterweight check makes the opposite perspective a standing voice instead of an occasional one: whoever owns the work, the other agent challenges it. Owner and counterweight are structural roles, not topics — it is never "the work agent checks work things," always "the one who didn't do the work checks it."

The counterweight is not a second reviewer. /review's lenses (outcome, process, cost, strategy, surprise) belong to the owner's side of the ledger. The counterweight's only job is the complement.

## The two independence rules

A challenge is only as good as its independence. Two rules protect it:

1. **Fresh context, always.** The counterweight is invoked clean, given only the deliverable (or the /decide plan) and the challenger role — never the owner's working context. An agent asked to argue against itself in the same context converges toward agreement. In an interactive session, that means a subagent or a separate invocation, not a role-play turn.
2. **Different frontier model, when the harness allows.** Run the counterweight on a state-of-the-art model from a *different lab* than the one that did the work — different training priors mean a different distribution of blind spots, which is the point. Pair by "best available from another provider," not by fixed model names; names rot, the invariant doesn't. Where the current harness can't switch models, fresh context alone is the floor, and the model split is the standing target for the runtime (record the current pairing in runtime memory, not here).

## Process

1. **Name the axis.** One line: what pole was this work optimizing for? If the counterweight can't name it, that's the first finding.
2. **Take the opposite pole.** Personal↔work is one instance; others recur — tech↔human, build↔live, speed↔durability, public↔private, leverage↔load. These are examples, not a menu: name the complement of whatever pole you actually found.
3. **Deliver small.** Exactly three parts, five lines hard cap:
   - the single strongest objection from the opposite pole;
   - one thing the owner's lens missed (may be positive — an unclaimed win counts);
   - a verdict: **no objection** / **proceed with this amendment** / **this needs the human**.
4. **The owner answers in writing.** Answered means addressed, not obeyed — "accepting the cost because X" is a valid answer. A blocking challenge (Gate 2) does not pass until the answer exists.
5. **No veto.** Unresolved disagreement escalates to the human. The counterweight's power is that its objection gets written down and answered, never that it wins.

## Gates

- **Gate 0 — no check.** Slices, errands, routine ops, anything /act is already checkpointing. A counterweight on "scheduled the dentist" is noise.
- **Gate 1 — non-blocking, at /review.** Default for any significant chunk: a completed /decide plan, a closed work session, anything that earns a review. The counterweight reads the review's gap-analysis and appends its five lines; output feeds /compound and the next /decide.
- **Gate 2 — blocking, at /decide.** Default-on for every one-way door /decide flags, every STRATEGY.md edit, anything public/financial/relational, anything touching "Explicitly not doing." The challenge happens *before* /act — challenging an irreversible thing at review time is an autopsy. Skipping Gate 2 requires an explicit note in the plan, and skips are reviewed at the weekly like any other commitment.
- **Standing gates.** The weekly review: the cadence owner runs it, the work agent writes the dissent paragraph. The quarterly strategy revisit: reversed. Each recurring review has a named counterweight voice, every time.

## Rationalizations

| Excuse | Rebuttal |
|--------|----------|
| "The owner already steelmanned it" | Self-generated dissent converges with the self. Independence is the mechanism, not the flavor. |
| "This gate never objects, skip it" | Three content-free "no objection"s in a row means the gate is set at the wrong level — move the threshold, don't silently stop checking. |
| "The challenge deserves a full analysis" | A challenge longer than the review is theater. Five lines; escalate if it truly can't fit. |
| "We disagree, so let's iterate until we agree" | Two rounds max. Persistent disagreement is signal — hand it to the human intact, don't negotiate it away. |

## Exit criteria

The axis named, the five-line challenge delivered from a fresh context (different-lab frontier model where possible), the owner's written answer, and either a resolution or a clean escalation to the human. Gate 2: no /act until this exists.
