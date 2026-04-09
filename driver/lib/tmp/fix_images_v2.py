
import os
import re

files_to_fix = [
    (r"c:\Users\FergentiusRosales\Herd\truecabtt\mobileapp\driver\lib\pages\NavigatorPages\adddriver.dart", [
        (r"Image\.network\(countries\[i\]\['flag'\]\)", 
         r"SafeImage(url: countries[i]['flag'], width: 28, height: 20, fit: BoxFit.cover)"),
        (r"Image\.network\(\s*countries\[phcode\]\['flag'\]\)", 
         r"SafeImage(url: countries[phcode]['flag'], width: 28, height: 20, fit: BoxFit.cover)")
    ]),
    (r"c:\Users\FergentiusRosales\Herd\truecabtt\mobileapp\driver\lib\pages\login\namepage.dart", [
        (r"Image\.network\(countries\[i\]\['flag'\]\)", 
         r"SafeImage(url: countries[i]['flag'], width: 28, height: 20, fit: BoxFit.cover)"),
        (r"Image\.network\(\s*countries\[phcode\]\['flag'\]\)", 
         r"SafeImage(url: countries[phcode]['flag'], width: 28, height: 20, fit: BoxFit.cover)")
    ]),
    (r"c:\Users\FergentiusRosales\Herd\truecabtt\mobileapp\driver\lib\pages\login\carinformation.dart", [
        (r"SafeImage\(url: \(vehicletypes\.isNotEmpty\) \? vehicletypes\[i\]\['type_icon'\]\.toString\(\) : '', width: 100, height: 100, fit: BoxFit\.contain\),\s*vehicleType\[k\]\['icon'\]\.toString\(\),\s*fit: BoxFit\.contain,\s*width: media\.width \* 0\.1,",
         r"SafeImage(url: vehicleType[k]['icon'].toString(), width: media.width * 0.1, fit: BoxFit.contain),")
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
        print(f"No changes made to {file_path}")
