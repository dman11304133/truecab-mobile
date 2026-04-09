const fs = require('fs');

function fixFile(filePath, patches) {
    let lines = fs.readFileSync(filePath, 'utf8').split('\n');
    let changed = false;

    patches.forEach(patch => {
        if (patch.type === 'replace_line') {
            const lineIndex = patch.line - 1;
            if (lineIndex >= 0 && lineIndex < lines.length && lines[lineIndex].includes(patch.old)) {
                lines[lineIndex] = lines[lineIndex].replace(patch.old, patch.new);
                changed = true;
                console.log(`Fixed line ${patch.line} in ${filePath}`);
            }
        } else if (patch.type === 'replace_all') {
            const oldContent = lines.join('\n');
            const newContent = oldContent.split(patch.old).join(patch.new);
            if (oldContent !== newContent) {
                lines = newContent.split('\n');
                changed = true;
                console.log(`Global replace in ${filePath}`);
            }
        }
    });

    if (changed) {
        fs.writeFileSync(filePath, lines.join('\n'));
    }
}

// 1. Fix bookingwidgets.dart
fixFile('lib/pages/onTripPage/bookingwidgets.dart', [
    { type: 'replace_all', old: "import 'glass_box.dart';", new: "import '../../widgets/glass_box.dart';" },
    // ApplyCouponsContainer: closing GlassBox
    { type: 'replace_line', line: 213, old: ');', new: '),' },
    { type: 'replace_line', line: 214, old: '}', new: '    );\n  }' },
    // CreateRequestBottomSheet: closing GlassBox
    // We'll find it around 2444 as per previously reported Error
    { type: 'replace_line', line: 2444, old: ');', new: '),\n      ),\n    );' }
]);

// 2. Fix booking_confirmation.dart
let content = fs.readFileSync('lib/pages/onTripPage/booking_confirmation.dart', 'utf8');

// Fix Imports
content = content.replace(/import '\.\.\/NavigatorPages\/glass_box.dart';/g, "import '../../widgets/glass_box.dart';");

// Fix Main Panel closing (Line 4831 from )) to )))
let bcLines = content.split('\n');
if (bcLines[4830].includes('))') && bcLines[4831].includes(': Container()')) {
    bcLines[4830] = bcLines[4830].replace('))', ')))');
}

// Fix Searching Panel closing (Line 5576 from )) to )))
if (bcLines[5575].includes('))') && bcLines[5576].includes(': Container()')) {
    bcLines[5575] = bcLines[5575].replace('))', ')))');
}

// Fix Accepted Panel closing (Line 6617 from ))) to ))))
if (bcLines[6611].includes(')))') && bcLines[6612].includes(': Container()')) {
    bcLines[6611] = bcLines[6611].replace(')))', '))))');
}

content = bcLines.join('\n');

// Fix SOS List and Cancel Dialog wraps which are unclosed
// These use localized pattern matching since they are in complex Columns
content = content.replace(/(InkWell\([\s\S]*?child: Container\([\s\S]*?child: Row\([\s\S]*?children: \[[\s\S]*?\]\s*\)\s*\)\s*\)\s*)\)\s*,\s*SizedBox\(/, 
    (m, p1) => p1 + "),\n                                            ),\n                                            SizedBox(");

content = content.replace(/(Button\([\s\S]*?onTap: \(\) async \{[\s\S]*?\}\s*,\s*textcolor: textColor\s*\)\s*)\)\s*,\s*\(userRequestData/,
    (m, p1) => p1 + "),\n                                          ),\n                                          (userRequestData");

fs.writeFileSync('lib/pages/onTripPage/booking_confirmation.dart', content);
console.log('Fixed booking_confirmation.dart structural errors.');
