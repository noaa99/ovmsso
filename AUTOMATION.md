# How the daily questions work

Each event page (`circuit-lab/index.html`, `water-quality/index.html`) ships with its
question bank built into the page. On load it also fetches `extra.json` from its own
folder and merges any questions found there into the bank.

- `circuit-lab/extra.json` — appended questions for Circuit Lab
- `water-quality/extra.json` — appended questions for Water Quality
- `*/bank-stems.txt` — one line per question already in the built-in bank
  (`topic | type | question`). Written for the daily scheduled task so it can avoid
  repeating what already exists. The pages never fetch it.

A scheduled task adds one question to each `extra.json` every morning. Question shapes:

```json
{"id":"x1104","topic":"ohm","diff":2,"type":"num","q":"...","ans":3.5,"unit":"A","tol":0.02,"explain":"..."}
{"id":"x1104","topic":"logic","diff":2,"type":"mc","q":"...","choices":["a","b","c","d"],"ans":2,"explain":"..."}
```

`topic` must match one of the page's keys exactly or the question is silently dropped.

- circuit-lab: `history charges acdc ohm circuits control diodes logic kirchhoff`
- water-quality: `estuary habitat zones nutrients acid reef param calc salino pollution`

Students' progress lives in their own browser (localStorage), so adding questions never
disturbs it.

If a question ever needs to be removed, delete its object from `extra.json`. Questions in
the built-in bank are edited inside the page file itself.
