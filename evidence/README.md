# ReliefGrid Build & Evidence Documentation

**Project:** ReliefGrid: Salesforce Admin + PD1 Capstone  
**Target Org Username:** `prajwal@reliefgrid.dev`  
**Org ID:** `00Dg800000Qib6YEAR`  
**Instance URL:** `https://orgfarm-a68b986535-dev-ed.develop.my.salesforce.com`  
**API Version:** `62.0`  
**Status:** 100% Complete & Verified  

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

---

## 2. Apex Test Execution & Code Coverage Report

Test Command Executed:
```bash
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

| Test Class | Test Method Name | Execution Time | Outcome | What It Proves |
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

## 4. Section 15.2 Screenshot Checklist & One-Click CLI Commands

Use these exact CLI commands in your terminal to open each required page directly in your browser:

### Section 1: Application Home
- **#1: Org home page showing the ReliefGrid app**
  ```powershell
  sf org open --path "/lightning/app/c__Reliefgrid"
  ```

### Section 2: Data Model & Relationships
- **#2: Fields list for each of the five objects**
  ```powershell
  # Incident__c
  sf org open --path "/lightning/setup/ObjectManager/Incident__c/FieldsAndRelationships/view"

  # Volunteer__c
  sf org open --path "/lightning/setup/ObjectManager/Volunteer__c/FieldsAndRelationships/view"

  # Relief_Center__c
  sf org open --path "/lightning/setup/ObjectManager/Relief_Center__c/FieldsAndRelationships/view"

  # Dispatch__c
  sf org open --path "/lightning/setup/ObjectManager/Dispatch__c/FieldsAndRelationships/view"

  # Resource_Request__c
  sf org open --path "/lightning/setup/ObjectManager/Resource_Request__c/FieldsAndRelationships/view"
  ```
- **#3: Schema Builder showing relationships**
  ```powershell
  sf org open --path "/lightning/setup/SchemaBuilder/page?address=%2Fschemadesigner%2Fschemadesigner.apexp"
  ```

### Section 4: Sample Data & Locations
- **#4: Volunteers list view and a record with its location**
  ```powershell
  # Available Volunteers list view
  sf org open --path "/lightning/o/Volunteer__c/list?filterName=Available_Volunteers"

  # Volunteer record detail (Meera Nair) showing Current Location geolocation
  sf org open --path "/lightning/r/Volunteer__c/a05g800000EEPPvAAP/view"
  ```

### Section 5: Validation Rules
- **#5: Each validation rule, plus one error on screen**
  ```powershell
  # Incident Validation Rules list
  sf org open --path "/lightning/setup/ObjectManager/Incident__c/ValidationRules/view"

  # Volunteer Validation Rules list
  sf org open --path "/lightning/setup/ObjectManager/Volunteer__c/ValidationRules/view"

  # Resource Request Validation Rules list
  sf org open --path "/lightning/setup/ObjectManager/Resource_Request__c/ValidationRules/view"

  # Dispatch Validation Rules list
  sf org open --path "/lightning/setup/ObjectManager/Dispatch__c/ValidationRules/view"

  # Error on screen: open INC-0002, edit Status to 'Resolved' without notes, click Save
  sf org open --path "/lightning/r/Incident__c/a06g800000AqlMsAAJ/view"
  ```

### Section 6: Queues & Flows
- **#6: Both queues and each of the three Flow canvases**
  ```powershell
  # Queues Setup list
  sf org open --path "/lightning/setup/Queues/home"

  # Flow 1: Incident Intake Routing canvas
  sf org open --path "/builder_platform_interaction/flowBuilder.app?flowId=301g800001Ap1ztAAB"

  # Flow 2: Resource Request Approved canvas
  sf org open --path "/builder_platform_interaction/flowBuilder.app?flowId=301g800001Ap1zvAAB"

  # Flow 3: Escalation Alert canvas
  sf org open --path "/builder_platform_interaction/flowBuilder.app?flowId=301g800001Ap1zuAAB"
  ```
- **#7: Incident with the queue as Owner**
  ```powershell
  # Incident INC-0002 showing Owner = Critical Response Queue
  sf org open --path "/lightning/r/Incident__c/a06g800000AqlMsAAJ/view"
  ```

### Section 7: Roles, Permissions & Security
- **#8: Role hierarchy**
  ```powershell
  sf org open --path "/lightning/setup/Roles/home"
  ```
- **#9: Both permission sets and the Field Volunteer field permissions**
  ```powershell
  # Permission Sets home list
  sf org open --path "/lightning/setup/PermSets/home"

  # ReliefGrid Coordinator Permission Set
  sf org open --path "/lightning/setup/PermSets/page?address=%2F0PSg800000Gcvwv"

  # ReliefGrid Field Volunteer Permission Set (inspect Object & Field Permissions)
  sf org open --path "/lightning/setup/PermSets/page?address=%2F0PSg800000Gcvww"
  ```
- **#10: Vikram's view with read-only fields**
  ```powershell
  # Open Users list to click "Login" next to Vikram Volunteer
  sf org open --path "/lightning/setup/ManageUsers/home"
  ```

### Section 8: Reports & Dashboard
- **#11: All five reports**
  ```powershell
  # Report 1: Incidents by Severity and Status
  sf org open --path "/lightning/r/Report/00Og800000A43HiEAJ/view"

  # Report 2: Volunteer Availability
  sf org open --path "/lightning/r/Report/00Og800000A43HlEAJ/view"

  # Report 3: Dispatch Performance
  sf org open --path "/lightning/r/Report/00Og800000A43HhEAJ/view"

  # Report 4: Open Resource Requests
  sf org open --path "/lightning/r/Report/00Og800000A43HjEAJ/view"

  # Report 5: Unattended Critical Incidents
  sf org open --path "/lightning/r/Report/00Og800000A43HkEAJ/view"
  ```
- **#12: The Command Center dashboard**
  ```powershell
  # ReliefGrid Command Center Dashboard
  sf org open --path "/lightning/r/Dashboard/01Zg8000004mUHdEAM/view"
  ```

### Section 9: Apex & Asynchronous Processing
- **#13: Each Apex class and the trigger in the Developer Console**
  ```powershell
  # Open Developer Console
  sf org open --path "/_ui/common/apex/debug/ApexCSIPage"

  # Apex Classes Setup list
  sf org open --path "/lightning/setup/ApexClasses/home"

  # Apex Triggers Setup list
  sf org open --path "/lightning/setup/ApexTriggers/home"
  ```
- **#14: Apex Jobs page and the incident's Dispatches with distances**
  ```powershell
  # Apex Jobs Setup list (showing completed Queueable and Batch jobs)
  sf org open --path "/lightning/setup/AsyncApexJobs/home"

  # INC-0001 Dispatches Related List showing DSP-0001 and DSP-0002 with distances in km
  sf org open --path "/lightning/r/Incident__c/a06g800000AqlMrAAJ/related/Dispatches__r/view"
  ```
- **#15: Scheduled Jobs page**
  ```powershell
  # Scheduled Jobs setup list showing 'ReliefGrid Escalation Hourly'
  sf org open --path "/lightning/setup/CronTrigger/home"
  ```

### Section 11: Live Relief Map LWC
- **#16: Live map with pins**
  ```powershell
  # Relief Map custom tab showing active incidents and volunteer locations
  sf org open --path "/lightning/n/Relief_Map"
  ```

### Section 12: Apex Test Execution & Coverage
- **#17: Test run with every method passing**
  ```powershell
  # Apex Test Execution History
  sf org open --path "/lightning/setup/ApexTestQueue/home"
  ```
- **#18: Overall and per-class code coverage**
  ```powershell
  # Apex Classes list with Percent Covered column
  sf org open --path "/lightning/setup/ApexClasses/home"
  ```
- **#19: Highlighted covered lines in one class**
  ```powershell
  # Open Developer Console -> Tests panel -> Double-click DispatchService -> Highlight
  sf org open --path "/_ui/common/apex/debug/ApexCSIPage"
  ```

---

## 5. Verification Checklist for Deliverability (Browser Check)

If you have not already enabled email deliverability, check it once in the browser:
```powershell
sf org open --path "/lightning/setup/OrgEmailSettings/home"
```
Ensure **Access level** is set to **All email** so Flow email alerts are dispatched properly.

---

## 6. ReliefGrid Home Page (Live Map + Critical Open Incidents + Embedded Dashboard)

A dedicated, comprehensive Home Page (`ReliefGrid_Home`) was created and wired into the `ReliefGrid` Lightning Application as its primary landing view (`standard-home` tab).

### Layout Configuration
- **Template:** `home:desktopTemplate` (Type: `HomePage`)
- **Top Region:** `c:reliefMap` (Live Interactive Map displaying active incident and volunteer pins with refresh action)
- **Sidebar Region:** `flexipage:filterListCard` (Displaying the `Critical_Open_Incidents` filtered list view on `Incident__c`)
- **Bottom Left Region:** `desktopDashboards:embeddedDashboard` (Embedded `ReliefGrid Command Center` dashboard)
- **App Navigation:** `standard-home` positioned as the 1st tab in `Reliefgrid.app-meta.xml` with `Tab` action override to `ReliefGrid_Home`.

### Command to View the Home Page
Run this command to open the Home page directly in your browser:
```powershell
sf org open --path "/lightning/page/home"
```
*(Ensure "ReliefGrid" is selected in the App Launcher if opening for the first time).*

### Screenshot to Capture
- **Home Page with Address Bar Visible:**
  Capture the Home page showing:
  1. The live Relief Map in the top region with active incident pin (`INC-0003`) and volunteer pins.
  2. The Critical Open Incidents list card in the sidebar showing `INC-0003`.
  3. The embedded Command Center dashboard below the map.
  4. The browser address bar showing the org URL (`/lightning/page/home`).

