# Project Memory System

> **Purpose**: Capture creative intent, design decisions, and provide contextual briefings for seamless project continuation after breaks.

## Current State & Intentions

### **🎯 Active Work Stream**: ERA Trajectory Analysis - VALIDATION CHECKPOINT ⚠️
**Current Script**: `analysis/eda-2/eda-2.R` (COMPLETE)
**Status**: **PAUSED** - Awaiting expert validation of linkage methodology
**Critical Issue**: Low linkage rate (11.5%) between ERA approvals and Income Support episodes

**Project State (July 28, 2025)**:
- ✅ **ERA Analysis Complete**: 55,965 assessments analyzed, 9 comprehensive visualizations
- ✅ **Comparison Groups Created**: 4 groups for trajectory analysis (Direct Approval, Approved After Denial, Denied Only, Mixed)
- ✅ **Linkage Implementation**: ERA-to-IS linking logic implemented but concerning low success rate
- ⚠️ **Validation Request**: Letter to Bob created requesting methodology review
- 🛑 **Decision Point**: Cannot proceed with trajectory analysis until linkage approach validated

**Data Assets Created**:
- `ANALYSIS2_ERA_EVENT`: 55,965 ERA assessments with longitudinal tracking
- `ds_trajectory_groups`: 3,806 successfully linked ERA→IS cases (11.5% rate)
- Comprehensive EDA-2 report with approval pattern analysis

---

## 📝 Creative Intent Capture

### **Design Decisions Made**

1. **EDA-2 Analysis Architecture** (July 2025):
   - **Complete ERA pipeline**: 9 visualization sections covering approval patterns, demographic breakdowns, temporal trends
   - **Four-group comparison methodology**: Direct Approval (32,593), Approved After Denial (647), Denied Only (17,348), Mixed (1,443)
   - **Trajectory linkage logic**: person_oid + 3-month temporal window to connect ERA approvals to IS episodes
   - **Research focus**: "Scarring effects" hypothesis - do initial denials affect subsequent IS usage patterns?

2. **Critical Methodological Decision - VALIDATED & SUCCESSFUL**:
   - **Issue Identified**: Original linkage used exact ERA approval date vs IS episode start
   - **Problem**: IS spells always start on 1st of month; approval on 15th → IS starts on 1st (appears to precede assessment)
   - **Bob's Solution**: Use start of ERA assessment month instead of exact assessment date
   - **Implementation**: `era_month_start = floor_date(date_of_first_approval, "month")`
   - **Dramatic Success**: **Linkage rate improved from 11.5% to 54.2%** (nearly 5x improvement)
   - **Next Challenge**: Explore strategies to optimize remaining 45.8% unlinked cases

3. **Data Infrastructure Choices**:
   - **ERA Cohort**: ANALYSIS2_ERA_EVENT (ERA as inclusion criterion)
   - **IS Cohort**: ds_ellis ANALYSIS1 (IS as inclusion criterion)  
   - **Linking Strategy**: Cross-system person_oid matching
   - **Temporal Logic**: 3-month window for ERA→IS transition

4. **Approval Rate Definition** (validated methodology):
   - **Included**: "Approved" + "Denied" only (substantive decisions)
   - **Excluded**: "ApprovedOneTime", "Withdrawn", "Duplicate"
   - **Rationale**: Focus on true eligibility decisions, not emergency assistance

### **Research Strategy Evolution**
- **Phase 1 (Complete)**: Comprehensive ERA assessment pattern analysis
- **Phase 2 (Implemented, Requires Validation)**: ERA-to-Income Support trajectory linking
- **Phase 3 (Pending)**: Comparative analysis of Group 1 vs Group 2 IS usage patterns
- **Research Question**: Do initial denials create "scarring effects" affecting subsequent service usage?

**Critical Decision Point**: Cannot proceed to Phase 3 until linkage methodology validated by domain expert.

---

## 🔄 Next Steps & Unfinished Business

### **IMMEDIATE PRIORITY - Validation Required** ✅ **COMPLETED & VALIDATED**
1. **Bob's Response Received & Implemented** (July 28, 2025):
   - ✅ **Issue Identified**: Linkage methodology needed adjustment for monthly IS spell timing
   - ✅ **Solution Implemented**: Changed linkage to use start of ERA assessment month instead of exact date
   - ✅ **Rationale**: IS spells always start on 1st of month; approval on 15th → IS spell starts on 1st
   - ✅ **Code Updated**: Both eda-2.R and eda-2.qmd modified with improved linkage logic
   - ✅ **Results Validated**: **Linkage rate improved from 11.5% to 54.2%** (5x improvement!)

