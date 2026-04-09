const fs = require('fs');

const file = 'lib/pages/onTripPage/booking_confirmation.dart';
const content = fs.readFileSync(file, 'utf8');

function extractWidget(startIndex) {
    let pCount = 0;
    let bCount = 0;
    let brCount = 0;
    let inStr = false;
    let strChar = '';
    let startFound = false;

    for (let i = startIndex; i < content.length; i++) {
        const c = content[i];
        const prev = i > 0 ? content[i-1] : '';

        if (inStr) {
            if (c === strChar && prev !== '\\') inStr = false;
            continue;
        }

        if (c === "'" || c === '"') {
            inStr = true;
            strChar = c;
            continue;
        }

        if (c === '(') { pCount++; startFound = true; }
        if (c === ')') pCount--;
        if (c === '{') { bCount++; startFound = true; }
        if (c === '}') bCount--;
        if (c === '[') { brCount++; startFound = true; }
        if (c === ']') brCount--;

        if (startFound && pCount === 0 && bCount === 0 && brCount === 0) {
            return content.substring(startIndex, i + 1);
        }
    }
    return null;
}

const targets = [
    { name: '_buildNoDriverFoundOverlay', pattern: '(noDriverFound == true)' },
    { name: '_buildTripReqErrorOverlay', pattern: '(tripReqError == true)' },
    { name: '_buildServiceNotAvailableOverlay', pattern: '(serviceNotAvailable)' },
    { name: '_buildLowWalletOverlay', pattern: '(islowwalletbalance == true)' }
];

targets.forEach(t => {
    const startIdx = content.indexOf(t.pattern);
    if (startIdx !== -1) {
        const widget = extractWidget(startIdx);
        fs.writeFileSync(t.name + '.txt', widget);
        console.log(`Extracted ${t.name}`);
    } else {
        console.log(`Failed to find ${t.pattern}`);
    }
});
