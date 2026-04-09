
import os
import re

files_to_fix = [
    (r"c:\Users\FergentiusRosales\Herd\truecabtt\mobileapp\driver\lib\pages\vehicleInformations\upload_docs.dart", [
        (r"DecorationImage\(\s*image:\s*NetworkImage\(documentsNeeded\[i\]\['driver_document'\]\['data'\]\s*\[\s*'document'\]\),\s*fit:\s*BoxFit\s*\.cover\)", 
         r"safeImage(documentsNeeded[i]['driver_document']['data']['document'])")
    ]),
    (r"c:\Users\FergentiusRosales\Herd\truecabtt\mobileapp\driver\lib\pages\NavigatorPages\managevehicles.dart", [
        (r"DecorationImage\(\s*image:\s*NetworkImage\(\s*vehicledata\[i\]\['type_icon'\]\.toString\(\),\s*\),\s*fit:\s*BoxFit\.contain\)", 
         r"safeImage(vehicledata[i]['type_icon'].toString())")
    ]),
    (r"c:\Users\FergentiusRosales\Herd\truecabtt\mobileapp\driver\lib\pages\NavigatorPages\fleetdocuments.dart", [
        (r"DecorationImage\(\s*image:\s*NetworkImage\(\s*fleetdocumentsNeeded\[i\]\['fleet_document'\]\['data'\]\s*\[\s*'document'\]\s*\.toString\(\),\s*\),\s*fit:\s*BoxFit\s*\.cover\)", 
         r"safeImage(fleetdocumentsNeeded[i]['fleet_document']['data']['document'].toString())")
    ]),
    (r"c:\Users\FergentiusRosales\Herd\truecabtt\mobileapp\driver\lib\pages\NavigatorPages\assigndriver.dart", [
        (r"DecorationImage\(\s*image:\s*NetworkImage\(\s*fleetdriverList\[i\]\['profile_picture'\]\.toString\(\),\s*\),\s*fit:\s*BoxFit\.fill\)", 
         r"safeImage(fleetdriverList[i]['profile_picture'].toString())")
    ])
]

for file_path, replacements in files_to_fix:
    if not os.path.exists(file_path):
        print(f"File not found: {file_path}")
        continue
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    orig_content = content
    for pattern, replacement in replacements:
        content = re.sub(pattern, replacement, content, flags=re.MULTILINE | re.DOTALL)
    
    if content != orig_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Successfully updated {file_path}")
    else:
        print(f"No changes made to {file_path} - check patterns")
