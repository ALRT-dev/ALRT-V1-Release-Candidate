import { useCallback, useMemo, useState } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import { listHazards } from "../api/resources";
import { LoadingState, ErrorState, EmptyState } from "../components/AsyncState";
import {
  askAlrt,
  AskAlrtRateLimitedError,
  type AskAlrtResponse,
} from "../lib/askAlrt";
import { isFirebaseConfigured } from "../lib/firebase";

interface ChatTurn {
  role: "user" | "assistant";
  text: string;
  meta?: AskAlrtResponse;
}

// Builds the plain-text `context` the Cloud Function reads (see
// lib/askAlrt.ts's AskAlrtRequest) from whatever accepted alerts the
// TEST backend currently has - fetched through listHazards(), which
// itself goes through the shared api client (api/client.ts), so this can
// never see anything but the backend VITE_API_BASE_URL is configured for.
const buildContext = (
  hazards: { title: string; severityBand: string; locationName: string | null }[],
): string =>
  hazards
    .slice(0, 10)
    .map(
      (h) =>
        `${h.title} (${h.severityBand}${h.locationName ? `, near ${h.locationName}` : ""})`,
    )
    .join("; ");

export const AskAlrtPage = () => {
  const fetchRecentAlerts = useCallback(
    () => listHazards({ reviewStatus: "accepted", pageSize: 10 }),
    [],
  );
  const alerts = useApiQuery(fetchRecentAlerts, []);

  const [turns, setTurns] = useState<ChatTurn[]>([]);
  const [question, setQuestion] = useState("");
  const [sending, setSending] = useState(false);
  const [sendError, setSendError] = useState<string | null>(null);

  const context = useMemo(
    () => (alerts.data ? buildContext(alerts.data) : ""),
    [alerts.data],
  );

  const configured = isFirebaseConfigured();

  const handleSend = async () => {
    const trimmed = question.trim();
    if (!trimmed || sending) return;
    setSending(true);
    setSendError(null);
    const nextTurns: ChatTurn[] = [...turns, { role: "user", text: trimmed }];
    setTurns(nextTurns);
    setQuestion("");
    try {
      const history = turns.map((t) => ({ role: t.role, content: t.text }));
      const response = await askAlrt({ question: trimmed, history, context });
      setTurns([...nextTurns, { role: "assistant", text: response.answer, meta: response }]);
    } catch (error) {
      if (error instanceof AskAlrtRateLimitedError) {
        setSendError(error.message);
      } else {
        setSendError(
          error instanceof Error ? error.message : "Ask ALRT is unavailable right now.",
        );
      }
    } finally {
      setSending(false);
    }
  };

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Ask ALRT</h1>
          <p>
            Ask questions about the alert information currently shown in this
            portal. Uses only the alerts this environment's backend returns -
            never production data.
          </p>
        </div>
      </div>

      {!configured && (
        <div className="state-block" role="status">
          Ask ALRT needs a Firebase Web App configured for this environment
          before it can answer questions (VITE_FIREBASE_* in .env.test /
          .env.example are blank until that Firebase Console step is done).
          The rest of this page still shows which TEST alerts would be used
          as context.
        </div>
      )}

      {alerts.loading && <LoadingState label="Loading alert context..." />}
      {!alerts.loading && Boolean(alerts.error) && (
        <ErrorState error={alerts.error} onRetry={alerts.refetch} />
      )}
      {!alerts.loading && !alerts.error && alerts.data && alerts.data.length === 0 && (
        <EmptyState label="No accepted alerts in this environment yet - Ask ALRT will answer from its general knowledge only." />
      )}

      {!alerts.loading && !alerts.error && (
        <>
          <div className="card" style={{ marginBottom: 12 }}>
            {turns.length === 0 ? (
              <EmptyState label="Ask a question below to get started." />
            ) : (
              turns.map((turn, i) => (
                <div key={i} style={{ marginBottom: 10 }}>
                  <strong>{turn.role === "user" ? "You" : "Ask ALRT"}:</strong>{" "}
                  {turn.text}
                  {turn.meta && (
                    <div style={{ fontSize: 11, color: "var(--color-text-muted)" }}>
                      source: {turn.meta.source}
                      {turn.meta.usedAI ? " (AI)" : ""}
                    </div>
                  )}
                </div>
              ))
            )}
          </div>

          {sendError && (
            <div className="state-block state-block--error" role="alert">
              {sendError}
            </div>
          )}

          <div style={{ display: "flex", gap: 8 }}>
            <input
              type="text"
              value={question}
              onChange={(e) => setQuestion(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === "Enter") void handleSend();
              }}
              placeholder="Ask about a current TEST alert..."
              disabled={sending}
              style={{ flex: 1 }}
            />
            <button
              type="button"
              className="btn"
              onClick={() => void handleSend()}
              disabled={sending || !question.trim()}
            >
              {sending ? "Asking..." : "Ask"}
            </button>
          </div>
        </>
      )}
    </div>
  );
};
