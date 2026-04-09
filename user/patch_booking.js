const fs = require('fs');
const path = 'C:\\Users\\FergentiusRosales\\Herd\\truecabtt\\mobileapp\\user\\lib\\pages\\onTripPage\\booking_confirmation.dart';
let lines = fs.readFileSync(path, 'utf8').split(/\r?\n/);
// Line numbers from previous view_file (1-indexed)
let start = 4085;
let end = 4402;
let replacement = [
  '                                   _buildNoDriverFoundOverlay(media),',
  '                                   _buildTripReqErrorOverlay(media),',
  '                                   _buildServiceNotAvailableOverlay(media),',
  '                                   _buildLowWalletOverlay(media),'
];
lines.splice(start - 1, end - start + 1, ...replacement);
fs.writeFileSync(path, lines.join('\n'), 'utf8');
console.log('Successfully patched lines 4085-4402');
