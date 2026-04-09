
import os
import re

file_path = r"c:\Users\FergentiusRosales\Herd\truecabtt\mobileapp\driver\lib\pages\login\carinformation.dart"

if os.path.exists(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Target the specific broken block around line 842
    pattern = r"if \(vehicleType\[k\]\['icon'\] != null\)\s+SafeImage\(url: vehicleType\[k\]\['icon'\]\.toString\(\), width: media\.width \* 0\.1, fit: BoxFit\.contain\),\s+height: media\.width \* 0\.08,\s+errorBuilder: \(context, error, stackTrace\) =>\s+Icon\(Icons\.directions_car, size: media\.width \* 0\.08, color: theme\),\s+\),"
    
    replacement = r"if (vehicleType[k]['icon'] != null) SafeImage(url: vehicleType[k]['icon'].toString(), width: media.width * 0.1, fit: BoxFit.contain),"
    
    new_content = re.sub(pattern, replacement, content, flags=re.MULTILINE | re.DOTALL)
    
    if new_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print("Successfully fixed carinformation.dart")
    else:
        print("Could not find the pattern in carinformation.dart")
else:
    print("File not found")
