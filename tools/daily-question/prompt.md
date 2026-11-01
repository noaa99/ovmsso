You are adding practice questions to the OVMS Science Olympiad daily practice apps. You are running inside the local clone of the site repo, and the working tree is already up to date. Edit files on disk only — do NOT run git; the wrapper script commits and pushes for you.

Add TWO new practice questions to EACH of the two Division B events — four questions in total. Work the two events one at a time: first `circuit-lab`, then `water-quality`.

STEP 0 — check for coach-supplied material.
If `reference/<event>/` exists and is not empty, read what is in it before anything else. The coach puts past exams, question sets, notes and diagrams there to steer what you write. Treat it as the authority on style, difficulty and phrasing, and prefer topics it emphasizes. It is reference material, not a source to copy from: never reproduce one of its questions, reword one, or reuse its numbers. If the folder is missing or empty, skip this step without comment.

STEP 1 — read what already exists, so you do not repeat it.
For each event, read:
  - `<event>/bank-stems.txt` — every question already in the built-in bank, one per line as `topic | type | question`
  - `<event>/extra.json` — questions added by earlier runs

STEP 2 — pick TWO topics by rotation, not by preference.
Take today's day-of-year number, modulo the number of topic keys for that event, and use that index into the list below for the first question. Use the NEXT key in the list (wrapping around) for the second question, so the two questions are on different topics. If either topic is already heavily represented among the LAST FIVE entries of extra.json, step to the following key.
  - circuit-lab: history, charges, acdc, ohm, circuits, control, diodes, logic, kirchhoff
  - water-quality: estuary, habitat, zones, nutrients, acid, reef, param, calc, salino, pollution
The `topic` string must match one of those keys EXACTLY, or the page silently drops the question.

STEP 3 — write TWO questions that are genuinely new.
Before writing, scan bank-stems.txt for each topic. Your question must not test the same quantity or fact as any existing one, and the two new questions must not test the same thing as each other. Rephrasing with different numbers is a duplicate, not a new question — the bank already has kilowatt-hour cost problems and chlorinity-to-salinity conversions, so do not write another of either. If every angle you can think of for a topic is taken, move to the next topic key and say so in your reply.

Shapes:
  - multiple choice: {"id":"...","topic":"...","diff":1|2|3,"type":"mc","q":"...","choices":["a","b","c","d"],"ans":<0-based index of the correct choice>,"explain":"..."}
  - numeric: {"id":"...","topic":"...","diff":1|2|3,"type":"num","q":"...","ans":<number>,"unit":"...","tol":<relative tolerance, usually 0.02>,"explain":"..."}

Rules: `id` is "x" plus the date, with a letter appended to keep ids unique — the two questions added on Nov 4 are `x1104a` and `x1104b`, and a further letter if one of those is taken. Make one of the two "mc" and the other "num". Vary which index holds the correct answer. Everything in English. `explain` shows the formula and the arithmetic, not just the answer.

Diagrams: a question may carry one, through two optional fields.
  - `"svg"` — inline SVG markup as a string. This is the preferred form: it is self-contained, scales, and needs no files. Author it to work in both light and dark themes — use `stroke="currentColor"` and `fill="none"` for the drawing, `fill="currentColor"` for text, never a hard-coded black, white or background fill. Give the root `<svg>` a `viewBox` and no fixed width or height. Keep labels inside the viewBox. No `<script>`, no external references, no `<image>`.
  - `"img"` — a path to an image file, relative to the event folder, for a diagram the coach supplied. Only use this when such a file actually exists; never invent a path.
  - `"caption"` — optional one-line caption shown under the figure.
A diagram must carry information the question needs — a circuit to trace, a schematic to read, a graph to interpret. Do not add one as decoration, and do not restate the whole circuit in words if the figure already shows it. For circuit-lab, a schematic question is worth writing often, since reading schematics is a large part of the event. Keep the drawing simple: a handful of components, clear labels, nothing that needs fine detail to read on a phone.

Difficulty: make one of the two `diff` 3 and the other `diff` 2. The diff 3 one should be genuinely harder — a two-step calculation, a case that needs a unit conversion first, or a distinction students usually get wrong — not just a diff 2 question with uglier numbers. Never use diff 1; the easy ground is well covered.

SCOPE — circuit-lab (2027 Division B): the seven named scientists; charge, Coulomb's law, fields and potential, static electricity; DC vs AC, RMS, period, frequency; current, voltage, resistance, Ohm's law, power, energy, kWh cost, efficiency, resistivity, temperature coefficient; series and parallel circuits, schematics, voltage dividers, resistor color code, potentiometers; switches, 3-way switches, relays, fuses, breakers, GFCIs, household wiring; PN-junction diodes, rectifiers, LEDs with series resistors; binary numbers and addition, logic gates, truth tables, Boolean algebra, De Morgan's law, universal gates, adders, multiplexers. Kirchhoff items are allowed but rare. NEVER: capacitance, inductance, RC time constants, magnetism, transformers, motors, impedance or phasors, oscilloscopes, transistors, op-amps, sequential logic or flip-flops.

SCOPE — water-quality (2027 Division B, MARINE AND ESTUARY, not freshwater): estuary formation, Venice salinity classes, salt wedge, euryhaline vs stenohaline, osmoregulation; mangroves, salt marshes, seagrass, tides, upwelling, intertidal zonation, food webs, the 10% rule, biomagnification; benthic/pelagic/neritic/oceanic and euphotic/disphotic/aphotic zones; eutrophication, hypoxia, dead zones, oxygen sag, nutrient sources; ocean acidification, carbonate chemistry, aragonite saturation; coral reef growth requirements, zooxanthellae symbiosis, bleaching and NOAA Coral Reef Watch DHW alert levels, reef threats; the eleven monitoring parameters (temperature, salinity, pH, dissolved oxygen, nitrate, phosphate, turbidity, total solids, fecal coliform, BOD, aragonite saturation) with units, methods and ranges; calculations (Winkler DO, BOD5, S = 1.80655 x Cl, hardness, alkalinity, C1V1 = C2V2, Secchi depth, nitrate and phosphate conversions, percent removal, solids); the salinometer task, specific gravity and percent/ppt conversions, event rules. NEVER use freshwater-only material: the freshwater Water Quality Index, freshwater macroinvertebrate tolerance classes, drinking water or wastewater plant processes, Traditional Ecological Knowledge, or life history strategies (r/K selection, survivorship curves). Do not require identifying one of the 23 listed coral reef organisms by name; general reef ecology is fine.

Math for both stays at Division B level: algebra, at most two simultaneous equations, no trigonometry.

STEP 4 — verify. Run the arithmetic for BOTH questions in a python3 or node one-liner and confirm each matches its `ans`. For multiple choice, confirm all three distractors are genuinely wrong.

STEP 5 — write the files. Append both objects to each event's `extra.json` array and save it. Parse the JSON with python3 to confirm it is still valid after the edit. Do not touch any other file, and do not run git.

Finally, reply with two lines, one per event: the two ids, their topics and types, and which existing questions you checked them against.
