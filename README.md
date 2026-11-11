# peakmindshow.com

The website for Peak Mind, the weekly show with JT McCarthy and Matt McCarthy.

- Everything served lives in `public/`. It is a plain static page with no build step.
- Pushing to `main` deploys it to GitHub Pages (`.github/workflows/deploy.yml`).
- The domain is registered at Cloudflare. DNS for `peakmindshow.com` and `www` points at GitHub Pages.
- The episode list comes from the Spotify show embed, so new episodes appear without changing this repo.
- Artwork comes from the Peak Mind show cover (Ascending Gate). Sources: `~/Downloads/peak-mind-spotify/show-cover/` and `social-profile/` on Matt's MacBook.
- `studio/` holds Peak Mind Studio, a local tool for show prep and episode approval. It is not part of the website and is never deployed (see `studio/README.md`).
