import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'borrower-success-topup.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

class IsiProvider with ChangeNotifier {
  int _saku = 0;
  int _updatesaku = 0;
  bool _isDataFetched = false;
  String _validationError = 'kosong';

  int get saku => _saku;
  int get updatesaku => _updatesaku;
  String get validationError => _validationError;

  void setsaku(int value) {
    _saku = value;
    notifyListeners();
  }

  void setupdatesaku(int value) {
    _updatesaku = value;
    notifyListeners();
  }

  bool validateForm() {
    print("woy woy :$_updatesaku");
    if (_updatesaku == 0 || _updatesaku == Null) {
      _validationError = 'kosong';
    } else {
      _validationError = '';
    }
    notifyListeners();
    return _validationError.isEmpty;
  }

  Future<void> fetchData(int id) async {
    if (_isDataFetched) {
      // Data has already been fetched, no need to fetch again
      return;
    }
    final apiUrl = Uri.parse('http://127.0.0.1:8000/borrowers/$id');

    try {
      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _saku = data['saku'];
        _isDataFetched = true;
        notifyListeners();
      } else {
        throw Exception('Failed to fetch saku data');
      }
    } catch (error) {
      throw Exception('Failed to connect to the server');
    }
  }

  Future<void> patchSaku(int id, int updatedSaku) async {
    final apiUrl = Uri.parse('http://127.0.0.1:8000/update_borrower_patch/$id');
    print("saku = $saku");
    print("updated saku :  $updatedSaku");
    try {
      final response = await http.patch(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"saku": saku + updatedSaku}),
      );

      if (response.statusCode == 200) {
        _saku += updatedSaku;
        _isDataFetched = false;
        notifyListeners();
        final url = Uri.parse("http://127.0.0.1:8000/riwayat/");
        var response2 = await http.post(url,
            headers: {"Content-Type": "application/json"},
            body: json.encode({
              'borrower_id': id,
              'nominal': updatesaku,
              'status': "topup",
            }));
        if (response2.statusCode == 200) {
          print('Riwayat request successful');
          print('Response body: ${response2.body}');
        } else {
          print('Post request failed');
          print('Response status code: ${response2.statusCode}');
        }
      } else {
        throw Exception('Failed to update saku data');
      }
    } catch (error) {
      throw Exception('Failed to connect to the server');
    }
  }
}

class IsiSaldoBorrower extends StatefulWidget {
  const IsiSaldoBorrower({Key? key, required this.id}) : super(key: key);
  final int id;
  @override
  HalamanIsiSaldoBorrower createState() => HalamanIsiSaldoBorrower();
}

class HalamanIsiSaldoBorrower extends State<IsiSaldoBorrower> {
  int selectedAmount = 0;

  void selectAmount(int amount) {
    setState(() {
      selectedAmount = amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isiProvider = Provider.of<IsiProvider>(context);
    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.teal),
        home: Scaffold(
            body: FutureBuilder(
                // future: isiProvider.fetchData(widget.id),
                future: Provider.of<IsiProvider>(context, listen: false)
                    .fetchData(widget.id),
                builder: (context, snapshot) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30, top: 25),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back_rounded,
                                size: 30.0,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () => selectAmount(50000),
                            child: AmountOption(
                              amount: 50000,
                              isSelected: selectedAmount == 50000,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => selectAmount(100000),
                            child: AmountOption(
                              amount: 100000,
                              isSelected: selectedAmount == 100000,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => selectAmount(200000),
                            child: AmountOption(
                              amount: 200000,
                              isSelected: selectedAmount == 200000,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () => selectAmount(300000),
                            child: AmountOption(
                              amount: 300000,
                              isSelected: selectedAmount == 300000,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => selectAmount(500000),
                            child: AmountOption(
                              amount: 500000,
                              isSelected: selectedAmount == 500000,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => selectAmount(1000000),
                            child: AmountOption(
                              amount: 1000000,
                              isSelected: selectedAmount == 1000000,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 30, right: 30, top: 20),
                        child: Row(
                          children: [
                            Text(
                              "Atau, ketik sendiri nominalnya",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 30, right: 30, bottom: 20),
                        child: Container(
                          child: TextField(
                            onChanged: (text) {
                              if (text.isEmpty) {
                                isiProvider.setupdatesaku(0);
                              } else {
                                int nilai = int.parse(text);
                                isiProvider.setupdatesaku(nilai);
                              }
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              prefixText: 'Rp ',
                            ),
                            style: TextStyle(
                              fontSize: 40.0,
                              fontWeight: FontWeight.bold,
                            ), // Menyesuaikan ukuran teks
                          ),
                        ),
                      ),
                      Container(
                        color: Color.fromRGBO(191, 220, 174, 1),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 40, right: 30),
                              child: Row(
                                children: [
                                  Text(
                                    "Rekening Sumber",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromRGBO(32, 106, 93, 1),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, bottom: 20, left: 30, right: 30),
                              child: Container(
                                // color: Color.fromRGBO(191, 220, 174, 1),
                                width: double.infinity,
                                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                // margin: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Saku Modal In',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '8632458732423',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      height: 1,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey,
                                            width: 2,
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 10),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  'Rp 178.256.438,00',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color.fromRGBO(
                                                          0, 177, 71, 1)),
                                                ),
                                              ],
                                            ),
                                          ]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: ElevatedButton(
                                onPressed: () {
                                  isiProvider.validateForm();
                                  if (isiProvider.validationError == "kosong") {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Warning'),
                                          content:
                                              Text('Tolong isi Dulu Nominal'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                              },
                                              child: Text('Close'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    isiProvider.patchSaku(
                                        widget.id, isiProvider.updatesaku);
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return BorrowerSuccessTopup(
                                          id: widget.id);
                                    }));
                                  }
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  backgroundColor: MaterialStateProperty.all(
                                    Color.fromRGBO(32, 106, 93, 1),
                                  ),
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.all(20)),
                                ),
                                child: Text(
                                  'LANJUTKAN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                })));
  }
}

class AmountOption extends StatelessWidget {
  final int amount;
  final bool isSelected;

  const AmountOption({
    required this.amount,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.money,
            color: isSelected ? Colors.green : Colors.black,
            size: 40,
          ),
          SizedBox(height: 10),
          Text(
            'Rp. $amount',
            style: TextStyle(
              color: isSelected ? Colors.green : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
