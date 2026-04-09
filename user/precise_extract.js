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

// Map start: line 1556 (editor), index in split('\n') is 1555.
// But I'll use the char index.
const lines = content.split('\n');
let mapStartIdx = -1;
let currentPos = 0;
for (let i = 0; i < 1555; i++) currentPos += lines[i].length + 1;
mapStartIdx = currentPos + lines[1555].indexOf('Container(');

const mapWidget = extractWidget(mapStartIdx);
fs.writeFileSync('map_widget.txt', mapWidget);

let topBarStartIdx = mapStartIdx + mapWidget.length;
// Find next Positioned(
while (content.indexOf('Positioned(', topBarStartIdx) !== -1) {
    const nextIdx = content.indexOf('Positioned(', topBarStartIdx);
    const slice = content.substring(topBarStartIdx, nextIdx);
    if (slice.trim() === ',' || slice.trim() === '') {
        topBarStartIdx = nextIdx;
        break;
    }
    topBarStartIdx = nextIdx + 1;
}

const topBarWidget = extractWidget(topBarStartIdx);
fs.writeFileSync('topbar_widget.txt', topBarWidget);

console.log('Extracted precisely!');
