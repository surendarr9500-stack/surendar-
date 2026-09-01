# Capacity Connect — SIH 2026 decks (PS 26075)

## Files

| File | Use |
|---|---|
| **`SIH2026_CAPACITY_CONNECT_26075_OFFICIAL_TEMPLATE.pptx`** | Ready-to-submit 6-slide deck in the official SIH template layout. Every slide carries a visual. |
| **`fill_official_template.py`** | Writes the same content into *your own* SIH template `.pptx` (keeps its theme, real logo, footer, titles). See below. |
| `SIH2026_CAPACITY_CONNECT_26075_preview.pdf` | 6-page preview render (approximate fonts — see note). |
| `preview/slide_01…06.png` | Per-slide PNG renders. |
| `CAPACITY_CONNECT_SIH2026_26075.pptx` | Extended 15-slide deck for presentation day. |
| `SIH2026_IDEA_CAPACITY_CONNECT_26075.pptx` | Earlier custom-styled variant of the 6 slides. |
| `assets/` | Images used in the decks — **AI-generated illustrative visuals**, not screenshots of a shipped build. |

## Images per slide

| Slide | Visual |
|---|---|
| 1 Title page | Digital Twin concept — fault highlighted on a component |
| 2 Idea title | Concept UI mockup — offline dashboard + mobile learning app |
| 3 Technical approach | Offline-first edge/cloud architecture banner + two flow charts |
| 4 Feasibility | Field engineer with a rugged tablet on a research vessel |
| 5 Impact | Trainer and trainees in a training session |
| 6 Research | Standards, manuals and prior-art illustration |

## Fill YOUR OWN template (Linux)

```bash
git clone -b arena/01a05db2-surendar https://github.com/surendarr9500-stack/surendar-.git
cd surendar-/docs/ppt
pip install --user python-pptx pillow

# In Drive: File -> Download -> Microsoft PowerPoint (.pptx)
python3 fill_official_template.py ~/Downloads/SIH2026_template.pptx capacity_connect.pptx

libreoffice --headless --convert-to pdf capacity_connect.pptx
```

The script keeps everything in the top 13% and bottom 13% of each slide (logo,
team box, title, footer, page number), deletes only the placeholder prompt text,
scales the layout to the template's canvas (Google Slides exports 10 x 5.625 in),
and removes any slide after the sixth.

Set your details first, near the top of the script:

```python
TEAM    = "Team Name"   # also fills the template's top-left box
TEAM_ID = "Team ID"
```

## Regenerating

```bash
python3 build_sih_official.py       # standalone 6-slide deck
python3 make_fill_variant.py        # regenerate fill_official_template.py from it
python3 build_ppt.py                # extended 15-slide deck
python3 preview_render.py <file.pptx> <outdir> [scale]
```

`fill_official_template.py` is generated — edit `build_sih_official.py` and re-run
`make_fill_variant.py` rather than editing it directly.

`preview_render.py` is a minimal PPTX->PNG previewer for layout checking only. It
renders with DejaVu Sans (the only font in this environment), ~10% wider than
Calibri, so real PowerPoint output is slightly looser than the previews.
