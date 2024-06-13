import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kidz_emporium/contants.dart';
import 'package:photo_view/photo_view.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final Function(String)? onTap;

  const ChatBubble({
    Key? key,
    required this.text,
    required this.isUser,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: isUser ? Alignment.topRight : Alignment.topLeft,
        child: GestureDetector(
          onTap: () {
            if (onTap != null) {
              onTap!(text);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isUser ? kPrimaryColor : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: isUser ? Radius.circular(16) : Radius.circular(0),
                bottomRight: isUser ? Radius.circular(0) : Radius.circular(16),
              ),
            ),
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              text,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FAQPage extends StatefulWidget {
  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  List<FAQMessage> faqMessages = [];
  TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  // Define the FAQ responses
  List<FAQResponse> _faqResponses = [
    FAQResponse(
      text: 'Our services listed below: \n\n• Occupational Therapy (OT)\n\n• Speech Therapy (ST)\n\n• Special Education (SPED)\n\n• Clinical Psychology (PSY)\n\n• Big Ones Playgroup\n\n• Little Ones Playgroup\n\n*All services come with package or one to one session.',
      image: null,
    ),
    FAQResponse(
      text: 'Yes, the customer need to pay RM50 in advance prior every booking appointment.',
      image: null,
    ),
    FAQResponse(
      text: 'Pricing list for every service listed below',
      image: 'assets/images/pricing_list.png',
    ),
    FAQResponse(
      text: 'You can contact us through these platforms: \n\n'
          'Phone: 03 - 89122455 or 017 - 5277473 \n\n'
          'Email: emporiumtherapy@gmail.com \n\n'
          'Facebook: kidzemporiumtherapy\n\n'
          'Instagram: kidzemporiumtherapy\n\n'
          'Tiktok: kidzemporiumtherapy',
      image: null,
    ),
    FAQResponse(
      text: 'Our working hours are Monday to Friday, from 9 AM to 5 PM.',
      image: null,
    ),
    FAQResponse(
      text: 'Yes, we offer online consultations via Google Meets. Please schedule an appointment first.',
      image: null,
    ),
    FAQResponse(
      text: 'You can visit our website at https://kidzemporiumtherapy.my.canva.site/kidz-emporium-therapy for more information and online booking.',
      image: null,
    ),
  ];

  // Define keywords related to different categories
  Map<String, List<String>> categoryKeywords = {
    'services': ["service", "services", "Service", "Services"],
    'payment': ["payment", "pay", "Payment", "Pay"],
    'pricing': ["price", "pricing", "Price", "Pricing"],
    // Add more categories and their corresponding keywords here
  };
  @override
  void initState() {
    super.initState();
    print('Scroll controller attached: ${_scrollController.hasClients}');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatBot'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 10,),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: faqMessages.length,
              itemBuilder: (context, index) {
                final message = faqMessages[index];
                return message.image != null
                    ? Padding(
                  padding: EdgeInsets.only(left: 16, top: 16, right: 16), // Adjust padding as needed
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: MediaQuery.of(context).size.height * 0.9,
                              child: PhotoView(
                                imageProvider: AssetImage(message.image!),
                                minScale: PhotoViewComputedScale.contained * 0.8,
                                maxScale: PhotoViewComputedScale.covered * 2,
                                enableRotation: true,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Image.asset(
                      message.image!,
                      width: 150, // Set image width as needed
                      height: 150, // Set image height as needed
                    ),
                  ),
                )
                    : ChatBubble(
                  text: message.text!,
                  isUser: message.isQuestion,
                  onTap: _handleLinkTap,
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6.0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _handleButtonPressed('Our Services');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: kPrimaryColor,
                          onPrimary: kPrimaryColor,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Our Services',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 10), // Add SizedBox for spacing between buttons
                      ElevatedButton(
                        onPressed: () {
                          _handleButtonPressed('Booking Payment');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: kPrimaryColor,
                          onPrimary: kPrimaryColor,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Booking Payment',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 10), // Add SizedBox for spacing between buttons
                      ElevatedButton(
                        onPressed: () {
                          _handleButtonPressed('Pricing List');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: kPrimaryColor,
                          onPrimary: kPrimaryColor,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Pricing List',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 10), // Add SizedBox for spacing between buttons
                      ElevatedButton(
                        onPressed: () {
                          _handleButtonPressed('Contact Us');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: kPrimaryColor,
                          onPrimary: kPrimaryColor,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Contact Us',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 10), // Add SizedBox for spacing between buttons
                      ElevatedButton(
                        onPressed: () {
                          _handleButtonPressed('Working Hours');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: kPrimaryColor,
                          onPrimary: kPrimaryColor,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Working Hours',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 10), // Add SizedBox for spacing between buttons
                      ElevatedButton(
                        onPressed: () {
                          _handleButtonPressed('Online Consultation');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: kPrimaryColor,
                          onPrimary: kPrimaryColor,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Online Consultation',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 10), // Add SizedBox for spacing between buttons
                      ElevatedButton(
                        onPressed: () {
                          _handleButtonPressed('Website');
                          _launchURL('https://kidzemporiumtherapy.my.canva.site/kidz-emporium-therapy');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: kPrimaryColor,
                          onPrimary: kPrimaryColor,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Website',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20), // Add SizedBox for spacing between buttons and search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for keywords...',
                    suffixIcon: IconButton(
                      onPressed: () {
                        // Implement the search functionality here
                        _sendMessage(_searchController.text);
                      },
                      icon: Icon(Icons.send),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    // Clear the search input controller
    _searchController.clear();

    // Display user's search input
    setState(() {
      faqMessages.add(FAQMessage(text: message, isQuestion: true));
    });


    // Check if the message contains any of the keywords for each category
    for (String category in categoryKeywords.keys) {
      if (categoryKeywords[category]!.any((keyword) => message.toLowerCase().contains(keyword))) {
        // Display information related to the selected category
        _displayCategoryInfo(category);
        return; // Exit the method after displaying the category info
      }
    }

    // If the message does not match any category, proceed with regular search functionality
    _searchRegular(message);
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  void _displayCategoryInfo(String category) {
    // Display information based on the selected category
    setState(() {
      switch (category) {
        case 'services':
          faqMessages.add(FAQMessage(text: 'Our services listed below:', isQuestion: false));
          for (FAQResponse response in _faqResponses) {
            if (_containsCategoryKeyword(response.text!, category)) {
              faqMessages.add(FAQMessage(text: response.text!, isQuestion: false));
              if (response.image != null) {
                faqMessages.add(FAQMessage(image: response.image!, isQuestion: false));
              }
            }
          }
          break;
        case 'payment':
          FAQResponse paymentInfo = _getFAQResponse('Booking Payment');
          faqMessages.add(FAQMessage(text: paymentInfo.text!, isQuestion: false));
          break;
        case 'pricing':
          FAQResponse pricingInfo = _getFAQResponse('Pricing List');
          faqMessages.add(FAQMessage(text: pricingInfo.text!, isQuestion: false));
          if (pricingInfo.image != null) {
            faqMessages.add(FAQMessage(image: pricingInfo.image!, isQuestion: false));
          }
          break;
      // Add more cases to handle other categories
      }
    });
  }

  bool _containsCategoryKeyword(String text, String category) {
    List<String> keywords = categoryKeywords[category]!;
    return keywords.any((keyword) => text.toLowerCase().contains(keyword));
  }

  void _searchRegular(String message) {
    // Analyze the message to find a response
    if (message.isNotEmpty) {
      // If the message is not empty, search for matching responses
      bool foundResponse = false; // Flag to track if a response is found
      for (FAQResponse response in _faqResponses) {
        if (response.text!.toLowerCase().contains(message.toLowerCase())) {
          // Found a match, add the response to the FAQ messages
          setState(() {
            faqMessages.add(FAQMessage(text: response.text!, isQuestion: false));
            if (response.image != null) {
              faqMessages.add(FAQMessage(image: response.image!, isQuestion: false));
            }
          });
          foundResponse = true;
          break; // Exit the loop after finding the first match
        }
      }
      if (!foundResponse) {
        // If no response is found, display "I do not have information for that"
        setState(() {
          faqMessages.add(FAQMessage(text: 'Sorry, I do not have information for that.', isQuestion: false));
        });
      }
    } else {
      // If the message is empty, display a default message
      setState(() {
        faqMessages.add(FAQMessage(text: 'Please enter a keyword to search.', isQuestion: false));
      });
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  void _handleButtonPressed(String keyword) {
    // Simulate fetching FAQ response based on keyword
    FAQResponse response = _getFAQResponse(keyword);
    setState(() {
      faqMessages.add(FAQMessage(text: '$keyword', isQuestion: true));
      if (response.text != null) {
        faqMessages.add(FAQMessage(text: response.text!, isQuestion: false));
      }
      if (response.image != null) {
        faqMessages.add(FAQMessage(image: response.image!, isQuestion: false));
      }
    });
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  FAQResponse _getFAQResponse(String keyword) {
    // Simulated FAQ responses
    if (keyword == 'Our Services') {
      return FAQResponse(
        text: 'Our services listed below: \n\n• Occupational Therapy (OT)\n\n• Speech Therapy (ST)\n\n• Special Education (SPED)\n\n• Clinical Psychology (PSY)\n\n• Big Ones Playgroup\n\n• Little Ones Playgroup\n\n *All services come with package or one to one session.',
        image: null,
      );
    } else if (keyword == 'Booking Payment') {
      return FAQResponse(
        text: 'Yes, the customer need to pay RM50 in advance prior every booking appointment.',
        image: null,
      );
    } else if (keyword == 'Pricing List') {
      return FAQResponse(
        text: 'Pricing list for every service listed below',
        image: 'assets/images/pricing_list.png',
      );
    } else if (keyword == 'Contact Us') {
      return FAQResponse(
        text: 'You can contact us through these platforms: \n\n'
            'Phone: 03 - 89122455 or 017 - 5277473 \n\n'
            'Email: emporiumtherapy@gmail.com \n\n'
            'Facebook: www.facebook.com/kidzemporiumtherapycenter\n\n'
            'Instagram: www.instagram.com/kidzemporiumtherapy\n\n'
            'Tiktok: www.tiktok.com/@kidzemporiumtherapy',
        image: null,
      );
    } else if (keyword == 'Working Hours') {
      return FAQResponse(
        text: 'Our working hours are Tuesday to Saturday, from 9 AM to 5 PM.',
        image: null,
      );
    } else if (keyword == 'Online Consultation') {
      return FAQResponse(
        text: 'Yes, we offer online consultations via Google Meets. Please schedule an appointment first.',
        image: null,
      );
    } else if (keyword == 'Website') {
      return FAQResponse(
        text: 'You can visit our website at https://kidzemporiumtherapy.my.canva.site/kidz-emporium-therapy for more information.',
        image: null,
      );
    } else {
      return FAQResponse(
        text: 'Sorry, I don\'t have information about that.\n\n'
            'For further information, you can contact us through these platforms:\n\n'
            'Phone: 03 - 89122455 or 017 - 5277473 \n\n'
            'Email: emporiumtherapy@gmail.com \n\n'
            'Facebook: www.facebook.com/kidzemporiumtherapycenter\n\n'
            'Instagram: www.instagram.com/kidzemporiumtherapy\n\n'
            'Tiktok: www.tiktok.com/@kidzemporiumtherapy',
        image: null,
      );
    }
  }

  void _handleLinkTap(String text) {
    // Split the text into sections based on the platforms
    List<String> sections = text.split('\n\n');

    // Iterate over each section to handle the platform-specific action
    for (String section in sections) {
      if (section.contains('Tiktok')) {
        _launchURL('https://www.tiktok.com/@kidzemporiumtherapy');
      } else if (section.contains('Instagram')) {
        _launchURL('https://www.instagram.com/kidzemporiumtherapy');
      } else if (section.contains('Facebook:')) { // Check for exact "Facebook" link
        // Extract the Facebook URL from the section
        String facebookUrl = section.split('Facebook:').last.trim();
        _launchURL(facebookUrl); // Launch the extracted Facebook URL
      }
    }
  }


  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}

class FAQMessage {
  final String? text;
  final String? image;
  final bool isQuestion;

  FAQMessage({
    this.text,
    this.image,
    required this.isQuestion,
  });
}

class FAQResponse {
  final String? text;
  final String? image;

  FAQResponse({
    this.text,
    this.image,
  });
}
