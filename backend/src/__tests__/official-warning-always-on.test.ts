import {describe,it,expect} from "vitest";
import {isAlwaysOnOfficialWarning,buildPushSettingsUserWhere,ALWAYS_ON_OFFICIAL_WHERE,ALWAYS_ON_OFFICIAL_SQL} from "../utils/official_warning.util.js";

describe("agreed always-on official warning rules",()=>{
  for (const [severity,severityBand] of [["advice","monitor"],["watchAndAct","action"],["emergency","critical"]]) {
    it(`keeps AWS ${severity} visible and eligible for push regardless of optional switches`,()=>{
      const warning={isAwsCompliant:true,reportedById:null,severity,severityBand};
      expect(isAlwaysOnOfficialWarning(warning)).toBe(true);
      expect(buildPushSettingsUserWhere(warning,"bushfire")).toEqual({});
    });
  }
  it("does not turn resolved or test Info updates, unknown levels, or community claims into always-on warnings",()=>{
    expect(isAlwaysOnOfficialWarning({isAwsCompliant:true,severity:"emergency",severityBand:"info"})).toBe(false);
    expect(isAlwaysOnOfficialWarning({isAwsCompliant:true,severity:"unknown",severityBand:"monitor"})).toBe(false);
    expect(isAlwaysOnOfficialWarning({isAwsCompliant:true,severity:"emergency",severityBand:"critical",reportedById:"user"})).toBe(false);
  });
  it("retains official critical exemption and all three levels in database query forms",()=>{
    expect(isAlwaysOnOfficialWarning({isAwsCompliant:false,severityBand:"critical",reportedById:null})).toBe(true);
    for(const level of ["advice","watchAndAct","emergency"]){
      expect(JSON.stringify(ALWAYS_ON_OFFICIAL_WHERE)).toContain(level);
      expect(ALWAYS_ON_OFFICIAL_SQL).toContain(level);
    }
  });
});
