const fs = require('fs');
const file = 'lib/pages/onTripPage/booking_confirmation.dart';
const backupFile = 'lib/pages/onTripPage/standard_ride_options_backup.txt';

let lines = fs.readFileSync(file, 'utf-8').split(/\r?\n/);
const backupLines = fs.readFileSync(backupFile, 'utf-8').split(/\r?\n/);

// Find the boundaries of the ride selection sheet in the current file
let startIdx = lines.findIndex(l => l.includes('//show bottom nav bar for choosing ride type'));
let endIdx = startIdx;
let bracketCount = 0;
let foundStart = false;

// Traverse downwards to find the end of this specific AnimatedPositioned
for(let i = startIdx; i < lines.length; i++) {
  const line = lines[i];
  if (line.includes('AnimatedPositioned(')) {
     foundStart = true;
  }
  
  if (foundStart) {
    bracketCount += (line.match(/\(/g) || []).length;
    bracketCount -= (line.match(/\)/g) || []).length;
    
    if (bracketCount === 0) {
      // Find the : Container(), right after
      if (lines[i+1].includes(': Container(),')) {
          endIdx = i + 1;
      } else {
          endIdx = i;
      }
      break;
    }
  }
}

// Ensure we found it
if (startIdx !== -1 && startIdx !== endIdx) {
  // Replace the monolithic block with a method call
  // We offset startIdx by -1 to include the condition `(isLoading == false ...)`
  while(!lines[startIdx-1].includes('))')) {
      if (lines[startIdx-1].includes('(isLoading == false')) {
          startIdx = startIdx - 1;
          break;
      }
      startIdx--;
  }

  lines.splice(startIdx, endIdx - startIdx + 1, '                                  _buildRideSelectionSheet(media),');

  // Wrap the backup in a function
  const wrappedBackup = [
    '',
    '  // ─── _buildRideSelectionSheet ──────────────────────────────────────',
    '',
    '  Widget _buildRideSelectionSheet(Size media) {',
    '    return ' + backupLines[0]
  ];
  
  for(let i=1; i<backupLines.length - 1; i++) {
      wrappedBackup.push(backupLines[i]);
  }
  
  let lastBackupLine = backupLines[backupLines.length - 1];
  if (!lastBackupLine.trim().endsWith(';')) lastBackupLine += ';';
  wrappedBackup.push(lastBackupLine);
  wrappedBackup.push('  }');

  // Inject at the bottom
  let insertIdx = lines.findIndex(l => l.includes('List decodeEncodedPolyline'));
  while(!lines[insertIdx-1].includes('}')) {
      insertIdx--;
  }
  insertIdx--;
  lines.splice(insertIdx, 0, ...wrappedBackup);
  
  fs.writeFileSync(file, lines.join('\n'), 'utf-8');
  console.log("Successfully restored and injected Ride Selection Sheet!");
} else {
  console.error("Could not find Ride Selection bounds.");
}
