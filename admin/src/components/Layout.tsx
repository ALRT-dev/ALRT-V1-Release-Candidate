import { NavLink, Outlet } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";

const NAV_ITEMS: { to: string; label: string }[] = [
  { to: "/", label: "Dashboard" },
  { to: "/alerts", label: "Alerts" },
  { to: "/moderation", label: "Moderation" },
  { to: "/sources", label: "Sources" },
  { to: "/categories", label: "Categories / Icons" },
  { to: "/users", label: "Users" },
  { to: "/admin-accounts", label: "Admin Accounts" },
  { to: "/ai-prompts", label: "AI Prompts" },
  { to: "/configuration", label: "Configuration" },
  { to: "/webhook-keys", label: "Webhook API Keys" },
  { to: "/ask-alrt", label: "Ask ALRT" },
];

export const Layout = () => {
  const { admin, logout } = useAuth();

  return (
    <div className="app-shell">
      <aside className="app-sidebar">
        <div className="app-sidebar__brand">ALRT Admin</div>
        <nav>
          {NAV_ITEMS.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === "/"}
              className={({ isActive }) =>
                `app-sidebar__nav-link${isActive ? " active" : ""}`
              }
            >
              {item.label}
            </NavLink>
          ))}
        </nav>
        <div className="app-sidebar__footer">
          <div>{admin?.email}</div>
          <div>Role: {admin?.role}</div>
          <button
            type="button"
            className="btn btn-sm"
            style={{ marginTop: 8, width: "100%" }}
            onClick={() => void logout()}
          >
            Log out
          </button>
        </div>
      </aside>
      <main className="app-main">
        <Outlet />
      </main>
    </div>
  );
};
