# ALRT Safety Profile on alert — example layout

Date: 21 October 2026
Purpose: show how the Safety Profile / For You section should appear on an alert detail screen.

---

## 1. Position in the alert

Recommended order on the alert detail screen:

1. Header
2. What we know
3. What to do
4. **For You / Safety Profile**
5. Tell your people
6. Everyone else
7. Attribution / source

The Safety Profile section should never be buried below the large purple share block.

---

## 2. If the user has NOT set up Safety Profile yet

Show a setup prompt instead of nothing.

### Example

**Guidance for your household**  
This alert has advice for older adults, children, mobility and more. Tick what applies and it shows here. Stays on your phone.

Chevron / tap target → opens Safety Profile

### Why
This tells the user:
- the feature exists
- this alert supports it
- nothing is being sent to the server

---

## 3. If the user HAS set up Safety Profile

Show a **FOR YOU** card immediately after **What to do**.

### Example: bushfire alert

**FOR YOU** · stays on your phone

**Children in my care**  
Children can become distressed by smoke and sudden plan changes. Packing familiar comfort items and leaving early if advised may help.

**Mobility or disability needs**  
Leaving takes longer when lifts, ramps or transport help are needed. Deciding early and keeping aids ready may help.

**Pets or livestock**  
Pets can panic at smoke and sirens. Bringing carriers, leads and food to the door before you need them may help.

Footer:
*General guidance from ALRT, not part of the official warning.*

---

## 4. Example: road closure / transport disruption

**FOR YOU** · stays on your phone

**Children in my care**  
Road closures can affect school pickup and long waits in the car. Planning an alternate pickup route and extra travel time may help.

**Medical condition**  
If travel disruption could leave you away from home longer than planned, carrying medication rather than planning to come back for it may help.

**Vision impairment**  
Detours and temporary barriers are harder when the route is unfamiliar. Taking a known route, or allowing more time for help at changes, may help.

Footer:
*General guidance from ALRT, not part of the official warning.*

---

## 5. Example: special event / sporting event

**FOR YOU** · stays on your phone

**Mobility or disability needs**  
Large event days often mean long entry lines and accessible parking filling early. Arriving earlier than usual and checking venue access details may help.

**Children in my care**  
Crowded venues make separation easier. Agreeing a meeting point before arrival and keeping a charged phone may help.

**Visiting Australia**  
Major event days can change road access and public transport patterns quickly. Checking local transport updates before leaving may help.

Footer:
*General guidance from ALRT, not part of the official warning.*

---

## 6. If this hazard should NOT show Safety Profile

Some hazards can stay empty by design.

Examples that may legitimately show no For You block:
- generic crash
- accident
- rescue road incident
- generic protest/rally
- generic notice with no real cohort-specific difference

In those cases, do **not** show weak filler.

---

## 7. Product rules to preserve

- The For You card must be **on device only**.
- It must be **after What to do** and **before Tell your people**.
- It must only show when there is genuine cohort-specific value.
- If no profile is selected but guidance exists, show the **setup prompt**.
- If profile is selected and matching lines exist, show the **For You card**.
- The card must not replace or rewrite the official warning.

---

## 8. What needs fixing in the current app

Current problems seen on phone:
- No Safety Profile section visible on alerts where it should exist.
- The large purple Tell your people card visually pushes the Safety Profile out of prominence.
- Some hazard categories do not yet have category-linked profile rows.

---

## 9. Working recommendation

For production:
- Always show the setup prompt when a hazard supports Safety Profile but the user has not configured it.
- Show the real For You card before Tell your people when the user has a matching profile.
- Build out category-linked profile guidance first for:
  - bushfire / smoke
  - flood / storm
  - air quality / health
  - road closure / transport disruption
  - sporting event / major crowd alerts