2. **Status: Ready for Phase 3** ⏳:
   - **Current**: 54.2% linkage rate is substantial improvement, though room for further optimization
   - **Available**: ds_trajectory_groups dataset with valid linked cases for analysis
   - **Next**: Trajectory analysis comparing Group 1 vs Group 2 IS usage patterns

### **Phase 3 Analysis (Ready to Start Wednesday)**
1. **Trajectory Comparison** 📊:
   - **Available Data**: ds_trajectory_groups with 54.2% linkage rate (~18,000+ linked cases)
   - **Group 1 (Direct Approval)**: Analyze IS usage patterns for "smooth" pathway clients
   - **Group 2 (Approved After Denial)**: Analyze IS usage patterns for "resilient" clients
   - **Statistical Comparison**: Test "scarring effects" hypothesis with substantial sample size
   - **Stream Analysis**: Compare duration patterns across A/B/C streams (already implemented)

2. **Technical Implementation Status**:
   - ✅ **Data Pipeline**: ERA → IS linkage methodology validated and working
   - ✅ **Analysis Framework**: Group-stream comparison chunk implemented
   - ✅ **Visualizations**: g10 & g11 charts for duration analysis by group and stream
   - ⏳ **Statistical Testing**: T-tests implemented, ready for interpretation
   - ⏳ **Policy Implications**: Ready for synthesis of findings

### **Next Session Priorities (Wednesday)**
1. **Interpret Results**: Analyze group-stream duration comparison outputs
2. **Statistical Significance**: Review t-test results for meaningful differences
3. **Policy Synthesis**: Connect findings to "scarring effects" hypothesis
4. **Future Optimization**: Consider strategies to improve 54.2% → higher linkage rate

### **Future Work (Beyond Current Scope)**
- Extend analysis to Groups 3 & 4 if interesting patterns emerge
- Longitudinal tracking of assessment patterns over time
- Regional/demographic deep dives based on initial findings

---

## 📊 Key Data Assets & Locations

### **Analysis-Ready Datasets**
1. **`ANALYSIS2_ERA_EVENT`**: 55,965 ERA assessments (complete)
   - Location: `[RESEARCH_PROJECT_CACHE_UAT].[P20250625].[ANALYSIS2_ERA_EVENT]`
   - Parquet: `./data-private/derived/manipulation/3-ellis-era-analysis2.parquet`

2. **`ds_trajectory_groups`**: 3,806 linked ERA→IS cases ⚠️ (validation pending)
   - Location: `[RESEARCH_PROJECT_CACHE_UAT].[P20250625].[ds_trajectory_groups]`
   - Created by: eda-2.R linking-to-income-support section

3. **`ds_ellis`**: 490,919 Income Support episodes (ANALYSIS1 cohort)
   - Location: `[RESEARCH_PROJECT_CACHE_UAT].[P20250625].[ds_ellis]`

### **Analysis Reports**
1. **EDA-2 Report**: `analysis/eda-2/eda-2.html` (complete)
   - 9 visualization sections covering ERA patterns
   - Approval rates by demographics, temporal trends
   - Four-group comparison framework

2. **Validation Request**: `data-private/derived/letter-to-bob.md`
   - Comprehensive methodology documentation
   - Specific validation questions for domain expert

---

## 🎯 When You Return: Quick Start Guide

### **Priority 1: Check for Bob's Response**
- Review any feedback on linkage methodology
- Implement suggested changes if needed
- Decide whether to proceed with current approach or modify

### **Priority 2: Resume Analysis**
If validation OK:
1. Open `analysis/eda-2/eda-2.R`
2. Add trajectory analysis section after "linking-to-income-support"
3. Focus on Group 1 vs Group 2 comparison using ds_trajectory_groups
4. Look for "scarring effects" in IS usage patterns

### **Priority 3: Context Refresh**
- Run `context_refresh()` for latest project status
- Review CACHE-manifest.md for any data updates
- Check if any new data assets have been created

### **Key Questions to Address Upon Return**:
1. Was 11.5% linkage rate validated as expected or methodology issue?
2. What trajectory differences exist between Direct Approval vs Approved After Denial?
3. Do initial denials create measurable "scarring effects" on service usage?
4. What policy implications emerge from the analysis?
   - Finish validation checks (missing values, data quality)
   - Link ANALYSIS2_ERA_EVENT to Income Support episodes
   - Create outcome measures (duration, recurrence patterns)

