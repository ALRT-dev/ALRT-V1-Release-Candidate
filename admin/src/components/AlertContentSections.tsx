import type { AlertContent } from "../api/alertTemplates";
import {profileLabels} from "../lib/profileLabels";
export function AlertContentSections({
  content,
  profileTags,
}: {
  content: AlertContent;
  profileTags?: string[];
}) {
  const profiles = profileTags
    ? content.profileGuidance.filter((x) =>
        x.profileTags.some((tag) => profileTags.includes(tag)),
      )
    : content.profileGuidance;
  return (
    <div className="alert-content-sections">
      {content.nativeLevel && (
        <p>
          <strong>Agency warning:</strong> {content.nativeLevel}
        </p>
      )}
      {content.affectedAreas.length > 0 && (
        <section>
          <h3>Affected area</h3>
          <p>{content.affectedAreas.join(", ")}</p>
        </section>
      )}
      {content.facts.length > 0 && (
        <section>
          <h3>What we know</h3>
          <ul>
            {content.facts.slice(0, 4).map((x, i) => (
              <li key={i}>{x}</li>
            ))}
          </ul>
        </section>
      )}
      {content.sourceDescription && <section><h3>Original source details</h3><p style={{whiteSpace:'pre-wrap'}}>{content.sourceDescription}</p></section>}
      {content.officialActions.length > 0 && (
        <section>
          <h3>What the agency says to do</h3>
          <ul>
            {content.officialActions.map((x, i) => (
              <li key={i}>{x}</li>
            ))}
          </ul>
        </section>
      )}
      {content.alrtSuggestions.length > 0 && content.officialActions.length < 2 && (
        <section>
          <h3>ALRT suggestions</h3>
          <p>General guidance from ALRT, not part of the official warning.</p>
          <ul>
            {content.alrtSuggestions.slice(0, Math.max(0, 2 - content.officialActions.length)).map((x, i) => (
              <li key={i}>{x}</li>
            ))}
          </ul>
        </section>
      )}
      {profiles.length > 0 && (
        <section>
          <h3>For you</h3>
          <p className="muted">
            ALRT suggestions for the selected groups. Follow the agency's
            directions.
          </p>
          {profiles.map((x) => (
            <p key={x.id}>
              <strong>{x.profileTags.map(tag=>profileLabels[tag]??tag).join(", ")}: </strong>
              {x.text}
            </p>
          ))}
        </section>
      )}
    </div>
  );
}
