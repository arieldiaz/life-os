# Adopting life-os

life-os is a framework you *run*, not a library you install. The framework stays public and generic; your life goes in a **private instance** — a repo named `<you>-os` where `STRATEGY.md` gets filled in, `memory/` accumulates, and your machines' real config lives. This doc is the mechanics of setting that up so the two repos stay connected for years: pulling framework improvements down stays a one-command merge, and sending improvements back up stays a deliberate, genericized act.

## Why clone → push, not the template button

GitHub's "Use this template" button copies the files but **severs the history**: your new repo starts from a single squashed commit with no ancestor in common with life-os. That feels tidy on day one and hurts forever after — the first `git merge upstream/main` demands `--allow-unrelated-histories`, and without a shared merge-base git can't three-way merge, so routine framework updates arrive as conflict storms over files you never touched. The first instance of this framework learned that the hard way; one of its commits is literally titled "Join histories with upstream." Save yourself the surgery.

A GitHub *fork* keeps the history but can't be made private while the source is public, so it can't hold your life either.

The pattern that works is a **private mirror with a shared merge-base**: clone life-os, push it to a fresh private repo, and keep life-os wired as the `upstream` remote.

## Create your instance

First make an empty private repo to receive the push. On github.com: New repository → name it `<you>-os` → Private → add **nothing** (no README, no license, no .gitignore — it must be truly empty). Or, with `<you>-os` replaced by your instance name:

```
gh repo create <you>-os --private
```

Now clone the framework and rewire the remotes: the clone's `origin` becomes `upstream` (the framework), and your private repo becomes `origin` (home). Replace `<you>-os` with your instance name and `<YOUR-GITHUB-USER>` with your GitHub username before pasting:

```
git clone https://github.com/arieldiaz/life-os.git <you>-os
cd <you>-os
git remote rename origin upstream
git remote add origin https://github.com/<YOUR-GITHUB-USER>/<you>-os.git
git push -u origin main
```

Verify the wiring — `origin` should point at your private repo, `upstream` at life-os:

```
git remote -v
```

That's the whole setup. Day-to-day work happens on your instance's `main` and pushes to `origin`; `upstream` exists only for the two flows below.

## Pull framework improvements down

Whenever life-os improves:

```
git fetch upstream
git merge upstream/main
```

Because the histories are shared, these are small, clean merges. Conflicts appear only in files you deliberately forked from the framework's version — a skill you rewrote, your AGENTS.md instance block — and those conflicts are informative: they're the framework and your fork of it disagreeing, which is worth the minute of attention.

## Send improvements back up

The flow is one-way by default: framework → instance by merge, instance → framework **only by deliberate extraction**. The test for what goes up: *would a stranger running their own instance want this?* A sharper skill, a better ground rule, a pipeline fix — yes, genericized. Anything with your name, your machines, or your life in it — never.

Cut the contribution branch **from `upstream/main`, not from your instance's `main`** — otherwise the PR drags your entire private history behind it:

```
git fetch upstream
git switch -c my-improvement upstream/main
```

Port the change onto the branch by hand, or `git cherry-pick` the instance commit and then scrub it. Genericizing means placeholder paths (`/Users/you`), placeholder hosts (`mini.local`, `your-domain.com`), no names, no real config values. Before pushing, read the full diff hunting for your username, email, hostnames, and real absolute paths:

```
git diff upstream/main...HEAD
```

Your private instance can't be a PR source, so contributions travel through a public fork of life-os. Create one, push the branch there, and open the PR (replace `<YOUR-GITHUB-USER>` with your GitHub username):

```
gh repo fork arieldiaz/life-os --remote --remote-name fork
git push fork my-improvement
gh pr create --repo arieldiaz/life-os --head <YOUR-GITHUB-USER>:my-improvement
```

## `.example` files: the config seam

The seam between framework and instance runs straight through configuration, and one convention keeps it clean: **every config file that holds machine-local paths or secrets exists twice — a tracked `.example` with placeholders, and a gitignored real copy.** The framework ships `ops/stream-paths.env.example` and `infra/secrets/.env.example`; your instance copies each to its real name and fills it in. The `.gitignore` already excludes the real copies. That's not tidiness — it's the tripwire that keeps your values out of a repo whose commits you'll someday cut public PRs from.

The hygiene rules:

- **The `.example` is the manual.** Its comments carry the documentation: what each value is, where it comes from, how to generate it, which machine it lives on. If a knob needs explaining, explain it there — not in a separate doc that will drift.
- **Placeholders are loudly fake.** `you`, `/Users/you`, `mini.local`, `your-domain.com` — values nobody could mistake for real. Secret-shaped keys stay *empty* (`AUTH_SECRET=`) so a filled value screams in any diff.
- **Never a real value "temporarily."** Git history is append-only in practice; a secret that touches a commit is a secret you rotate. This holds inside your private instance too — mistakes travel, and rotating is always more work than not leaking.
- **Change the shape, change the `.example`.** When your instance adds or renames a config knob, update the `.example` in the same commit. If the knob is framework-shaped rather than personal, that `.example` edit is exactly the kind of thing to extract and PR upstream.
- **New `.example` ⇒ new `.gitignore` line.** If you add a config file the existing ignore patterns don't cover, the ignore rule lands in the same commit as the `.example`. An `.example` whose real counterpart is trackable is a leak waiting for a `git add -A`.

## What lives where

Framework (this repo, PR-able): skills, commands, agent *definitions*, AGENTS.md rules, the STREAM.md spec, `ops/` scripts with placeholders, `.example` files.

Instance (private, never upstream): a filled `STRATEGY.md`, `memory/` contents, `derived/`, the real config copies, and everything your agents know about you.

When in doubt, the stranger test decides.
