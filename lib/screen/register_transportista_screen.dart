import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLngLib;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import '../model/conductor.dart';
import '../services/api_service.dart';

class RegisterTransportistaScreen extends StatefulWidget {
  const RegisterTransportistaScreen({Key? key}) : super(key: key);

  @override
  _RegisterTransportistaScreenState createState() => _RegisterTransportistaScreenState();
}

class _RegisterTransportistaScreenState extends State<RegisterTransportistaScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _carnetController = TextEditingController();
  final TextEditingController _licenciaConducirController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  DateTime? _selectedDate;
  latLngLib.LatLng? _selectedLocation;
  String? _direccionSeleccionada;
  bool _mapReady = false;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }
    _initializeCurrentLocation();
  }

  Future<void> _initializeCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _selectedLocation = latLngLib.LatLng(position.latitude, position.longitude);
      _mapReady = true;
    });
    _getAddressFromLatLng(_selectedLocation!);
  }

  Future<void> _getAddressFromLatLng(latLngLib.LatLng position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      setState(() {
        _direccionSeleccionada = "${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.country}";
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime initialDate = _selectedDate ?? DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _onMapTap(latLngLib.LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    _getAddressFromLatLng(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Transportista'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nombreController, 'Nombre', 'Ingrese su nombre'),
              _buildTextField(_apellidoController, 'Apellido', 'Ingrese su apellido'),
              _buildTextField(_carnetController, 'Carnet', 'Ingrese su carnet'),
              _buildTextField(_licenciaConducirController, 'Licencia de Conducir', 'Ingrese su licencia'),
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Seleccione su fecha de nacimiento'
                      : 'Fecha de Nacimiento: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today, color: Colors.blue),
                onTap: () => _selectDate(context),
              ),
              _buildTextField(_emailController, 'Email', 'Ingrese su email', isEmail: true),
              _buildTextField(_passwordController, 'Contraseña', 'Ingrese su contraseña', isPassword: true),
              const SizedBox(height: 20),
              _mapReady && _selectedLocation != null
                  ? SizedBox(
                      height: 300,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: _selectedLocation!,
                          initialZoom: 15,
                          onTap: (tapPosition, point) => _onMapTap(point),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _selectedLocation!,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),

              ListTile(
                title: const Text('Dirección seleccionada:'),
                subtitle: Text(_direccionSeleccionada ?? 'Toca el mapa para seleccionar tu ubicación'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _selectedLocation != null) {
                    _registerConductor();
                  } else {
                    _showSnackBar(context, "Error al registrar conductor. Revisa los campos.", Colors.red);
                  }
                },
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _registerConductor() async {
    final conductor = Conductor(
      nombre: _nombreController.text,
      apellido: _apellidoController.text,
      carnet: _carnetController.text,
      licenciaConducir: _licenciaConducirController.text,
      fechaNacimiento: _selectedDate!,
      direccion: _direccionSeleccionada!,
      email: _emailController.text,
      password: _passwordController.text,
      ubicacionLatitud: _selectedLocation!.latitude,
      ubicacionLongitud: _selectedLocation!.longitude,
      estado: "activo",
    );

    final response = await _apiService.createConductor(conductor.toJson());
    if (response.statusCode == 201) {
      _showSnackBar(context, "Conductor registrado correctamente.", Colors.green);
    } else {
      _showSnackBar(context, "Error: ${response.body}", Colors.red);
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint,
      {bool isPassword = false, bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, ingrese $label';
          }
          return null;
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
