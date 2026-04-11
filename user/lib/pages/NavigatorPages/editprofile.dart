import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_user/translations/translation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import '../../functions/auth_service.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../login/login.dart';
import '../noInternet/nointernet.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  ImagePicker picker = ImagePicker();
  bool _isLoading = false;
  String _error = '';
  bool _pickImage = false;
  String _permission = '';
  bool showToast = false;
  TextEditingController name = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController mobilenum = TextEditingController();
  
  String _gender = 'Male';
  File? _imageFile;
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    _error = '';
    isEdit = false;
    _initializeData();
  }

  _initializeData() {
    name.text = userDetails['name'].toString().split(' ')[0];
    lastname.text = (userDetails['name'].toString().split(' ').length > 1)
        ? userDetails['name'].toString().split(' ')[1]
        : '';
    mobilenum.text = userDetails['mobile'] ?? '';
    email.text = userDetails['email']?.toString() ?? '';
    _gender = userDetails['gender'] ?? 'Male';
  }

  getGalleryPermission() async {
    dynamic status;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        status = await Permission.storage.request();
      } else {
        status = PermissionStatus.granted;
      }
    } else {
      status = await Permission.photos.request();
    }
    return status;
  }

  getCameraPermission() async {
    var status = await Permission.camera.request();
    return status;
  }

  pickImageFromGallery() async {
    var permission = await getGalleryPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _pickImage = false;
        });
      }
    } else {
      setState(() => _permission = 'noPhotos');
    }
  }

  pickImageFromCamera() async {
    var permission = await getCameraPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _pickImage = false;
        });
      }
    } else {
      setState(() => _permission = 'noCamera');
    }
  }

  showToastFunc() {
    setState(() => showToast = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => showToast = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      body: Directionality(
        textDirection: languageDirection == 'rtl' ? TextDirection.rtl : TextDirection.ltr,
        child: Stack(
          children: [
            Column(
              children: [
                // Premium Header
                _buildHeader(media),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // Personal Information Card
                        _buildSectionCard(
                          title: t('text_personal_info'),
                          children: [
                            _buildInfoField(
                              icon: Icons.person_outline,
                              label: t('text_fname'),
                              controller: name,
                              isEditable: isEdit,
                              media: media,
                            ),
                            _buildInfoField(
                              icon: Icons.person_outline,
                              label: t('text_lname'),
                              controller: lastname,
                              isEditable: isEdit,
                              media: media,
                            ),
                            _buildGenderSelector(media),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Account Details Card
                        _buildSectionCard(
                          title: t('text_account_info') ?? "Account Details",
                          children: [
                            _buildInfoField(
                              icon: Icons.phone_android_outlined,
                              label: t('text_mob_num'),
                              controller: mobilenum,
                              isEditable: false, // Mobile usually not editable here
                              media: media,
                            ),
                            _buildInfoField(
                              icon: Icons.email_outlined,
                              label: t('text_email'),
                              controller: email,
                              isEditable: isEdit,
                              media: media,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Action Buttons
                        if (_error != '')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: MyText(text: _error, color: Colors.red, size: 12),
                          ),
                        if (isEdit) 
                          Button(
                            onTap: _updateProfile,
                            text: t('text_confirm'),
                          )
                        else
                          _buildLogoutButton(media),
                        
                        const SizedBox(height: 15),
                        _buildDeleteAccountButton(media),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Popups & Loaders
            if (_pickImage) _buildImagePickerPopup(media),
            if (_permission != '') _buildPermissionPopup(media),
            if (_isLoading) const Loading(),
            if (showToast) _buildUpdateToast(media),
            if (internet == false) NoInternet(onTap: () { internetTrue(); setState(() {}); }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Size media) {
    return Container(
      width: media.width,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 40),
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context, true),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
                ),
                MyText(
                  text: isEdit ? t('text_editprofile') : t('text_profile'),
                  color: Colors.white,
                  size: media.width * 0.05,
                  fontweight: FontWeight.bold,
                ),
                InkWell(
                  onTap: () => setState(() => isEdit = !isEdit),
                  child: Icon(isEdit ? Icons.close : Icons.edit, color: Colors.white, size: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildAvatar(media),
          const SizedBox(height: 15),
          MyText(
            text: userDetails['name'] ?? '',
            color: Colors.white,
            size: media.width * 0.055,
            fontweight: FontWeight.bold,
          ),
          MyText(
            text: userDetails['mobile'] ?? '',
            color: Colors.white.withOpacity(0.8),
            size: media.width * 0.035,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Size media) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: CircleAvatar(
            radius: 55,
            backgroundColor: Colors.grey[200],
            backgroundImage: _imageFile != null
                ? FileImage(_imageFile!)
                : NetworkImage(userDetails['profile_picture'] ?? '') as ImageProvider,
          ),
        ),
        if (isEdit)
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: () => setState(() => _pickImage = true),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [boxshadow],
                ),
                child: Icon(Icons.camera_alt, color: buttonColor, size: 20),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            text: title.toUpperCase(),
            size: 13,
            color: greyText,
            fontweight: FontWeight.bold,
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool isEditable,
    required Size media,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: buttonColor, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(text: label, size: 12, color: greyText),
                isEditable
                    ? TextField(
                        controller: controller,
                        style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: UnderlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      )
                    : MyText(
                        text: controller.text,
                        size: 16,
                        color: textColor,
                        fontweight: FontWeight.w600,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector(Size media) {
    if (!isEdit) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.people_outline, color: buttonColor, size: 20),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(text: t('text_gender'), size: 12, color: greyText),
                MyText(text: _gender, size: 16, color: textColor, fontweight: FontWeight.w600),
              ],
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        MyText(text: t('text_gender'), size: 12, color: greyText),
        Row(
          children: [
            _genderButton('Male'),
            _genderButton('Female'),
            _genderButton('Other'),
          ],
        ),
      ],
    );
  }

  Widget _genderButton(String type) {
    bool isSelected = _gender == type;
    return Expanded(
      child: GestureDetector(
        onTap: isEdit ? () => setState(() => _gender = type) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(top: 10, right: 8),
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.indigo : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.indigo : Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.indigo.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ] : [],
          ),
          child: MyText(
            text: type,
            color: isSelected ? Colors.white : Colors.grey.shade600,
            size: 14,
            fontweight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(Size media) {
    return Tapper(
      onTap: _showDeleteConfirmationDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.red.shade100, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_forever_outlined, color: Colors.red.shade400, size: 20),
            const SizedBox(width: 10),
            MyText(
              text: t('text_delete_account') ?? "Delete Account",
              color: Colors.red.shade400,
              size: 15,
              fontweight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_amber_rounded, size: 40, color: Colors.red.shade600),
              ),
              const SizedBox(height: 20),
              
              // Title
              MyText(
                text: t('text_delete_account') ?? "Delete Account",
                size: 20,
                fontweight: FontWeight.bold,
                color: Colors.black87,
              ),
              const SizedBox(height: 12),
              
              // Message
              MyText(
                text: t('text_delete_confirm') ?? "Are you sure? This action is permanent and your account will be deleted in 30 days.",
                size: 14,
                textAlign: TextAlign.center,
                color: Colors.grey.shade600,
              ),
              const SizedBox(height: 30),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: MyText(text: t('text_no') ?? "No", color: Colors.grey.shade700, fontweight: FontWeight.w600, size: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _deleteAccount();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.shade600.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: MyText(text: t('text_yes') ?? "Yes, Delete", color: Colors.white, fontweight: FontWeight.w600, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _deleteAccount() async {
    setState(() => _isLoading = true);
    var res = await AuthService.userDelete();
    setState(() => _isLoading = false);
    
    if (res == 'success') {
      logout = true;
      valueNotifierHome.incrementNotifier();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        setState(() => _error = res.toString());
      }
    }
  }

  Widget _buildLogoutButton(Size media) {
    return Tapper(
      onTap: () {
        logout = true;
        valueNotifierHome.incrementNotifier();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 10),
            MyText(text: t('text_sign_out'), color: Colors.red, size: 16, fontweight: FontWeight.bold),
          ],
        ),
      ),
    );
  }

  _updateProfile() async {
    setState(() => _error = '');
    String pattern = r"^[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])*$";
    var remail = email.text.trim();
    if (RegExp(pattern).hasMatch(remail)) {
      setState(() => _isLoading = true);
      var res = await updateProfile(
        '${name.text} ${lastname.text}',
        remail,
        mobilenum.text,
        _gender,
        _imageFile?.path
      );
      
      setState(() => _isLoading = false);
      if (res == 'success') {
        setState(() => isEdit = false);
        showToastFunc();
      } else {
        setState(() => _error = res.toString());
      }
    } else {
      setState(() => _error = t('text_email_validation'));
    }
  }

  Widget _buildImagePickerPopup(Size media) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      child: InkWell(
        onTap: () => setState(() => _pickImage = false),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _pickerOption(Icons.camera_alt, t('text_camera'), pickImageFromCamera),
                  _pickerOption(Icons.image, t('text_gallery'), pickImageFromGallery),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickerOption(IconData icon, String text, Function onTap) {
    return InkWell(
      onTap: () => onTap(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: Icon(icon, color: buttonColor, size: 30),
          ),
          const SizedBox(height: 10),
          MyText(text: text, size: 14, fontweight: FontWeight.w500),
        ],
      ),
    );
  }

  Widget _buildPermissionPopup(Size media) {
    return Center(
      child: PopUp(
        heading: t('text_permission'),
        close: true,
        closeonTap: () => setState(() => _permission = ''),
        heading2: _permission == 'noPhotos' ? t('text_open_photos_setting') : t('text_open_camera_setting'),
        buttonText: t('text_open_settings'),
        buttononTap: () => openAppSettings(),
      ),
    );
  }

  Widget _buildUpdateToast(Size media) {
    return Positioned(
      bottom: 50,
      width: media.width,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(25)),
          child: const MyText(text: "Profile Updated Successfully", color: Colors.white, size: 14),
        ),
      ),
    );
  }
}
