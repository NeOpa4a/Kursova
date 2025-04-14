import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nova_poshta/services/FIreBaseService.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController smsController = TextEditingController();
  Firebaseservice firebaseservice = Firebaseservice();
  List<dynamic> parcels = []; // Список для зберігання знайдених посилок
  late bool showSms = false;
  late bool showParcelDetails = false;
  List<TextEditingController> smsControllers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in smsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String? verificationId;

  void send() async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumberController.text,
        codeSent: (String verificationId, int? resendToken) {
          print("📩 Код надіслано. verificationId: $verificationId");
          setState(() {
            this.verificationId = verificationId; // Зберігаємо verificationId
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print("❌ Помилка: ${e}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Помилка при відправці SMS: ${e.message}'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        },
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          print("✅ Вхід завершено автоматично");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("⌛ Тайм-аут автоматичного отримання коду");
          setState(() {
            this.verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      print("❌ Помилка під час виклику verifyPhoneNumber: $e");
    }
  }

  Future<bool> checkCode(String code) async {
    if (verificationId == null) {
      print("❌ Verification ID відсутній");
      return false;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: code,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        print(
            "✅ Вхід завершено для номера: ${userCredential.user!.phoneNumber}");
        return true;
      } else {
        print("❌ Не вдалося увійти");
        return false;
      }
    } catch (e) {
      print("❌ Помилка перевірки: $e");
      return false;
    }
  }

  void SearchByPhone() {
    // Implement your search logic here
    setState(() {
      parcels = []; // Очищаємо список перед новим пошуком
      showParcelDetails = false; // Скидаємо стан деталей посилки
      showSms = false; // Скидаємо стан SMS
      verificationId = null; // Скидаємо verificationId
    });
    if (phoneNumberController.text != null) {
      firebaseservice.getParcels(phoneNumberController.text).then((value) {
        if (value.docs.isNotEmpty) {
          setState(() {
            parcels = value.docs
                .map((doc) => doc.data())
                .toList(); // Зберігаємо знайдені посилки у списку
            for (var i = 0; i < parcels.length; i++) {
              smsControllers.add(TextEditingController());
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Parcels found!'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'No parcels found for this phone number. But you always can make one ;)'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid phone number'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Image(
          image: AssetImage(
            './images/photo_2025-04-12_22-31-28.jpg',
          ),
          fit: BoxFit.fill,
          width: 130,
          height: 130,
          // 'GO BOX',
          // style: TextStyle(
          //   color: Colors.white,
          //   fontWeight: FontWeight.bold, fontSize: 50,
          // fontFamily: "Gagalin"),
        ),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(),
        ),
        backgroundColor: Color(0xFFFF8C0F),
        elevation: 0,
      ),
      backgroundColor: Color(0xFF0c1113),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('GO BOX',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('©2025 Go Box. All rights reserved',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('About Us',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Working hours: 9AM - 6PM',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Support',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text('+1 800 123 4567',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                    SizedBox(width: 8),
                    Icon(Icons.email, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text('support@example.com',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
                Row(
                  children: [],
                ),
              ],
            ),
          ]),
        ),
        color: Color(0xFF13161b),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Text.rich(
              TextSpan(
                text: 'Welcome to ', // Перша частина тексту
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold), // Стиль для першої частини
                children: <TextSpan>[
                  TextSpan(
                    text: 'GO BOX', // Текст, що буде іншого кольору
                    style: TextStyle(
                        color: Color(0xFFFF8C0F),
                        fontSize: 24,
                        fontWeight: FontWeight.bold), // Стиль для GO BOX
                  ),
                ],
              ),
            ),
            Container(
                margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.3,
                    vertical: MediaQuery.of(context).size.height * 0.05),
                child: Column(
                  children: [
                    TextField(
                      style: TextStyle(color: Colors.white),
                      cursorColor: Color(0xFFFF8C0F),
                      controller: phoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    ElevatedButton(
                        onPressed: SearchByPhone,
                        child: Text(
                          "Submit",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF8C0F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )),
                  ],
                )),
            SizedBox(height: MediaQuery.of(context).size.height * 0.005),
            Expanded(
              child: Container(
                child: parcels.length == 0
                    ? Center(
                        child: Text('No parcels found',
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
                      )
                    : ListView.builder(
                        itemCount: parcels.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.3,
                                vertical:
                                    MediaQuery.of(context).size.height * 0.01),
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.05,
                                vertical:
                                    MediaQuery.of(context).size.height * 0.02),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF1a1d1f), // Кінцевий колір
                                  Color(0xFF1a1d1f), // Кінцевий колір
                                  Color(0xFFFF8C0F), // Початковий колір
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                  color: Color(0xFFFF8C0F), width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Status: ',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: '${parcels[index]['status']}',
                                        style: TextStyle(
                                          color: Color(
                                              0xFFFF8C0F), // або будь-який інший колір для статусу
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),

                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Tracking number: ',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                      TextSpan(
                                        text:
                                            '${parcels[index]['trackingNumber']}',
                                        style: TextStyle(
                                          color: Color(
                                              0xFFFF8C0F), // або будь-який інший колір для tracking number
                                          fontSize: 16,
                                          fontWeight: FontWeight
                                              .bold, // Можна додати жирний шрифт, якщо потрібно
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),
                                // Text('Delivery Address: ${parcels[index]['deliveryAdress']}', style: TextStyle(color: Colors.white, fontSize: 16)),
                                // SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                if (!showParcelDetails)
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF0c1113),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'For more details, please sign in:',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16)),
                                        if (!showParcelDetails)
                                          ElevatedButton(
                                            onPressed: () {
                                              send();
                                              setState(() {
                                                showSms = true;
                                              });
                                            },
                                            child: Text('Sign In',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color(0xFFFF8C0F),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),
                                if (showSms)
                                  TextField(
                                    style: TextStyle(color: Colors.white),
                                    cursorColor: Color(0xFFFF8C0F),
                                    controller: smsControllers[index],
                                    onSubmitted: (value) async {
                                      bool result = await checkCode(value);
                                      if (result) {
                                        setState(() {
                                          showParcelDetails = true;
                                          showSms = false;
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('Invalid SMS code!'),
                                            duration: Duration(seconds: 2),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'SMS Code',
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),
                                if (showParcelDetails)
                                  Text("Parcel Details",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold)),
                                if (showParcelDetails)
                                  Row(
                                    children: [
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.person,
                                                    color: Colors
                                                        .white), // Іконка для відправника
                                                SizedBox(width: 8),
                                                if (parcels[index]['sender'] !=
                                                    null)
                                                  Text(
                                                      'Sender: ${parcels[index]['sender']}',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16)),
                                              ],
                                            ),
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.01),
                                            Row(
                                              children: [
                                                Icon(Icons.person_add,
                                                    color: Colors
                                                        .white), // Іконка для отримувача
                                                SizedBox(width: 8),
                                                if (parcels[index]
                                                        ['customer'] !=
                                                    null)
                                                  Text(
                                                      'Receiver: ${parcels[index]['customer']['name'] ?? ""}',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16)),
                                              ],
                                            ),
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.01),
                                            Row(
                                              children: [
                                                Icon(Icons.title,
                                                    color: Colors
                                                        .white), // Іконка для отримувача
                                                SizedBox(width: 8),
                                                if (parcels[index]['title'] !=
                                                    null)
                                                  Text(
                                                      'Product: ${parcels[index]['title']}',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16)),
                                              ],
                                            ),
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.01),
                                            Row(
                                              children: [
                                                Icon(Icons.location_on,
                                                    color: Colors
                                                        .white), // Іконка для адреси доставки
                                                SizedBox(width: 8),
                                                if (parcels[index]
                                                        ['deliveryAdress'] !=
                                                    null)
                                                  Text(
                                                      'Delivery Address: ${parcels[index]['deliveryAdress']}',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16)),
                                              ],
                                            ),
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.01),
                                            Row(
                                              children: [
                                                Icon(Icons.attach_money,
                                                    color: Colors
                                                        .white), // Іконка для адреси доставки
                                                SizedBox(width: 8),
                                                if (parcels[index]['isPayed'] !=
                                                    null)
                                                  Text(
                                                      parcels[index]['isPayed']
                                                          ? "Payed"
                                                          : "Not Payed",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16)),
                                              ],
                                            ),
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.01),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_month,
                                                    color: Colors
                                                        .white), // Іконка для адреси доставки
                                                SizedBox(width: 8),
                                                if (parcels[index]['DateSHP'] !=
                                                    null)
                                                  Text(
                                                      "Sent date: ${parcels[index]['DateSHP']}",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16)),
                                              ],
                                            ),
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.01),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_month,
                                                    color: Colors
                                                        .white), // Іконка для адреси доставки
                                                SizedBox(width: 8),
                                                if (parcels[index]['DateARR'] !=
                                                    null)
                                                  Text(
                                                      "Date received: ${parcels[index]['DateARR']}",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16)),
                                              ],
                                            ),
                                          ])
                                    ],
                                  )
                              ],
                            ),
                          );
                        },
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
