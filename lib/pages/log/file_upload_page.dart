import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:heartless/backend/controllers/health_document_controller.dart';
import 'package:heartless/pages/log/file_upload_preview_page.dart';
import 'package:heartless/services/date/date_service.dart';
import 'package:heartless/services/enums/custom_file_type.dart';
import 'package:heartless/shared/constants.dart';
import 'package:heartless/shared/models/health_document.dart';
import 'package:heartless/widgets/log/file_tile.dart';

class FileUploadPage extends StatefulWidget {
  final String patientId;
  const FileUploadPage({super.key, required this.patientId});

  @override
  State<FileUploadPage> createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 200,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      for (var fileFormat in CustomFileType.values)
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  //! file upload mechanism here
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions:
                                        fileExtensionsFromCustomFileType(
                                            fileFormat),
                                  );

                                  if (result != null &&
                                      result.files.isNotEmpty &&
                                      result.files.single.path != null) {
                                    // ! upload file
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FileUploadPreviewPage(
                                                  file: result.files[0],
                                                  fileType: fileFormat,
                                                  patientId: widget.patientId,
                                                )));
                                  }
                                },
                                child: CircleAvatar(
                                  backgroundImage:
                                      AssetImage(fileFormat.imageUrl),
                                  radius: 20,
                                ),
                              ),
                              Text(fileFormat.value),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        backgroundColor: Constants.primaryColor,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: SearchBar(
          controller: _searchController,
          hintText: 'Search by tag or title',
          hintStyle: MaterialStateProperty.all(
            TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          leading: Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.fromLTRB(0, 5, 12, 0),
            child: Image.asset('assets/Icons/magnifyingGlass.png', scale: 2),
          ),
          onChanged: (text) {
            setState(() {});
            {
              // ! search functionality
              print(text);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 300,
                child: StreamBuilder(
                    stream: HealthDocumentController.getHealthDocuments(
                        widget.patientId),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data != null &&
                          snapshot.data.docs.isNotEmpty) {
                        return ListView.builder(
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              HealthDocument healthDocument =
                                  HealthDocument.fromMap(
                                      snapshot.data.docs[index].data());
                              return FileTile(
                                title: healthDocument.name,
                                fileType: healthDocument.customFileType,
                                dateString: DateService.dayDateTimeFormat(
                                    healthDocument.createdAt),
                              );
                            });
                      } else {
                        return const Center(
                          child: Text('No Documents yet!'),
                        );
                      }
                    }),
              ),
              // MonthDivider(
              //   month: 'February',
              //   year: '2024',
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
