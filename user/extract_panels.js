const fs = require('fs');
const path = 'C:\\Users\\FergentiusRosales\\Herd\\truecabtt\\mobileapp\\user\\lib\\pages\\onTripPage\\booking_confirmation.dart';
let lines = fs.readFileSync(path, 'utf8').split(/\r?\n/);

// Phase 2: Step 2 & 3 - Extract Searching and On-Trip
// Line numbers from current file (1-indexed)
let searchStart = 1612;
let searchEnd = 2351;
let tripStart = 2352;
let tripEnd = 9143;

// Extract blocks
let searchingBlock = lines.slice(searchStart - 1, searchEnd).join('\n');
let tripBlock = lines.slice(tripStart - 1, tripEnd).join('\n');

// Create methods
let searchingMethod = `
  Widget _buildSearchingOverlay(Size media) {
    return ${searchingBlock.trim().replace(/,$/, '')};
  }
`;

let tripMethod = `
  Widget _buildOnTripPanel(Size media) {
    return ${tripBlock.trim().replace(/,$/, '')};
  }
`;

// Replace in build Stack (top-to-bottom to avoid shifting before extraction)
// Actually, we extracted search first, then trip.
// Replacement: replace everything from searchStart to tripEnd with two calls.
lines.splice(searchStart - 1, tripEnd - searchStart + 1, 
    '                                   _buildSearchingOverlay(media),',
    '                                   _buildOnTripPanel(media),'
);

// Find class ending
let decodeIndex = lines.findIndex(l => l.includes('List decodeEncodedPolyline'));
let closeBraceIndex = decodeIndex - 1;
while(lines[closeBraceIndex].trim() !== '}') {
    closeBraceIndex--;
}

// Insert before the LAST closing brace
lines.splice(closeBraceIndex, 0, searchingMethod, tripMethod);

fs.writeFileSync(path, lines.join('\n'), 'utf8');
console.log('Successfully extracted _buildSearchingOverlay and _buildOnTripPanel');
