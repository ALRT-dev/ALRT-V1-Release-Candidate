import { describe, expect, it } from 'vitest';
import { sourceHealthObservation } from '../lib/sourceHealth';

const now = Date.parse('2026-11-13T12:00:00Z');
const recent = '2026-11-13T11:58:00Z';
const healthy = { healthStatus: 'healthy', scheduleMinutes: 2, lastHealthCheck: recent, lastSuccessfulFetch: recent };
describe('source health observations', () => {
  it('uses two scheduled intervals with a ten-minute floor', () => {
    expect(sourceHealthObservation(healthy, now)).toBe('Recent successful source check');
    expect(sourceHealthObservation({ ...healthy, lastHealthCheck: '2026-11-13T11:49:59Z' }, now)).toBe('Stale source check');
    expect(sourceHealthObservation({ ...healthy, scheduleMinutes: 15, lastHealthCheck: '2026-11-13T11:31:00Z' }, now)).toBe('Recent successful source check');
    expect(sourceHealthObservation({ ...healthy, scheduleMinutes: 15, lastHealthCheck: '2026-11-13T11:29:59Z' }, now)).toBe('Stale source check');
  });
  it.each([
    { scheduleMinutes: null }, { scheduleMinutes: 0 }, { lastHealthCheck: null },
    { lastHealthCheck: 'invalid' }, { lastHealthCheck: '2026-11-13T13:00:00Z' },
    { lastSuccessfulFetch: null }, { healthStatus: 'unknown' },
  ])('never calls incomplete observations healthy: %j', change => {
    expect(sourceHealthObservation({ ...healthy, ...change }, now)).toBe('Source health unverified');
  });
  it('keeps stored failure visible despite old or absent observation dates', () => {
    expect(sourceHealthObservation({ ...healthy, healthStatus: 'failing', lastHealthCheck: null }, now)).toBe('failing');
    expect(sourceHealthObservation({ ...healthy, healthStatus: 'stale' }, now)).toBe('Stale source check');
  });
});
