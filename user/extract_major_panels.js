const fs = require('fs');

const file = 'lib/pages/onTripPage/booking_confirmation.dart';
const content = fs.readFileSync(file, 'utf8');

function extractBlock(startIndex) {
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
            inStr = true; strChar = c; continue;
        }

        if (c === '(') { pCount++; startFound = true; }
        if (c === ')') pCount--;
        if (c === '{') { bCount++; startFound = true; }
        if (c === '}') bCount--;
        if (c === '[') { brCount++; startFound = true; }
        if (c === ']') brCount--;

        if (startFound && pCount === 0 && bCount === 0 && brCount === 0) {
            let nextIdx = i + 1;
            while(nextIdx < content.length && /\s/.test(content[nextIdx])) nextIdx++;
            if (content[nextIdx] === '?' || content[nextIdx] === ':') continue;
            if (content[nextIdx] === ',' || content[nextIdx] === ']' || content[nextIdx] === ';') {
                return content.substring(startIndex, i + 1);
            }
        }
    }
    return null;
}

const targets = [
    { name: '_buildSheetHeightToggle', pattern: 'if (_chooseGoodsType && choosenTransportType == 1' },
    { name: '_buildRideSelectionSheet', pattern: '//show bottom nav bar for choosing ride type' },
    { name: '_buildPaymentMethodOverlay', pattern: '(_choosePayment == true)' },
    { name: '_buildDriverSearchPanel', pattern: "(userRequestData.isNotEmpty && userRequestData['accepted_at'] == null)" },
    { name: '_buildOnTripPanel', pattern: "(userRequestData.isNotEmpty && userRequestData['accepted_at'] != null)" }
];

targets.forEach(t => {
    let startIdx = content.indexOf(t.pattern);
    if (startIdx !== -1) {
        // If it's a comment, we need to find the actual widget start after it
        if (t.pattern.startsWith('//')) {
            startIdx = content.indexOf('(', startIdx);
        }
        const block = extractBlock(startIdx);
        if (block) {
            fs.writeFileSync(t.name + '.txt', block);
            console.log(`Extracted ${t.name}`);
        } else {
            console.log(`Failed to extract block for ${t.name}`);
        }
    } else {
        console.log(`Failed to find ${t.pattern}`);
    }
});
