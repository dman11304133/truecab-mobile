const fs = require('fs');

const file = fs.readFileSync('lib/pages/onTripPage/booking_confirmation.dart', 'utf-8');
const lines = file.split('\n');

// Find the line where the main Stack children start
let stackStart = -1;
for (let i = 0; i < lines.length; i++) {
  if (lines[i].includes('return Stack(') && lines[i+1].includes('alignment:') && lines[i+2].includes('children: [')) {
    stackStart = i + 2;
    break;
  }
}

if (stackStart === -1) {
  console.log("Could not find Stack start");
  process.exit(1);
}

const stackChildren = [];
let braceCount = 0;
let bracketCount = 0;
let parenCount = 0;
let inString = false;
let stringChar = '';

// From stackStart, read until the Stack children array closes
let currentChildStart = -1;
for (let i = stackStart; i < lines.length; i++) {
  const line = lines[i];
  
  for (let j = 0; j < line.length; j++) {
    const char = line[j];
    const prevChar = j > 0 ? line[j-1] : '';

    if (inString) {
      if (char === stringChar && prevChar !== '\\') {
        inString = false;
      }
      continue;
    }

    if (char === "'" || char === '"') {
      inString = true;
      stringChar = char;
      continue;
    }

    if (char === '{') braceCount++;
    if (char === '}') braceCount--;
    if (char === '(') parenCount++;
    if (char === ')') parenCount--;
    if (char === '[') bracketCount++;
    if (char === ']') bracketCount--;

    // Inside the 'children: [' bracket scope exactly
    if (braceCount === 0 && parenCount === 0 && bracketCount === 1) {
      // Find the start of the next top-level item if we don't have one
      if (currentChildStart === -1 && /[a-zA-Z]/.test(char)) {
        currentChildStart = i; // Save line number
      }
      
      // If we see a comma at the top level, the current child is done
      if (char === ',' && currentChildStart !== -1) {
        stackChildren.push({
          start: currentChildStart,
          end: i
        });
        currentChildStart = -1;
      }
    }

    // Stack children array closing
    if (bracketCount === 0 && char === ']') {
       // if there was a child with no trailing comma
       if (currentChildStart !== -1) {
         stackChildren.push({
           start: currentChildStart,
           end: i
         });
       }
       console.log('Stack ends at line', i);
       console.log(JSON.stringify(stackChildren, null, 2));
       process.exit(0);
    }
  }
}
