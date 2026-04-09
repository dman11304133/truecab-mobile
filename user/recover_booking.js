const fs = require('fs');

const file = 'lib/pages/onTripPage/booking_confirmation.dart';
const backupFile = 'lib/pages/onTripPage/standard_ride_options_backup.txt';

let lines = fs.readFileSync(file, 'utf-8').split(/\r?\n/);
const backupLines = fs.readFileSync(backupFile, 'utf-8').split(/\r?\n/);

// These are our 0-indexed line ranges inside Stack children
// NOTE: Lines parsed by Node.js above were 0-indexed, because split() maps directly to indices.
const extractions = [
  { name: '_buildMap', start: 1555, end: 1757 },
  { name: '_buildTopBar', start: 1758, end: 1887 },
  { name: '_buildFloatingActionButtons', start: 1888, end: 2119 },
  { name: '_buildSheetHeightToggle', start: 2124, end: 2168 },
  // Ride Selection Sheet (2170 - 4649) is replaced by our backup, we will delete it and replace with call
  { name: '_buildNoDriverFoundOverlay', start: 4650, end: 4725 },
  { name: '_buildTripReqErrorOverlay', start: 4726, end: 4807 },
  { name: '_buildServiceNotAvailableOverlay', start: 4808, end: 4907 },
  { name: '_buildLowWalletOverlay', start: 4908, end: 4967 },
  { name: '_buildPaymentMethodOverlay', start: 4968, end: 5513 },
  { name: '_buildDriverSearchPanel', start: 5514, end: 6110 },
  // 6114-6240 is some overlay
  { name: '_buildDriverSearchCancelReason', start: 6114, end: 6240 },
  { name: '_buildOnTripPanel', start: 6252, end: 7625 },
  { name: '_buildCancelReasonOverlay', start: 7626, end: 7712 },
  { name: '_buildDateTimePickerOverlay', start: 7714, end: 7994 },
  { name: '_buildSosOverlay', start: 7995, end: 8357 },
  { name: '_buildAddressConfirmationOverlay', start: 8358, end: 8869 },
  { name: '_buildEditUserDetailsOverlay', start: 8875, end: 9311 },
  { name: '_buildCancelConfirmationOverlay', start: 9312, end: 9388 },
  { name: '_buildDriverCancelledOverlay', start: 9395, end: 9406 }, // might be loader or driver cancelled
  { name: '_buildNoInternetOverlay', start: 9407, end: 9492 },
  { name: '_buildMarkerGenerationSection', start: 9497, end: 9571 }
];

const rideSelectionStart = 2170;
const rideSelectionEnd = 4649;

// We will collect the extracted methods text
const generatedMethods = [];

// Helper to strip minimum common indentation
function reindent(block) {
  let minIndent = Infinity;
  for (const line of block) {
    if (line.trim() === '') continue;
    const match = line.match(/^(\s*)/);
    if (match) {
      const indent = match[1].length;
      if (indent < minIndent) minIndent = indent;
    }
  }
  if (minIndent === Infinity) minIndent = 0;

  return block.map(line => {
    if (line.trim() === '') return '';
    const currentIndent = line.match(/^(\s*)/)[1].length;
    const relativeIndent = currentIndent - minIndent;
    return '    ' + ' '.repeat(relativeIndent) + line.trim();
  });
}

// 1. Extract the slices and convert to methods
for (const ext of extractions) {
  const slice = lines.slice(ext.start, ext.end + 1);
  const reindented = reindent(slice);
  
  generatedMethods.push('');
  generatedMethods.push('  // ─── ' + ext.name + ' ──────────────────────────────────────');
  generatedMethods.push('');
  generatedMethods.push('  Widget ' + ext.name + '(Size media) {');
  // First line gets appended directly to return, others follow
  generatedMethods.push('    return ' + reindented[0].trim());
  for (let i = 1; i < reindented.length; i++) {
    generatedMethods.push(reindented[i]);
  }
  generatedMethods.push('  }');
}

// 2. Clear out the extracted blocks and ride selection block by replacing with method calls
// We work backwards to not mess up indices
const allRemovals = [...extractions, { name: '_buildRideSelectionSheet', start: rideSelectionStart, end: rideSelectionEnd }];
allRemovals.sort((a, b) => b.start - a.start);

for (const rm of allRemovals) {
  const methodCall = `                                  ${rm.name}(media),`;
  // Replace the entire block with the method call
  lines.splice(rm.start, rm.end - rm.start + 1, methodCall);
}

// 3. Append backup text and generated methods before `decodeEncodedPolyline`
let insertIdx = lines.findIndex(l => l.includes('List decodeEncodedPolyline'));
if (insertIdx !== -1) {
    // Find the enclosing brace of the class
    while(!lines[insertIdx-1].includes('}')) {
        insertIdx--;
    }
    insertIdx--; // before the brace
    
    // Insert backup text
    lines.splice(insertIdx, 0, ...backupLines);
    insertIdx += backupLines.length;
    
    // Insert generated methods
    lines.splice(insertIdx, 0, ...generatedMethods);
} else {
    console.error("Could not find decodeEncodedline");
    process.exit(1);
}

fs.writeFileSync(file, lines.join('\n'), 'utf-8');
console.log('Recovery complete!');
