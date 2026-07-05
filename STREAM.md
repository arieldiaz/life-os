# STREAM.md — the external event stream

The stream does **not** live in this repo. It's a separate local-only data store — mostly audio, video, photos, screenshots — with its own lifecycle, sync, and backup. This file is the spec; the repo only ever holds *derived text* about stream events, never the events themselves.

## Topology

```
 MacBook (capture)                Mac mini (canonical + compute)         QNAP NAS (archive)
 ~/Stream/  = spool               $STREAM_CANONICAL                      ethernet to mini
 ├─ recordings auto-ingested      ├─ full append-only store              ├─ nightly stream backup
 ├─ synced to mini every few      ├─ Whisper transcription daemon        ├─ video archive
 │   minutes, then DELETED        │   (timestamps → derived/)            └─ snapshots (ransomware
 │   locally (spool-and-forward)  ├─ local Qwen derivation                   protection)
 └─ nothing accumulates here      └─ serves stream over SMB for
                                      live sessions when needed
```

The MacBook is a capture device, not a store. Recordings land in the spool, ship to the mini, and are removed locally once the transfer is verified. The mini is the single canonical copy; the NAS is its backup. A periodic offline/offsite encrypted copy on top of the NAS is still wise — the NAS protects against disk death, not against everything.

## Naming

```
$STREAM/YYYY/MM/DD/HHMM-short-slug.ext
$STREAM/YYYY/MM/DD/HHMM-short-slug.md      ← optional sidecar
```

Automated ingest derives the timestamp from the file's modification time and the slug from the original filename. Sidecars are optional for automated captures — the transcript becomes the findable text — but a one-line sidecar at capture time is still gold for anything that mattered.

## Rules (unchanged, non-negotiable)

1. **Append-only.** Never edit, rename, move, or delete events. Corrections are new events. (One exception: secrets — see "What never enters the stream.")
2. **Rawest form available.** Audio over transcript, original file over description.
3. **No taxonomy.** Date + slug. Finding things is the job of derived indexes and transcripts.
4. **When in doubt, capture.** The filter is at derivation time.
5. **Tier 0 privacy.** Raw stream data stays on this network. Local models (Whisper, Qwen on the mini) do the deriving. Cloud models see derived text (Tier 1) and curated memory (Tier 2), and touch a raw item only when a human hands it over explicitly, per item.

## What never enters the stream

Append-only cuts both ways: whatever gets captured is kept forever, so a few things must never be captured. "When in doubt, capture" does not apply to:

- **Credentials in any form** — password manager windows, API keys, `.env` contents, tokens, recovery phrases, 2FA codes and their QR codes, banking and login screens. (Credential *files* can't enter — ingest only accepts image/A/V extensions — but a *screenshot* of one can. Don't take it, or take it into `private/`.)
- **Private browsing** — incognito/private windows are private from your own archive too.
- **Other people's confidences** — screens or messages shared with you on the understanding they wouldn't be kept.

Tier 0 being local-only is not a defense here: the stream is backed up to the NAS, mirrored across machines, and served over SMB. Credentials don't belong in *any* archive.

**Escape hatches** (enforced by `ops/` ingest):

- A `private/` subfolder inside any capture dir is never ingested. Screenshot freely into it; it stays out of the archive. Empty it yourself on whatever schedule you like.
- Filenames containing `noarchive` or ending in `-private` are skipped.

**The secrets exception — the one exception to append-only:** if a secret slips into the stream anyway, delete that event immediately and add a small correction event noting what was deleted and why (never the secret itself). Then rotate the credential — an archive that briefly held a key means the key is burned. A permanent copy of a leaked credential is a liability, not history.

## Pipeline

The working machinery lives in [`ops/`](ops/README.md):

1. **Ingest (MacBook):** a watcher normalizes new recordings out of capture locations into the spool, named per convention.
2. **Sync (MacBook → mini):** every few minutes, verified transfer to the canonical store, then removal from the spool.
3. **Transcribe (mini):** open-source Whisper picks up new audio/video and writes timestamped transcripts into `derived/` with provenance headers.
4. **Backup (mini → NAS):** nightly incremental. Append-only data makes this trivial.

Live use on the MacBook: recent transcripts are in `derived/` (which *is* in the repo/vault and syncs like any text), and the mini can expose the raw store over SMB when a session genuinely needs to touch an original — which, per Tier 0, is a human decision each time.

## What counts as an event

Voice notes, call and screen recordings, video, photos, screenshots, saved articles (URL + content — pages die), meeting transcripts as-delivered, journal fragments, exported chat threads, decisions-as-made ("chose X because Y", one line, timestamped). If it happened and might matter, it's an event. Text-only events go in the spool too — a two-line `.md` is a perfectly good event.
