## Git commit conventions

- Prefix every commit message with `[claude]`.
- Keep commit messages terse and descriptive, ideally a single line.
- Do not add a `Co-Authored-By` trailer or any other AI attribution to commits, with one exception: always end the commit message with the `Claude-Session: <url>` trailer when the session's attribution reminder provides one.
- Example: `[claude] Fix login validation`, followed by a blank line and `Claude-Session: https://claude.ai/code/session_<id>`
