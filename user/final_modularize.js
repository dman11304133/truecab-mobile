const fs = require('fs');

const file = 'lib/pages/onTripPage/booking_confirmation.dart';
const backupFile = 'lib/pages/onTripPage/standard_ride_options_backup.txt';

let content = fs.readFileSync(file, 'utf-8');
let lines = content.split(/\r?\n/);

const backupContent = fs.readFileSync(backupFile, 'utf-8');
const backupLines = backupContent.split(/\r?\n/);

// Updated Mapping (0-indexed)
const extractions = [
  { name: '_buildMap', start: 1555, end: 1757 },
  { name: '_buildTopBar', start: 1758, end: 1887 },
  { name: '_buildFloatingActionButtons', start: 1888, end: 2119 },
  { name: '_buildSheetHeightToggle', start: 2124, end: 2168 },
  { name: '_buildRideSelectionSheet', start: 2170, end: 4649 }, // This will be replaced by backup
  { name: '_buildNoDriverFoundOverlay', start: 4650, end: 4725 },
  { name: '_buildTripReqErrorOverlay', start: 4726, end: 4807 },
  { name: '_buildServiceNotAvailableOverlay', start: 4808, end: 4907 },
  { name: '_buildLowWalletOverlay', start: 4908, end: 4967 },
  { name: '_buildPaymentMethodOverlay', start: 4968, end: 5513 },
  { name: '_buildDriverSearchPanel', start: 5514, end: 6110 },
  // 6112-6113 is just a line break or empty space in the stack children. Ignoring.
  { name: '_buildDriverSearchCancelReason', start: 6114, end: 6240 },
  // 6242-6248, 6249-6251, 6252-7625. OnTripPanel seems to start around 6252.
  { name: '_buildOnTripPanel', start: 6252, end: 7625 },
  { name: '_buildCancelReasonOverlay', start: 7626, end: 7712 },
  // 7713 is empty
  { name: '_buildDateTimePickerOverlay', start: 7714, end: 7994 },
  { name: '_buildSosOverlay', start: 7995, end: 8357 },
  { name: '_buildAddressConfirmationOverlay', start: 8358, end: 8869 },
  { name: '_buildEditUserDetailsOverlay', start: 8871, end: 9311 },
  { name: '_buildCancelConfirmationOverlay', start: 9312, end: 9388 },
  // 9388-9394 is some empty space or small child
  { name: '_buildDriverCancelledOverlay', start: 9395, end: 9406 },
  { name: '_buildNoInternetOverlay', start: 9407, end: 9492 },
  // 9494-9496 empty
  { name: '_buildMarkerGenerationSection', start: 9497, end: 9571 }
];

const generatedMethods = [];

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

// 1. Extract and build methods
for (const ext of extractions) {
    if (ext.name === '_buildRideSelectionSheet') {
        // Build from backup instead
        const reindentedBackup = reindent(backupLines);
        generatedMethods.push('');
        generatedMethods.push('  // ─── ' + ext.name + ' ──────────────────────────────────────');
        generatedMethods.push('');
        generatedMethods.push('  Widget ' + ext.name + '(Size media) {');
        generatedMethods.push('    return ' + reindentedBackup[0].trim());
        for (let i = 1; i < reindentedBackup.length - 1; i++) {
            generatedMethods.push(reindentedBackup[i]);
        }
        let lastLine = reindentedBackup[reindentedBackup.length - 1];
        if (!lastLine.trim().endsWith(';')) lastLine += ';';
        generatedMethods.push(lastLine);
        generatedMethods.push('  }');
    } else {
        const slice = lines.slice(ext.start, ext.end + 1);
        const reindented = reindent(slice);
        generatedMethods.push('');
        generatedMethods.push('  // ─── ' + ext.name + ' ──────────────────────────────────────');
        generatedMethods.push('');
        generatedMethods.push('  Widget ' + ext.name + '(Size media) {');
        generatedMethods.push('    return ' + reindented[0].trim());
        for (let i = 1; i < reindented.length - 1; i++) {
            generatedMethods.push(reindented[i]);
        }
        let lastLine = reindented[reindented.length - 1];
        if (!lastLine.trim().endsWith(';')) lastLine += ';';
        generatedMethods.push(lastLine);
        generatedMethods.push('  }');
    }
}

// 2. Replace in-place (backwards)
const sortedRemovals = [...extractions].sort((a, b) => b.start - a.start);
for (const rm of sortedRemovals) {
    const methodCall = `                                  ${rm.name}(media),`;
    lines.splice(rm.start, rm.end - rm.start + 1, methodCall);
}

// 3. Inject at end of class
let insertIdx = lines.findIndex(l => l.includes('List decodeEncodedPolyline'));
if (insertIdx !== -1) {
    while(!lines[insertIdx-1].includes('}')) {
        insertIdx--;
    }
    insertIdx--;
    lines.splice(insertIdx, 0, ...generatedMethods);
} else {
    console.error("Marker injection point not found");
    process.exit(1);
}

fs.writeFileSync(file, lines.join('\n'), 'utf-8');
console.log('Modularization recovery complete!');
