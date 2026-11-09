import { describe, expect, it } from 'vitest';
import { readCFSCap } from '../utils/cfs_cap.util.js';

const entry = (id: string, area: string) => `<entry><id>${id}</id><title>Example bushfire</title><content type="text/xml"><alert xmlns="urn:oasis:names:tc:emergency:cap:1.2"><identifier>${id}</identifier><sent>2026-10-15T19:51:35+10:30</sent><status>Actual</status><scope>Public</scope><msgType>Alert</msgType><info><language>en-AU</language><senderName>South Australian Country Fire Service</senderName><event>Fire</event><headline>Example bushfire</headline><description>Fire near Example Road.</description><parameter><valueName>WarningLevel</valueName><value>Watch and Act</value></parameter><area><areaDesc>Example Road</areaDesc>${area}</area></info></alert></content></entry>`;
const feed = (entries: string) => `<feed xmlns="http://www.w3.org/2005/Atom">${entries}</feed>`;
const good = entry('F2610150124-2026-10-15T19:51:35+10:30', '<circle>-33.03,138.43 0.0</circle>');
const bad = entry('F2610159999-2026-10-15T19:51:35+10:30', '<circle>invalid</circle>');

describe('CFS CAP partial failure', () => {
  it('skips one malformed record and keeps the rest', () => {
    expect(readCFSCap(feed(good + bad)).map(x => x.id)).toEqual(['cfs-F2610150124']);
  });
  it('still fails the fetch when no record is readable', () => {
    expect(() => readCFSCap(feed(bad))).toThrow();
  });
});
