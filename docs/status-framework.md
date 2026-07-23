# Status framework

The shared status taxonomy for Life OS (and any instance built on it, e.g.
Ariel OS). It is both:

1. **Reactions** the agents (e.g. Liv 🦋 / Max 🦊) put on the human's messages
   and thread roots to signal where an item stands, and
2. The **mental model** for any item's state anywhere in the system — not just
   chat.

Every item is in exactly **one lifecycle state**. The handshake reactions are
acknowledgment/handoff signals layered on top; they are not lifecycle states.

## Lifecycle states (an item is always exactly one)

- 🔄 **in-process** — actively being worked right now.
- 🗓️ **scheduled** — flagged to resurface at a set time (reminder/cron set).
  The "keep it alive" state. **No resurface date = kill it, don't park it.**
- 🚧 **blocked** — waiting on something external before it can move.
- ✅ **done** — shipped / confirmed / complete.

That's the whole lifecycle. If an item isn't one of these four, it's either
done (close it) or it should be scheduled (give it a date). There is no
open-ended "parked / someday" bucket — that was a graveyard where things
quietly died and blurred into "blocked."

## Handshake states (acknowledgment / handoff — layered on, not lifecycle)

- 🎯 **decided** — decision made, recommendation landed.
- ❓ **needs your call** — blocked on a decision from the human before moving.
- 🧠 **thinking** — needs real judgment, give it a beat.
- 🙈 **noted, not acting** — saw it, intentionally taking no action.

## Pickup is the identity reaction itself

There is no separate 👀 "seen it, picking it up." When an agent reacts with its
**identity** emoji (e.g. 🦋 / 🦊), that *is* the "I've got it" signal. A bare 👀
would be redundant.

## Who acted

Identity + status combine to show who did what:

- 🦋✅ = Liv done · 🦊✅ = Max done
- 🦋🗓️ = Liv scheduled a follow-up · 🦊🚧 = Max is blocked

## Changelog

- **2026-07-23** — Established as a global framework. Removed 👀 (redundant with
  the identity reaction) and 📌 parked (a no-date bucket too close to blocked;
  replaced by the schedule-it-or-kill-it rule under 🗓️).
