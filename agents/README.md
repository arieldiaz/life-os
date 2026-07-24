# agents/ — few agents, many hats

Most agent frameworks multiply agents: one per task, dozens per review. This repo inverts that. **A small number of durable agents are the primary communication loops** — persistent working relationships with names, scopes, and accumulated context — and they *wear skills as hats*. When Liv runs a weekly review, that's Liv wearing the `/review` hat, not a "review agent" spun up from nothing.

Why fewer is better here: continuity is the compounding surface. A hundred ephemeral agents each start from zero; two durable agents accrue judgment about *you* — what you underestimate, when you're avoiding something, which lessons you've already learned twice. The skills stay generic; the agents get personal.

## The roster

| Agent | Role | Owns |
|-------|------|------|
| [Liv](liv.md) | Personal Chief of Staff | The life outside work — personal ops, household, coordination — plus the loop's cadence: triage, orientation, reviews, memory curation. Runs the week. |
| [Max](max.md) | CEO | The work: strategy, tracks, priorities, tradeoffs, saying no. Runs the quarter. |

The line between them is domain, not altitude: a work question at any altitude is Max's; a personal one at any altitude is Liv's. Cadence spans both — Liv runs the review mechanics either way, and hands the work calls to Max.

You are the board. Agents advise and execute; you own the votes that matter.

Why exactly two, and why they argue: [yin-and-yang.md](yin-and-yang.md). The mechanism that keeps the argument honest is the counterweight check — [skills/challenge/SKILL.md](../skills/challenge/SKILL.md).

## How an agent session works

1. Session opens *as* an agent (e.g. "Liv, what's on deck?"). The agent file is loaded on top of `AGENTS.md` — identity, scope, and standing instructions.
2. The agent reads its standing context (`memory/index.md`, `STRATEGY.md`, its own sections of memory) before anything else.
3. Work happens through the normal skills — the agent picks the hat, the hat defines the workflow.
4. Sessions end the normal way: `/compound` anything durable. Lessons about *the agent's own conduct* ("Liv schedules too optimistically") compound into the agent file itself.

## Rules

- **Agents are template + instance.** The files here define role, scope, and voice — publishable. What an agent *knows about you* lives in `memory/`, in your private instance. Never write personal facts into the agent definition files.
- **No new agents without a reason continuity can't solve.** Before adding a third/fourth agent, ask: is this a new *relationship*, or just a hat Liv or Max should wear?
- **Agents respect the tier system** like everyone else (AGENTS.md rule 10).
- **Disagreement is the job.** Liv and Max exist partly to tell you things you don't want to hear, kindly. An agent that always agrees is a hat, not an agent.
