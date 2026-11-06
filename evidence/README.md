# ReliefGrid Build & Evidence Documentation

**Project:** ReliefGrid: Salesforce Admin + PD1 Capstone  
**Target Org Username:** `prajwal@reliefgrid.dev`  
**Org ID:** `00Dg800000Qib6YEAR`  
**Instance URL:** `https://orgfarm-a68b986535-dev-ed.develop.my.salesforce.com`  
**API Version:** `62.0`  
**Status:** 100% Complete, Deployed & Verified  
**GitHub Repository:** [https://github.com/Prajwal020/reliefgrid.git](https://github.com/Prajwal020/reliefgrid.git)  

---

## 1. Phase Completion Status Table

| Phase | Description | Status | Key Artifacts / Highlights |
|---|---|---|---|
| **Step 0** | Schema Audit & Pre-flight | **PASSED** | Audited all 5 objects (`Relief_Center__c`, `Volunteer__c`, `Incident__c`, `Dispatch__c`, `Resource_Request__c`), preserved existing structures, identified and targeted only spec gaps. |
| **Phase 1** | Data Model & Admin Schema | **PASSED** | Added `Reported_Date__c` default (`NOW()`), `Relief_Center__c` Read sharing, `ControlledByParent` on Dispatch, formulas `Priority_Score__c` & `Hours_Open__c`, roll-up summary fields `Total_Dispatches__c` & `Active_Dispatches__c`, all 6 validation rules, 2 custom list views (`Critical_Open_Incidents`, `Available_Volunteers`), page layouts, and `ReliefGrid` Lightning App. |
| **Phase 2** | Queues, Flows, Roles, Perm Sets | **PASSED** | Queues `Critical_Response_Queue` and `General_Response_Queue`; 3 Flows deployed & active (`Incident_Intake_Routing`, `Resource_Request_Approved`, `Escalation_Alert`); Role hierarchy `Operations_Head` > `Regional_Coordinator` > `Field_Volunteer`; Permission sets `ReliefGrid_Coordinator` (full CRUD) and `ReliefGrid_Field_Volunteer` (read-only with restricted edit on Volunteer status/location and Dispatch status). |
| **Phase 3** | Core Apex Service & Queueable | **PASSED** | Deployed `DispatchService.cls`, `DispatchAssignmentJob.cls`, and `IncidentTriggerHandler.cls`. Supported both SObject Decimal and Double coordinate inputs. |
| **Phase 4** | Sample Data Ingestion | **PASSED** | Loaded 3 Relief Centers (with notification email `4mt23cs135@mite.ac.in`) and 10 Volunteers with realistic geolocations across Bengaluru using `scripts/load-data.apex`. |
| **Phase 5** | Trigger, Batch, Tests, LWC & Map | **PASSED** | Deployed `IncidentTrigger.trigger`, `IncidentEscalationBatch.cls`, `TestDataFactory.cls`, `DispatchServiceTest.cls`, `IncidentEscalationBatchTest.cls`, `MapMarkerController.cls`, `MapMarkerControllerTest.cls`, LWC `reliefMap`, FlexiPage App Page `Relief_Map`, and custom tab `Relief_Map`. |
| **Phase 6** | Hourly Escalation Scheduling | **PASSED** | Scheduled `ReliefGrid Escalation Hourly` (`0 0 * * * ?`). Verified via `CronTrigger`: State `WAITING`. |
| **Phase 7** | Test User Provisioning & Sharing | **PASSED** | Created `Aisha Coordinator` (`aisha.coordinator.00dg8@reliefgrid.dev`) with `Regional_Coordinator` role & coordinator permset; Created `Vikram Volunteer` (`vikram.volunteer.00dg8@reliefgrid.dev`) with `Field_Volunteer` role & field volunteer permset. |
| **Phase 8** | Custom Report Types, Reports & Dashboard | **PASSED** | Deployed Custom Report Type `Incidents_with_Dispatches`, folder `ReliefGrid_Reports`, all 5 Reports, and Lightning Dashboard `ReliefGrid_Command_Center` in `ReliefGrid_Dashboards`. |
| **Home Page** | ReliefGrid Home FlexiPage | **PASSED** | Created `ReliefGrid_Home` (Type: `HomePage`, template: `home:desktopTemplate`) with live `reliefMap` LWC, `Critical_Open_Incidents` sidebar card, and embedded `ReliefGrid_Command_Center` dashboard. Set as primary landing tab in `Reliefgrid` app. |

---

## 2. Apex Test Execution & Code Coverage Report

Test Command Executed:
```powershell
sf apex run test --class-names DispatchServiceTest IncidentEscalationBatchTest MapMarkerControllerTest --code-coverage --detailed-coverage --result-format human --wait 15
```

### Test Summary
- **Outcome:** **PASSED (100% Pass Rate)**
- **Tests Ran:** 8
- **Failures:** 0
- **Org-Wide Code Coverage:** **97%**
- **Test Run ID:** `707g800000uERRaAAO`

### Per-Class Code Coverage Breakdown

| Apex Class | Type | Coverage % | Uncovered Lines | Specification Target | Status |
|---|---|---|---|---|---|
| `DispatchService` | Service Class | **97%** | 53, 54 | ≥ 90% | **PASSED** |
| `IncidentTriggerHandler` | Trigger Handler | **100%** | None | ≥ 90% | **PASSED** |
| `DispatchAssignmentJob` | Queueable Apex | **88%** | 22 (Job chaining branch) | ≥ 75% | **PASSED** |
| `IncidentEscalationBatch` | Batch & Schedulable Apex | **100%** | None | ≥ 90% | **PASSED** |
| `MapMarkerController` | Aura/LWC Controller | **100%** | None | ≥ 90% | **PASSED** |
| `IncidentTrigger` | Apex Trigger | **100%** | None | ≥ 90% | **PASSED** |

### Individual Test Method Results

| Test Class | Test Method Name | Execution Time | Outcome | What It Proves (Use in Report Section 7) |
|---|---|---|---|---|
| `DispatchServiceTest` | `nearestVolunteersAreFilteredAndOrdered` | 87 ms | **Pass** | SOQL `DISTANCE()` filters by status (`Available`), skill (`Medical`), radius (< 50 km), and sorts closest first. |
| `DispatchServiceTest` | `newIncidentDispatchesNearestVolunteersAndMarksThemBusy` | 198 ms | **Pass** | End-to-end trigger + Queueable job creates Dispatch records with calculated distance in km and sets volunteer status to `Busy`. |
| `DispatchServiceTest` | `higherPriorityIncidentGetsTheOnlyVolunteer` | 191 ms | **Pass** | Priority ordering: Critical incident claims sole available volunteer over Low incident. |
| `DispatchServiceTest` | `resolvingIncidentReleasesVolunteers` | 211 ms | **Pass** | Resolving incident closes Dispatches (`Completed`) and returns volunteers to `Available`. |
| `DispatchServiceTest` | `bulkIncidentsNeverDoubleBookVolunteers` | 754 ms | **Pass** | Bulk safety: 20 simultaneous incidents never double-assign the 10 available volunteers. |
| `IncidentEscalationBatchTest` | `escalatesOnlyOverdueUnattendedIncidents` | 667 ms | **Pass** | Batch query locator isolates unattended Critical (>1 hr) and High (>3 hr) incidents and marks `Escalated`. |
| `IncidentEscalationBatchTest` | `jobCanBeScheduledHourly` | 260 ms | **Pass** | Schedulable interface properly registers cron expression `0 0 * * * ?` in `CronTrigger`. |
| `MapMarkerControllerTest` | `returnsActiveIncidentsAndNonOfflineVolunteers` | 337 ms | **Pass** | Map controller wire method returns non-resolved incidents and non-offline volunteers with coordinate payloads. |

---

## 3. End-to-End Demo Script Execution Summary (Section 13)

| Step | Action | Expected Spec Outcome | Verified Result |
|---|---|---|---|
| **a** | Insert Critical Flood incident at `(12.9250, 77.6200)` needing 2 Rescue volunteers. | Flow 1 assigns Owner to Critical Response Queue. Trigger enqueues Queueable. Nearest 2 Rescue volunteers dispatched with distances, marked Busy, Incident status becomes `Assigned`. | **Verified (`INC-0001`):** Owner = `Critical Response Queue`, 2 dispatches created (`DSP-0001`: Meera Nair @ 1.23 km; `DSP-0002`: Imran Khan @ 1.62 km). Both volunteers marked `Busy`. Incident status `Assigned`, `Active_Dispatches__c = 2`. |
| **b** | Insert High Medical incident at `(15.3000, 75.1000)` (Hubli, >300 km away). | Flow 1 routes to Critical Response Queue. Queueable finds 0 volunteers within 50 km. Incident status remains `New`. | **Verified (`INC-0002`):** Owner = `Critical Response Queue`, 0 dispatches created, status remains `New`. |
| **c** | Attempt to update `INC-0001` Status to `Resolved` without `Resolution_Notes__c`. | Validation rule `Incident__c.Resolution_Notes_Required` throws error and blocks update. | **Verified:** Threw `FIELD_CUSTOM_VALIDATION_EXCEPTION: Add resolution notes before resolving an incident.`. Blocked update. |
| **d** | Update `INC-0001` Status to `Resolved` with resolution notes. | Trigger calls `releaseVolunteers`: dispatches marked `Completed`, volunteers returned to `Available`, `Active_Dispatches__c` rolls up to 0. | **Verified:** `DSP-0001` & `DSP-0002` marked `Completed`; Meera Nair & Imran Khan updated to `Available`; `INC-0001.Active_Dispatches__c` = 0. |
| **e** | Backdate `INC-0002.Reported_Date__c` by 4 hours and execute `IncidentEscalationBatch`. | Batch sets `Status__c = 'Escalated'` and `Escalated__c = true`. Flow 3 (`Escalation_Alert`) fires email to `4mt23cs135@mite.ac.in`. | **Verified:** `INC-0002` updated to `Escalated`, `Escalated__c = true`. Flow 3 executed send email action. |
| **f** | Insert `Resource_Request__c` for `INC-0002` linked to `Central Relief Camp`, then update Status to `Approved`. | Flow 2 (`Resource_Request_Approved`) triggers and emails Relief Center contact (`4mt23cs135@mite.ac.in`). | **Verified (`RR-0001`):** Status updated to `Approved`. Flow 2 triggered send email action with quantity and incident name in body. |

---

## 4. Master Screenshot Guide for Final Project Report

> [!IMPORTANT]
> **Guidelines for Report Screenshots (from PDF Section 15):**
> 1. Always keep the **browser address bar visible** showing the URL with your org domain (`orgfarm-a68b986535-dev-ed.develop.my.salesforce.com`).
> 2. Ensure each screenshot is clean, high resolution, and accompanied by the exact 2-line caption provided below.

### Screenshot Master Table

| # | Spec Section | Target Screen | Purpose / Caption | One-Click CLI Launch Command |
|---|---|---|---|---|
| **1** | Sec 1 | App Launcher / Home | ReliefGrid Lightning App home view showing navigation tabs. | `sf org open --path "/lightning/app/c__Reliefgrid"` |
| **2a** | Sec 2 | Incident Fields | Custom fields, formulas (`Priority_Score__c`, `Hours_Open__c`) and roll-ups on `Incident__c`. | `sf org open --path "/lightning/setup/ObjectManager/Incident__c/FieldsAndRelationships/view"` |
| **2b** | Sec 2 | Volunteer Fields | Geolocation and picklist fields on `Volunteer__c`. | `sf org open --path "/lightning/setup/ObjectManager/Volunteer__c/FieldsAndRelationships/view"` |
| **2c** | Sec 2 | Relief Center Fields | Geolocation, capacity, and contact email on `Relief_Center__c`. | `sf org open --path "/lightning/setup/ObjectManager/Relief_Center__c/FieldsAndRelationships/view"` |
| **2d** | Sec 2 | Dispatch Fields | Master-Detail relationship to Incident and distance fields on `Dispatch__c`. | `sf org open --path "/lightning/setup/ObjectManager/Dispatch__c/FieldsAndRelationships/view"` |
| **2e** | Sec 2 | Resource Request Fields | Quantity and status tracking on `Resource_Request__c`. | `sf org open --path "/lightning/setup/ObjectManager/Resource_Request__c/FieldsAndRelationships/view"` |
| **3** | Sec 2 | Schema Builder | Visual entity-relationship diagram with all 5 ReliefGrid objects. | `sf org open --path "/lightning/setup/SchemaBuilder/page?address=%2Fschemadesigner%2Fschemadesigner.apexp"` |
| **4a** | Sec 4 | Available Volunteers List | Filtered list view showing available field volunteers. | `sf org open --path "/lightning/o/Volunteer__c/list?filterName=Available_Volunteers"` |
| **4b** | Sec 4 | Volunteer Detail Record | Volunteer detail page (Meera Nair) showing Geolocation coordinates. | `sf org open --path "/lightning/r/Volunteer__c/a05g800000EEPPvAAP/view"` |
| **5a** | Sec 5 | Validation Rules List | Active validation rules across ReliefGrid objects. | `sf org open --path "/lightning/setup/ObjectManager/Incident__c/ValidationRules/view"` |
| **5b** | Sec 5 | Validation Error on Screen | Screen error when attempting to resolve incident without notes. | `sf org open --path "/lightning/r/Incident__c/a06g800000AqlMsAAJ/view"` |
| **6a** | Sec 6 | Queues List | Critical Response Queue and General Response Queue configuration. | `sf org open --path "/lightning/setup/Queues/home"` |
| **6b** | Sec 6 | Flow 1 Canvas | `Incident_Intake_Routing` before-save Fast Field Update flow. | `sf org open --path "/builder_platform_interaction/flowBuilder.app?flowId=301g800001Ap1ztAAB"` |
| **6c** | Sec 6 | Flow 2 Canvas | `Resource_Request_Approved` record-triggered email alert flow. | `sf org open --path "/builder_platform_interaction/flowBuilder.app?flowId=301g800001Ap1zvAAB"` |
| **6d** | Sec 6 | Flow 3 Canvas | `Escalation_Alert` record-triggered escalation email alert flow. | `sf org open --path "/builder_platform_interaction/flowBuilder.app?flowId=301g800001Ap1zuAAB"` |
| **7** | Sec 6 | Queue Ownership | Incident detail page showing Owner as `Critical Response Queue`. | `sf org open --path "/lightning/r/Incident__c/a06g800000AqlMsAAJ/view"` |
| **8** | Sec 7 | Role Hierarchy | Operations Head > Regional Coordinator > Field Volunteer tree. | `sf org open --path "/lightning/setup/Roles/home"` |
| **9a** | Sec 7 | Permission Sets List | `ReliefGrid_Coordinator` and `ReliefGrid_Field_Volunteer` sets. | `sf org open --path "/lightning/setup/PermSets/home"` |
| **9b** | Sec 7 | Field Volunteer FLS | Restricted Field-Level Security for volunteer user. | `sf org open --path "/lightning/setup/PermSets/page?address=%2F0PSg800000Gcvww"` |
| **10** | Sec 7 | Vikram Logged-in View | Read-only enforcement when viewing incident as Vikram Volunteer. | `sf org open --path "/lightning/setup/ManageUsers/home"` |
| **11a** | Sec 8 | Report 1 | Incidents by Severity and Status summary report. | `sf org open --path "/lightning/r/Report/00Og800000A43HiEAJ/view"` |
| **11b** | Sec 8 | Report 2 | Volunteer Availability matrix report. | `sf org open --path "/lightning/r/Report/00Og800000A43HlEAJ/view"` |
| **11c** | Sec 8 | Report 3 | Dispatch Performance grouped report with distances. | `sf org open --path "/lightning/r/Report/00Og800000A43HhEAJ/view"` |
| **11d** | Sec 8 | Report 4 | Open Resource Requests grouped report with sums. | `sf org open --path "/lightning/r/Report/00Og800000A43HjEAJ/view"` |
| **11e** | Sec 8 | Report 5 | Unattended Critical Incidents report with Hours Open formula. | `sf org open --path "/lightning/r/Report/00Og800000A43HkEAJ/view"` |
| **12** | Sec 8 | Command Center Dashboard | 5-component Lightning Dashboard with Donut, Bar, Metric, and Tables. | `sf org open --path "/lightning/r/Dashboard/01Zg8000004mUHdEAM/view"` |
| **13a** | Sec 9 | Apex Classes List | All 7 custom Apex classes in Setup showing code coverage %. | `sf org open --path "/lightning/setup/ApexClasses/home"` |
| **13b** | Sec 9 | Apex Trigger | `IncidentTrigger` in Setup / Developer Console. | `sf org open --path "/lightning/setup/ApexTriggers/home"` |
| **14a** | Sec 9 | Apex Jobs Monitor | Completed asynchronous Queueable and Batch job executions. | `sf org open --path "/lightning/setup/AsyncApexJobs/home"` |
| **14b** | Sec 9 | Dispatches Related List | Incident related list showing automatic dispatches with distances in km. | `sf org open --path "/lightning/r/Incident__c/a06g800000AqlMrAAJ/related/Dispatches__r/view"` |
| **15** | Sec 9 | Scheduled Jobs | `ReliefGrid Escalation Hourly` job waiting in CronTrigger queue. | `sf org open --path "/lightning/setup/CronTrigger/home"` |
| **16** | Sec 11 | Live Relief Map Tab | Standalone LWC map showing Bangalore pins with refresh action. | `sf org open --path "/lightning/n/Relief_Map"` |
| **17** | Sec 12 | Apex Test Execution History | Apex Test Queue showing 100% test pass rate across all 8 tests. | `sf org open --path "/lightning/setup/ApexTestQueue/home"` |
| **18** | Sec 12 | Code Coverage Breakdown | 97% overall org code coverage in Apex Classes Setup table. | `sf org open --path "/lightning/setup/ApexClasses/home"` |
| **19** | Sec 12 | Developer Console Highlight | Developer Console showing green highlighted covered lines in `DispatchService`. | `sf org open --path "/_ui/common/apex/debug/ApexCSIPage"` |
| **20** | Bonus | ReliefGrid Home Page | Complete Command Home Page with Live Map, Critical Incidents, and Dashboard. | `sf org open --path "/lightning/page/home"` |

---

## 5. Report Writing Outline & Viva Presentation Guide

### 5.1 Report Outline (Section 15.1 Mappings)

1. **Title Page:** Project title (*ReliefGrid: Disaster Relief & Volunteer Dispatch Platform*), Student Name (*Prajwal*), Roll Number, Course, Date.
2. **Problem Statement & Objectives:** Disaster response operations require real-time, location-aware matching of skilled volunteers to critical incidents while avoiding double-booking and governor limit exhaustion.
3. **Requirement Mapping:** Map every spec feature from Section 0 (Data model, Flows, Queues, Roles, Permissions, Trigger, Queueable, Batch, Schedule, LWC).
4. **System Architecture & ERD:**
   - Five-step workflow: Incident Logged -> Intake Flow (Queue routing) -> Trigger -> Queueable (`DISTANCE` SOQL) -> Dispatch creation -> Release on Resolution -> Hourly Batch Escalation.
   - Insert Screenshot #3 (Schema Builder).
5. **Admin Implementation:**
   - 6 Validation Rules (Insert Screenshot #5a & #5b).
   - 2 Queues (`Critical_Response_Queue`, `General_Response_Queue`).
   - 3 Record-Triggered Flows (Insert Screenshots #6b, #6c, #6d).
   - Role Hierarchy & FLS Security (Insert Screenshots #8, #9a, #9b, #10).
   - 5 Reports & 1 Command Center Dashboard (Insert Screenshots #11a-e, #12).
6. **Development Implementation:**
   - Geolocation SOQL with `DISTANCE(Current_Location__c, GEOLOCATION(:lat, :lon), 'km')`.
   - Asynchronous Queueable Apex (`DispatchAssignmentJob`) architecture and SOQL governor limit mitigation.
   - Batch & Schedulable Apex (`IncidentEscalationBatch`) with hourly cron.
   - Lightning Web Component (`reliefMap`) with Lightning Map integration.
7. **Testing & Quality Assurance:**
   - Test execution results table (8 tests, 100% pass rate).
   - Per-class coverage table (Org Wide: 97%).
   - Insert Screenshots #17, #18, #19.
8. **End-to-End Demo Script:** Walk through Section 13 demo steps (a through f) with corresponding output logs.
9. **Challenges & Key Learnings:**
   - *Governor Limits in Triggers:* Why distance calculations and volunteer matching must run asynchronously in Queueable Apex.
   - *Double-Booking Prevention:* Maintaining in-memory `used` volunteer sets across concurrent incidents.
   - *Apex Decimal vs Double Handling:* SObject geolocation fields return `Decimal`, requiring proper signature resolution in distance calculations.
10. **Conclusion & Future Scope:** Mobile volunteer app with GPS tracking, SMS integration via Twilio/Experience Cloud, offline support.
11. **Appendix:** Verbatim source code for Apex classes, triggers, and LWC.

---

### 5.2 Key Points to Stress During Viva / Evaluation

- **Location-Based SOQL:** Uses Salesforce's native `DISTANCE()` and `GEOLOCATION()` functions in SOQL queries to filter volunteers within `SEARCH_RADIUS_KM` (50 km) and sort by proximity at the database layer.
- **Asynchronous Design:** Trigger enqueues a Queueable job rather than running queries synchronously. This protects transaction time, avoids the 100-query governor limit, and allows self-chaining if query limits approach thresholds.
- **Priority-First Allocation:** Incidents are queried ordered by `Priority_Score__c DESC` so critical emergencies secure scarce volunteers first.
- **Double-Booking Guard:** A `Set<Id> used` keeps track of volunteers allocated in the current execution context so no single volunteer is assigned to multiple active incidents simultaneously.
- **Least-Privilege Security:** Field Volunteers cannot modify incident records or delete data, and can only edit their own location and dispatch status via custom permission sets and sharing settings.

---

## 6. Deliverability Check

Verify email deliverability in Setup so all Flow emails (Flow 2 & Flow 3) dispatch cleanly:
```powershell
sf org open --path "/lightning/setup/OrgEmailSettings/home"
```
Ensure **Access level** is set to **All email**.
