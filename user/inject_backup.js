const fs = require('fs');
const file = 'lib/pages/onTripPage/booking_confirmation.dart';
const backupFile = 'lib/pages/onTripPage/standard_ride_options_backup.txt';

let lines = fs.readFileSync(file, 'utf-8').split(/\r?\n/);
const backupLines = fs.readFileSync(backupFile, 'utf-8').split(/\r?\n/);

// Replace ride selection monolithic block with method call
// Lines 2172 to 4645 are the block. (2170 in 0-indexed is line 2171 //show bottom nav bar...)
lines.splice(2170, 4646 - 2170 + 1, '                                  _buildRideSelectionSheet(media),');

// Inject backup logic
let insertIdx = lines.findIndex(l => l.includes('List decodeEncodedPolyline'));
if (insertIdx !== -1) {
    // Find the enclosing brace of the class
    while(!lines[insertIdx-1].includes('}')) {
        insertIdx--;
    }
    insertIdx--; // before the brace
    
    // Add some empty space
    backupLines.unshift('');
    backupLines.unshift('');
    
    lines.splice(insertIdx, 0, ...backupLines);
} else {
    console.error("Could not find decodeEncodedPolyline");
    process.exit(1);
}

fs.writeFileSync(file, lines.join('\n'), 'utf-8');
console.log('Targeted recovery complete!');
