const puppeteer = require('puppeteer-core');
const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

const BASE_URL = 'https://orgfarm-a68b986535-dev-ed.develop.my.salesforce.com';
const SCREENSHOTS_DIR = path.resolve(__dirname, '..', 'evidence', 'screenshots');

async function getFrontdoorUrl(targetPath) {
    const raw = execSync(`sf org open --path "${targetPath}" --url-only --json`, {
        cwd: path.resolve(__dirname, '..'),
        encoding: 'utf8'
    });
    return JSON.parse(raw).result.url;
}

async function waitAndCapture(page, targetPath, filename, waitMs = 8000) {
    console.log(`Navigating to ${targetPath}...`);
    await page.goto(BASE_URL + targetPath, { waitUntil: 'domcontentloaded', timeout: 90000 });
    
    // Wait for spinners and loading indicators to clear
    await new Promise(r => setTimeout(r, waitMs));
    try {
        await page.waitForFunction(() => {
            const spinners = document.querySelectorAll('.slds-spinner_container, .auraLoadingBox, .initial-loading');
            for (let s of spinners) {
                if (s.offsetParent !== null) return false;
            }
            return true;
        }, { timeout: 10000 });
    } catch (e) {
        // Continue if spinner check times out
    }
    await new Promise(r => setTimeout(r, 2000));

    const outPath = path.join(SCREENSHOTS_DIR, filename);
    await page.screenshot({ path: outPath, fullPage: false });
    console.log(`Saved: ${filename}`);
}

async function main() {
    if (!fs.existsSync(SCREENSHOTS_DIR)) {
        fs.mkdirSync(SCREENSHOTS_DIR, { recursive: true });
    }

    console.log('Obtaining initial frontdoor URL...');
    const loginUrl = await getFrontdoorUrl('/lightning/app/c__Reliefgrid');

    const browser = await puppeteer.launch({
        executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
        headless: 'new',
        defaultViewport: { width: 1440, height: 900 },
        args: [
            '--no-sandbox',
            '--disable-setuid-sandbox',
            '--disable-dev-shm-usage',
            '--disable-gpu',
            '--window-size=1440,900'
        ]
    });

    try {
        const page = await browser.newPage();
        await page.setViewport({ width: 1440, height: 900 });

        console.log('Logging in via frontdoor.jsp...');
        await page.goto(loginUrl, { waitUntil: 'domcontentloaded', timeout: 90000 });
        await new Promise(r => setTimeout(r, 12000));

        // 01: App home
        await page.screenshot({ path: path.join(SCREENSHOTS_DIR, '01_org_home_reliefgrid_app.png') });
        console.log('Captured 01_org_home_reliefgrid_app.png');

        // 02: Fields list for each of the 5 objects
        await waitAndCapture(page, '/lightning/setup/ObjectManager/Incident__c/FieldsAndRelationships/view', '02_fields_incident.png');
        await waitAndCapture(page, '/lightning/setup/ObjectManager/Volunteer__c/FieldsAndRelationships/view', '02_fields_volunteer.png');
        await waitAndCapture(page, '/lightning/setup/ObjectManager/Relief_Center__c/FieldsAndRelationships/view', '02_fields_relief_center.png');
        await waitAndCapture(page, '/lightning/setup/ObjectManager/Dispatch__c/FieldsAndRelationships/view', '02_fields_dispatch.png');
        await waitAndCapture(page, '/lightning/setup/ObjectManager/Resource_Request__c/FieldsAndRelationships/view', '02_fields_resource_request.png');

        // 03: Schema Builder
        await waitAndCapture(page, '/lightning/setup/SchemaBuilder/page?address=%2Fschemadesigner%2Fschemadesigner.apexp', '03_schema_builder.png', 12000);

        // 04: Volunteers list view (Available Volunteers) and detail record
        await waitAndCapture(page, '/lightning/o/Volunteer__c/list?filterName=Available_Volunteers', '04_volunteers_list_view.png');
        await waitAndCapture(page, '/lightning/r/Volunteer__c/a05g800000EEPPvAAP/view', '04_volunteer_record_location.png');

        console.log('Batch 1 complete!');
    } finally {
        await browser.close();
    }
}

main().catch(err => {
    console.error('Batch 1 failed:', err);
    process.exit(1);
});
