# Project agent memory

Project-intrinsic agent knowledge for peakmindshow.com and the Peak Mind tools. Keep entries concise; point to the authoritative file instead of repeating it.

- **Peak Mind moved here from `purple-phoenix/jtworldteacher`, which is being retired (Matt, 2026-11-11).** New Peak Mind work belongs in this repo.
- **The site is `public/` only.** The Pages workflow uploads just that folder, so tools like `studio/` are never served on peakmindshow.com.
- **Peak Mind Studio is the local app in `studio/`.** Private data lives in `~/peak-mind-studio/data`, never in git (this repo is public). Do not use Claude artifacts for Peak Mind documents: keep them local and self-hosted (Matt, 2026-11-11). The weekly run writes its review with `studio/studioctl.py put-review`, and Matt approves in the Studio. See `studio/README.md`.

## Pull requests

- **Every PR gives Matt a link to see it before he merges, plus 2 to 4 numbered steps.** Run `scripts/preview-pr.sh <pr-number>` (rerun after each push). It serves that PR's `public/` on the tailnet at `https://matts-macbook-pro.tailebcf61.ts.net:<5700 + PR number>/`. Open the link yourself first, then put it in the PR body under "Preview". If the PR changes nothing in `public/`, say so plainly and link what it does change instead (for `studio/`, the running Studio). After the PR merges or closes, retire it with `scripts/preview-pr.sh --stop <pr-number>`.
