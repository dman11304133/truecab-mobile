
import os
import re

def fix_nav_drawer():
    path = r"c:\Users\FergentiusRosales\Herd\truecabtt\mobileapp\driver\lib\pages\navDrawer\nav_drawer.dart"
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Missing closing paren for BoxDecoration
    old = r"decoration: BoxDecoration\(\s+borderRadius: BorderRadius\.circular\(8\),\s+image: safeImage\(userDetails\['profile_picture'\]\),\s+\),"
    new = r"decoration: BoxDecoration(\n                                    borderRadius: BorderRadius.circular(8),\n                                    image: safeImage(userDetails['profile_picture'])),\n                              ),"
    
    # Try more flexible regex if literal fails
    pattern = r"decoration: BoxDecoration\(\s+borderRadius: BorderRadius\.circular\(8\),\s+image: safeImage\(userDetails\['profile_picture'\]\),\s+\),"
    content = re.sub(pattern, new, content)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

def fix_notification():
    path = r"c:\Users\FergentiusRosales\Herd\truecabtt\mobileapp\driver\lib\pages\NavigatorPages\notification.dart"
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace chunk 0 that failed
    pattern = r"Image\(\s+image: safeImage\(\s+notificationHistory\[\s+i\]\s+\[\s+'image'\],\s+\),\s+height:\s+media\.width \*\s+0\.1,\s+width: media\s+\.width \*\s+0\.8,\s+fit: BoxFit\.contain,\s+\)"
    replacement = r"SafeImage(\n                                                                      url: notificationHistory[\n                                                                              i]\n                                                                          [\n                                                                          'image'],\n                                                                      height:\n                                                                          media.width *\n                                                                              0.1,\n                                                                      width: media\n                                                                              .width *\n                                                                          0.8,\n                                                                      fit: BoxFit.contain,\n                                                                    )"
    
    content = re.sub(pattern, replacement, content, flags=re.MULTILINE | re.DOTALL)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

fix_nav_drawer()
fix_notification()
print("Applied fixes")
