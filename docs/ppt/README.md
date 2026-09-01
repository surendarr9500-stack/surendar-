# Capacity Connect — presentation decks (SIH 2026, PS 26075)

| File | Use |
|---|---|
| `SIH2026_IDEA_CAPACITY_CONNECT_26075.pptx` | **Official SIH Idea Submission format** — exactly 6 slides with the mandated section headings. This is the one to upload. |
| `CAPACITY_CONNECT_SIH2026_26075.pptx` | Extended 15-slide engineering pitch deck for presentation day / internal review. |
| `preview/slide_XX.png` | Rendered previews of the 6-slide submission deck (approximate — fonts differ slightly from PowerPoint). |

## Before you submit

1. **Set your team details.** Open `build_sih_template_ppt.py` and edit:
   ```python
   TEAM    = "Team Name"   # your registered team name
   TEAM_ID = "Team ID"     # your SIH team ID
   ```
   then re-run `python3 build_sih_template_ppt.py`. (Or just type over the
   placeholders directly in PowerPoint.)
2. **Export to PDF.** The SIH portal accepts PDF only — `File → Save as → PDF`.
3. Keep the slide count at 6 (including the title slide), per the template rules.

## Regenerating

```bash
pip install python-pptx pillow
python3 build_sih_template_ppt.py      # 6-slide submission deck
python3 build_ppt.py                   # 15-slide extended deck
python3 preview_render.py SIH2026_IDEA_CAPACITY_CONNECT_26075.pptx preview
```

`preview_render.py` is a minimal PPTX→PNG previewer used for layout
verification only; it supports just the shape vocabulary these two scripts
emit and is not a general-purpose renderer.
