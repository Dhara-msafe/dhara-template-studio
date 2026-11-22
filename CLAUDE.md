# Dhara Template Studio — notes for Claude

## Website and interface work

For any website, page or component work in `frontend/`, use the project skills in `.claude/skills/` in this order:

1. **frontend-design** first. Settle the direction (palette, type, layout, what the one memorable thing is) before writing code.
2. **ui-ux-pro-max** for the design system: tokens, type scale, spacing, component and accessibility rules.
   It runs a local search script: `python3 .claude/skills/ui-ux-pro-max/scripts/search.py "<query>" --design-system`
3. **GSAP** for motion (`gsap-core`, `gsap-react`, `gsap-scrolltrigger`, `gsap-timeline`, `gsap-performance`). In React use `useGSAP` from `@gsap/react` so animations clean up on unmount.
4. **premium-web-design** and the Emil Kowalski skills (`emil-design-eng`, `animate`, `review-animations`) to review restraint, spacing and interaction polish before finishing.
5. **awwwards-3d** only when a 3D or WebGL scene is asked for. It loads Three.js from a CDN and is heavy on phones; do not add it by default.
6. **webapp-testing** to check the result in a real browser at desktop and phone widths.

### Motion rules

- Always respect `prefers-reduced-motion`. Wrap every GSAP animation in `gsap.matchMedia()` under `(prefers-reduced-motion: no-preference)`, and make sure the page is complete and readable with no animation at all.
- Never hide content that only JavaScript reveals. If scripts fail, everything must still be visible.
- Animate `transform` and `opacity` only. No animation on a form the user is typing in.
- One orchestrated moment per page beats many small effects.

### Design identity

The look is "green sheet": court-paper green, bottle-green ink, revenue-stamp pink, typewritten document sheets. Tokens live at the top of `frontend/app/globals.css`. Do not drift toward another product's look.

## Working rules for this repo

- Commit directly to `develop`. No pull requests.
- Templates in `supabase/seed.sql` load as `draft`. Nothing is published without advocate review.
- When a template's legal basis changes, update `docs/TEMPLATE_RESEARCH.md` in the same commit.
- The skills in `.claude/skills/` are third-party code and text. `skills-lock.json` records where each came from and at which commit. Review a skill's `SKILL.md` and scripts before updating it.
