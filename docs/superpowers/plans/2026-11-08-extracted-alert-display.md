# Extracted alert display follow-up

Implements Sarah's selected reference layout and 8 November feedback in the existing development worktree. Production and live prompts stay unchanged.

1. Add regressions for sparse records retaining a What to do section, specific source incident labels on Other records, and readable incident titles. Preserve original data and category IDs.
2. Improve agency sections: readable sentence spacing, facts/advice borders, explicit unavailable-advice state rather than a missing section. Never invent facts or instructions.
3. Replace stacked sharing buttons with accessible white action rows, clear group selection and separate external sharing; retain existing consent and delivery handlers.
4. Place useful content before secondary source/time details. Keep selected-only, hazard-relevant Safety Profile matching; put guides after For You.
5. Run targeted tests and analysis, generate actual Flutter screenshots and inspect them. Record unresolved taxonomy/library gaps separately from display fixes. No deployment in this pass.
