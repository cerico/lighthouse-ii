const fs = require('fs');
const { urls } = require('./urls');
const puppeteer = require('puppeteer');
const lighthouse = require('lighthouse');
const config = require('lighthouse/lighthouse-core/config/lr-desktop-config.js');
const reportGenerator = require('lighthouse/report/generator/report-generator');
const reportsLocation = '/var/www/html/lighthouses.io37.ch';

(async() => {
  let browser = null;
  let page = null;

  try {
    console.log('try')
    browser = await navigateToIndex();
    page = (await browser.pages())[0];

    console.log('Running Lighthouse...');

    for(let i = 0; i < urls.length; i += 1) {
      const report = await lighthouse(`https://${urls[i].url}`, {
        port: (new URL(browser.wsEndpoint())).port,
        output: 'json',
        logLevel: 'info',
        disableDeviceEmulation: true,
        chromeFlags: ['--disable-mobile-emulation']
    }, config);
      const json = reportGenerator.generateReport(report.lhr, 'json');
      const html = reportGenerator.generateReport(report.lhr, 'html');
      fs.writeFileSync(`${reportsLocation}/${urls[i].url.replace(/\//g, '-')}.json`, json);
      fs.writeFileSync(`${reportsLocation}/${urls[i].url.replace(/\//g, '-')}.html`, html);
    }
    console.log('Done!');
  } catch (error) {
    console.error('Error!', error);
  } finally {
    await page.close();
    await browser.close();
  }
})();

async function navigateToIndex() {
    const browser = await puppeteer.launch({ headless: true });
    const page = await browser.newPage();

    console.log('Login success!');
    return browser;
}