2. **Analysis Pipeline**:
   - Survival analysis comparing approved vs. denied clients
   - Duration modeling by stream and decision outcome
   - Visualization of client trajectories over time

### **Near-term (This Sprint)**
1. **Create EDA reports** for ANALYSIS2 cohort
2. **Build comparison tables** (approved vs. denied outcomes)
3. **Develop survival curves** for Income Support duration
4. **Statistical testing** for group differences

### **Strategic (Project Goals)**
1. **Quantify impact** of ERA decisions on IS usage patterns
2. **Evaluate effectiveness** of CEIS workshops for denied clients
3. **Estimate total IS usage** over follow-up periods
4. **Policy recommendations** based on findings

---

## 🧠 Technical Memory

### **Data Architecture Decisions**
- **ELLIS ISLAND** (`ds_ellis`): First-ever IS episodes (ANALYSIS1 cohort)
- **ERA EVENTS** (`ANALYSIS2_ERA_EVENT`): All ERA assessments with decisions
- **Linking Strategy**: `person_oid` for individual tracking across datasets, `compass_Assessment_ID` for linking assessments to decisions

### **Methodological Choices**
- **Cohort Definition**: First IS episode >= 2015-01-01 for temporal consistency
- **Stream Focus**: Stream B (moderate barriers) as primary research target
- **Longitudinal Tracking**: Multiple assessments per person for trajectory analysis
- **ERA assessment**: started in 2022, no data prior to that (EA,SND, NI were used instead)
### **Code Patterns Established**
- Standardized demographic categorization across all datasets
- Consistent variable naming conventions (age_category3, sex2, etc.)
- Database-first storage with local exports for analysis

---

## 🎬 Project Narrative

### **The Story So Far**
This project analyzes the impact of Employment Readiness Assessment (ERA) decisions on Income Support usage patterns. We're specifically interested in Stream B clients who undergo assessments and receive approval/denial decisions.

**Key Insight**: Rather than treating assessments as one-time events, we're tracking client evolution through multiple assessments to understand how barriers, streams, and decisions change over time.

**Current Chapter**: Building the ANALYSIS2 cohort to enable longitudinal comparison of approved vs. denied clients' subsequent Income Support usage.

### **Plot Points Reached**
1. ✅ **ANALYSIS1 Cohort**: First-ever IS episodes for baseline population
2. ✅ **ERA Assessment Data**: Linked assessments to eligibility decisions
3. 🚧 **ANALYSIS2 Cohort**: ALL ERA assessments with longitudinal tracking
4. ⏳ **Outcome Linkage**: Connect decisions to subsequent IS episodes
5. ⏳ **Survival Analysis**: Compare duration patterns by decision outcome

---

## 🔍 Context Refresh Triggers

### **When to Load Additional Context**
- Working with new data tables → Load `RDB-manifest.md`
- Workign with groomed and cached data → Load `cache-manifest.md`
- Starting analysis scripts → Load `method.md` and `cache-manifest.md`
- Writing reports → Load `glossary.md` and `mission.md`
- Encountering validation issues → Load `validation-tests.md`

### **Keyphrase Monitoring**
AI should watch for these phrases and suggest context updates:
- "compare approved vs denied" → Load method definitions
- "survival analysis" → Load statistical approach documentation
- "Stream B clients" → Load segmentation definitions
- "ERA decisions" → Load assessment process documentation

---

## 💡 Insights & Discoveries

### **Data Quality Insights**
- **High linkage success**: ~90%+ ERA assessments have linked decisions
- **Multiple assessments common**: Many clients undergo repeat ERAs
- **Decision patterns**: Some clients show decision changes over time
- **Withdrawal rates**: Need to understand reasons for withdrawn applications

### **Methodological Insights**
- **Longitudinal approach** reveals client trajectories better than cross-sectional
- **Stream classification** may change between assessments
- **Time-to-decision** varies significantly across cases
- **Assessment sequencing** provides natural experiment opportunities

---

## 🚨 Risk Factors & Monitoring

### **Technical Risks**
- **Data linkage**: Dependency on `compass_Assessment_ID` for decision linking
- **Cohort definition**: Changes to eligibility criteria affect comparability
- **Missing data**: Incomplete assessments or decisions bias results

### **Analytical Risks**
- **Selection bias**: Withdrawn applications may differ systematically
- **Temporal confounding**: Policy changes over 2015-2025 period
- **Stream migration**: Clients changing streams affects comparison validity

---

*Last Updated: 2025-07-28*
*Next Review: When starting new analysis phase or after project break*
