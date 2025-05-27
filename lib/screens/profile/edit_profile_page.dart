import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/services/class_store.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class EditProfilePage extends StatefulWidget {
  final Renter renter;
  const EditProfilePage({super.key, required this.renter});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController bioController;
  String? imagePath;

  // Add this list at the top of your _EditProfilePageState class:
  final List<String> thailandCities = [
    'Bangkok',
    'Chiang Mai',
    'Phuket',
    'Pattaya',
    'Khon Kaen',
    'Hat Yai',
    'Nakhon Ratchasima',
    'Udon Thani',
    'Surat Thani',
    'Rayong',
  ];

  // Add a variable to hold the selected city:
  String? selectedCity;

  @override
  void initState() {
    super.initState();
    bioController = TextEditingController(text: widget.renter.bio);
    // Use renter.location directly, default to 'Bangkok' if empty or not in list
    String initialCity = (widget.renter.location != null && widget.renter.location.isNotEmpty)
        ? widget.renter.location
        : 'Bangkok';
    selectedCity = thailandCities.contains(initialCity) ? initialCity : 'Bangkok';
    imagePath = widget.renter.profilePicUrl;
  }

  @override
  void dispose() {
    bioController.dispose();
    super.dispose();
  }

  Future<String?> uploadProfileImage(File file) async {
    try {
      final renterId = widget.renter.id; // Make sure your Renter model has an 'id' field
      final ext = path.extension(file.path);
      final filename = '${const Uuid().v4()}$ext';
      final ref = FirebaseStorage.instance.ref().child('profile_pics/$renterId/$filename');
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      // Handle error, e.g. show a snackbar
      return null;
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imagePath = picked.path;
      });
      // Upload to Firebase Storage
      final url = await uploadProfileImage(File(picked.path));
      if (url != null) {
        setState(() {
          imagePath = url;
        });
      }
    }
  }

  void saveProfile() {
    // Save bio, location, and imagePath to your backend or state management
    // Example for Provider:
    final provider = Provider.of<ItemStoreProvider>(context, listen: false);
    provider.updateRenterProfile(
      bio: bioController.text,
      location: selectedCity,
      imagePath: imagePath,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const StyledTitle('Edit Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: width * 0.14,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: imagePath != null && imagePath!.isNotEmpty
                      ? (imagePath!.startsWith('http')
                          ? NetworkImage(imagePath!)
                          : FileImage(
                              // ignore: prefer_const_constructors
                              File(imagePath!),
                            ) as ImageProvider
                        )
                      : null,
                  child: imagePath == null || imagePath!.isEmpty
                      ? Icon(Icons.person, size: width * 0.14, color: Colors.white)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Location label above the dropdown
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 4, bottom: 6),
                child: StyledBody('Location', color: Colors.black, weight: FontWeight.bold),
              ),
            ),
            DropdownButtonFormField<String>(
              value: selectedCity,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // <-- Black border
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // <-- Black border
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2), // <-- Black border
                ),
              ),
              dropdownColor: Colors.white,
              items: thailandCities
                  .map((city) => DropdownMenuItem(
                        value: city,
                        child: Text(
                          city,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal, // Make location text normal weight
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCity = value;
                });
              },
            ),
            const SizedBox(height: 24),
            // Bio label above the text box
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 4, bottom: 6),
                child: StyledBody('Describe yourself', color: Colors.black, weight: FontWeight.bold),
              ),
            ),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // <-- Black border
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // <-- Black border
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2), // <-- Black border
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const StyledHeading('Save', weight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}