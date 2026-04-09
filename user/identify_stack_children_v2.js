const fs = require('fs');

const file = 'lib/pages/onTripPage/booking_confirmation.dart';
const content = fs.readFileSync(file, 'utf8');
const lines = content.split('\n');

// Find Stack start
let stackHeaderFound = false;
let childrenHeaderFound = false;
let stackSearchLine = -1;

for (let i = 0; i < lines.length; i++) {
    if (lines[i].includes('return Stack(')) {
        stackHeaderFound = true;
    }
    if (stackHeaderFound && lines[i].includes('children: [')) {
        childrenHeaderFound = true;
        stackSearchLine = i;
        break;
    }
}

if (!childrenHeaderFound) {
    console.error("Stack children not found");
    process.exit(1);
}

let children = [];
let currentChildStartLine = -1;
let bCount = 0; // brace
let pCount = 0; // paren
let brCount = 0; // bracket
let inStr = false;
let strChar = '';

// We are starting INSIDE the children: [ bracket.
// So we assume initial brCount is 1 relative to the file, but let's track globally.

// Actually, let's track globally for correctness.
bCount = 0; pCount = 0; brCount = 0; inStr = false;

for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    
    // Check if we are inside the stack children array
    if (i < stackSearchLine) {
        // Just track counts to reach state at stackSearchLine
        for (let j = 0; j < line.length; j++) {
            const c = line[j];
            const prev = j > 0 ? line[j-1] : '';
            if (inStr) { if (c === strChar && prev !== '\\') inStr = false; continue; }
            if (c === "'" || c === '"') { inStr = true; strChar = c; continue; }
            if (c === '{') bCount++; if (c === '}') bCount--;
            if (c === '(') pCount++; if (c === ')') pCount--;
            if (c === '[') brCount++; if (c === ']') brCount--;
        }
        continue;
    }

    // Now we are at or after 'children: ['
    for (let j = 0; j < line.length; j++) {
        const c = line[j];
        const prev = j > 0 ? line[j-1] : '';

        if (inStr) {
            if (c === strChar && prev !== '\\') inStr = false;
            continue;
        }

        if (c === "'" || c === '"') {
            inStr = true;
            strChar = c;
            continue;
        }

        if (c === '{') bCount++; if (c === '}') bCount--;
        if (c === '(') pCount++; if (c === ')') pCount--;
        if (c === '[') brCount++; if (c === ']') brCount--;

        // Inside the children array exactly
        if (brCount === 1 && bCount === 0 && pCount === 0) {
            // Find start of child
            if (currentChildStartLine === -1 && !/\s/.test(c) && c !== '[' && c !== ',') {
                currentChildStartLine = i;
            }
            // Find end of child (at top-level comma)
            if (c === ',' && currentChildStartLine !== -1) {
                children.push({ start: currentChildStartLine, end: i });
                currentChildStartLine = -1;
            }
            // Handle array end
        } else if (brCount === 0 && c === ']' && currentChildStartLine !== -1) {
             children.push({ start: currentChildStartLine, end: i });
             console.log(JSON.stringify(children, null, 2));
             process.exit(0);
        }
    }
}
