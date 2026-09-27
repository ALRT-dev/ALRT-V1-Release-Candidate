import { Navigate, Route, Routes } from "react-router-dom";
import { AuthProvider } from "./auth/AuthContext";
import { RequireAuth } from "./auth/RequireAuth";
import { ToastProvider } from "./components/ToastContext";
import { Layout } from "./components/Layout";
import { LoginPage } from "./pages/LoginPage";
import { DashboardPage } from "./pages/DashboardPage";
import { AlertsPage } from "./pages/AlertsPage";
import { ModerationPage } from "./pages/ModerationPage";
import { SourcesPage } from "./pages/SourcesPage";
import { CategoriesPage } from "./pages/CategoriesPage";
import { UsersPage } from "./pages/UsersPage";
import { AdminAccountsPage } from "./pages/AdminAccountsPage";
import { AIPromptsPage } from "./pages/AIPromptsPage";
import { ConfigurationPage } from "./pages/ConfigurationPage";
import { WebhookKeysPage } from "./pages/WebhookKeysPage";
import { AskAlrtPage } from "./pages/AskAlrtPage";

function App() {
  return (
    <AuthProvider>
      <ToastProvider>
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route
            element={
              <RequireAuth>
                <Layout />
              </RequireAuth>
            }
          >
            <Route path="/" element={<DashboardPage />} />
            <Route path="/alerts" element={<AlertsPage />} />
            <Route path="/moderation" element={<ModerationPage />} />
            <Route path="/sources" element={<SourcesPage />} />
            <Route path="/categories" element={<CategoriesPage />} />
            <Route path="/users" element={<UsersPage />} />
            <Route path="/admin-accounts" element={<AdminAccountsPage />} />
            <Route path="/ai-prompts" element={<AIPromptsPage />} />
            <Route path="/configuration" element={<ConfigurationPage />} />
            <Route path="/webhook-keys" element={<WebhookKeysPage />} />
            <Route path="/ask-alrt" element={<AskAlrtPage />} />
          </Route>
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </ToastProvider>
    </AuthProvider>
  );
}

export default App;
