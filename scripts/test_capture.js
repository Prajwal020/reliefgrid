const puppeteer = require('puppeteer-core');
const { execSync } = require('child_process');
const path = require('path');

async function getFrontdoorUrl(targetPath) {
    const raw = execSync(`sf org open --path "${targetPath}" --url-only --json`, {
        cwd: path.resolve(__dirname, '..'),
        encoding: 'utf8'
    });
    const parsed = JSON.parse(raw);
    return parsed.result.url;
}

async function run() {
    console.log('Fetching frontdoor URL for /lightning/app/c__Reliefgrid...');
    // Open directly with the ReliefGrid app in context
    const url = await getFrontdoorUrl('/lightning/app/c__Reliefgrid');
    console.log('Launching Chrome...');

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
        console.log('Navigating to frontdoor URL...');
        await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 90000 });

        console.log('Waiting for Lightning navigation bar...');
        await page.waitForFunction(() => {
            return document.querySelector('one-app-nav-bar') !== null || 
                   document.querySelector('one-app-header') !== null ||
                   document.querySelector('.slds-global-header') !== null;
        }, { timeout: 90000 });

        console.log('Waiting for content to render...');
        // Wait 12 seconds for full rendering of components
        await new Promise(r => setTimeout(r, 12000));

        const outPath = path.resolve(__dirname, '..', 'evidence', 'screenshots', '01_org_home_reliefgrid_app.png');
        await page.screenshot({ path: outPath, fullPage: false });
        console.log('Screenshot saved to:', outPath);
    } finally {
        await browser.close();
    }
}

run().catch(err => {
    console.error('Error running test screenshot:', err);
    process.exit(1);
});
