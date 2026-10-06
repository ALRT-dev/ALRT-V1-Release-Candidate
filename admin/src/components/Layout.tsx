import { NavLink, Outlet } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";
import type { AdminRole } from "../api/types";

// `roles` hides a link from roles the backend would refuse anyway (UX
// only, the backend is still the gate). No `roles` means every admin role.
const NAV_ITEMS: { to: string; label: string; roles?: AdminRole[] }[] = [
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
  { to: "/ask-alrt-library", label: "Ask ALRT Answers" },
  { to: "/emergency-numbers", label: "Emergency Numbers" },
  { to: "/audit-log", label: "Audit Log", roles: ["superAdmin", "admin"] },
];

export const Layout = () => {
  const { admin, logout, hasRole } = useAuth();
  const navItems = NAV_ITEMS.filter((item) => !item.roles || hasRole(...item.roles));

  return (
    <div className="app-shell">
      <aside className="app-sidebar">
        <div className="app-sidebar__brand">ALRT Admin</div>
        <nav>
          {navItems.map((item) => (
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
          <NavLink to="/change-password" className="app-sidebar__nav-link">
            Change password
          </NavLink>
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
