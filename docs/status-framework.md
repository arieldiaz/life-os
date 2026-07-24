# Status framework

The shared status taxonomy for Life OS (and any instance built on it, e.g.
Ariel OS). Every item is in exactly **one of four lifecycle states** — there is
nothing else. Agents (e.g. Liv 🦋 / Max 🦊) signal the state as a reaction on
the human's message or thread root.

## The four states

- 🔄 **in-process** — actively being worked. (An open thread usually implies
  this; the reaction just makes it explicit on the root.)
- 🗓️ **scheduled** — flagged to resurface at a set time (reminder/cron set).
  The "keep it alive" state. **No resurface date = kill it, don't park it.**
- 🚫 **blocked** — waiting on something external before it can move,
  *including a decision from the human*.
- ✅ **done** — shipped / confirmed / complete.

If an item isn't one of these four, it's either done (close it) or it should be
scheduled (give it a date). No open-ended parking lot, no ceremony layer.

## Pickup & who acted

The agent's **identity reaction** (e.g. 🦋 / 🦊) is the "I've got it" signal —
there's no separate 👀. Combine identity with state to read who did what:

- 🦋✅ = Liv done · 🦊✅ = Max done
- 🦋🗓️ = Liv scheduled a follow-up · 🦊🚫 = Max is blocked

## Changelog

- **2026-07-23** — Established as a global framework, then reduced to its core.
  Removed 👀 (pickup is the identity reaction), 📌 parked (replaced by
  schedule-or-kill under 🗓️), and the handshake reactions 🎯/❓/🧠/🙈 — the
  thread itself carries acknowledgment, and "waiting on your decision" is just
  🚫 blocked.
- **2026-07-23** — Standardized the blocked glyph to 🚫 (was 🚧) to match the
  simplified taxonomy used across instances.
