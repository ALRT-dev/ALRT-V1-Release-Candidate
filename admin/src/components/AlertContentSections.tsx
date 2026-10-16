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
            {content.facts.map((x, i) => (
              <li key={i}>{x}</li>
            ))}
          </ul>
        </section>
      )}
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
      {content.alrtSuggestions.length > 0 && (
        <section>
          <h3>ALRT suggestions</h3>
          <ul>
            {content.alrtSuggestions.map((x, i) => (
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
