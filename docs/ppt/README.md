# Capacity Connect — presentation decks (SIH 2026, PS 26075)

| File | Use |
|---|---|
| **`SIH2026_CAPACITY_CONNECT_26075_OFFICIAL_TEMPLATE.pptx`** | ⭐ **Submit this.** Content laid out inside the official SIH template chrome — team-name box (top-left), centred section title, SIH badge (top-right), dark `@SIH Idea submission- Template` footer bar with page numbers. 6 slides. |
| `SIH2026_CAPACITY_CONNECT_26075_OFFICIAL_TEMPLATE_preview.pdf` | 6-page PDF preview of the above (approximate fonts — see note). |
| `SIH2026_IDEA_CAPACITY_CONNECT_26075.pptx` | Earlier custom-styled version of the same 6 slides (same content, different chrome). |
| `CAPACITY_CONNECT_SIH2026_26075.pptx` | Extended 15-slide deck for presentation day / internal review. |
| `assets/*.png` | Concept visuals used in the decks — **AI-generated illustrative mockups**, not screenshots of a shipped build. Replace with real screenshots once the app runs. |
| `preview_official/`, `preview/` | Per-slide PNG renders used for layout verification. |

## Before you submit

1. **Set your team details** — edit at the top of `build_sih_official.py`:
   ```python
   TEAM    = "Team Name"   # registered team name (also fills the top-left box)
   TEAM_ID = "Team ID"
   ```
   then re-run the script; or type over the placeholders in PowerPoint.
2. **Drop in the official SIH logo.** The top-right badge is a text placeholder —
   copy the real SIH 2026 logo from the template you were given and paste it over
   the badge on each slide.
3. **Export to PDF** in PowerPoint (`File → Save as → PDF`). The portal accepts PDF only.
4. Keep it at 6 slides, and keep the mandated section headings unchanged.

## Regenerating

```bash
pip install python-pptx pillow
python3 build_sih_official.py          # official-template 6-slide deck
python3 build_sih_template_ppt.py      # custom-styled 6-slide deck
python3 build_ppt.py                   # extended 15-slide deck
python3 preview_render.py <file.pptx> <outdir> [scale]
```

`preview_render.py` is a minimal PPTX→PNG previewer for layout checking only.
It renders with DejaVu Sans (the only font available in this environment), which
is ~10% wider than Calibri — so real PowerPoint output is slightly *looser* than
the previews, never tighter.

---

## Linux: fill YOUR OWN template file (recommended)

`fill_official_template.py` edits *your* SIH template `.pptx` in place — it keeps
your file's masters, theme, SIH logo, footer and slide titles, deletes only the
placeholder prompt text, and writes the Capacity Connect content (including the
two images) into the body of each slide. It auto-scales to your template's slide
size, so a 10 × 5.625 in Google Slides export works as well as 13.333 × 7.5 in.

```bash
# 1. get this repo on your machine
git clone -b arena/01a05db2-surendar https://github.com/surendarr9500-stack/surendar-.git
cd surendar-/docs/ppt

# 2. dependencies
pip install --user python-pptx pillow

# 3. download your SIH template from Google Drive:
#    File -> Download -> Microsoft PowerPoint (.pptx)

# 4. fill it
python3 fill_official_template.py ~/Downloads/SIH2026_template.pptx capacity_connect.pptx

# 5. edit team name / logo if needed, then export to PDF
libreoffice --headless --convert-to pdf capacity_connect.pptx
```

Set `TEAM` and `TEAM_ID` near the top of the script before step 4 to fill your
registered team details automatically.

The script keeps everything in the top 13% and bottom 13% of each slide
untouched (that is where the template's logo, team box, title and footer live),
and removes exactly 6 slides' worth of prompt text plus any slide after the
sixth (the "Important Instructions" slide).
