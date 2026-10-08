/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_BASE_URL: string;
  readonly VITE_ENABLE_DUMMY_ALERTS?: string;
  readonly VITE_USE_RELAY?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
