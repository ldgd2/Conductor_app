# Conductor App

Aplicación móvil para conductores, que incluye funcionalidades de inicio de sesión, registro, manejo de vehículos y ofertas, integración con notificaciones y servicios de ubicación en tiempo real.

## Estructura del Proyecto

conductor_app/ ├── lib/ │ ├── main.dart # Punto de entrada de la aplicación │ ├── firebase_options.dart # Configuración de Firebase │ ├── models/ # Modelos de datos │ │ ├── Agricultor.dart │ │ ├── CargaOferta.dart │ │ ├── Conductor.dart │ │ ├── Pedido.dart │ │ └── (...otros modelos) │ ├── notifications/ # Gestión de notificaciones │ │ └── notification.dart # Servicio de notificaciones │ ├── screens/ # Pantallas principales │ │ ├── home_screen.dart # Pantalla principal │ │ ├── loginscreen.dart # Pantalla de inicio de sesión │ │ ├── PedidosOfertasScreen.dart # Pantalla de pedidos y ofertas │ │ ├── register_transportista_screen.dart # Pantalla de registro │ │ ├── RegistrarVeiculosScreen.dart # Pantalla de registro de vehículos │ │ └── VehiculosScreen.dart # Pantalla de gestión de vehículos │ ├── services/ # Servicios auxiliares │ │ ├── api_service.dart # Cliente API │ │ └── ConductorProvider.dart # Manejo del estado global │ ├── themes/ # Temas de la aplicación │ └── theme.dart # Definición de tema ├── pubspec.yaml # Archivo de configuración de dependencias


## Configuración de Firebase

1. Crea un proyecto en [Firebase Console](https://console.firebase.google.com/).
2. Agrega una aplicación Android con el paquete correspondiente (`com.tuempresa.conductorapp`).
3. Descarga el archivo `google-services.json` y colócalo en el directorio `android/app/`.
4. Asegúrate de agregar el archivo `firebase_options.dart` en tu proyecto. Este archivo se genera automáticamente con el comando:

   flutterfire configure



# Dependencias
Las dependencias utilizadas en el proyecto están listadas en el archivo pubspec.yaml. Aquí están las más importantes:

## dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
  http: ^1.2.2
  provider: ^6.1.2
  google_maps_flutter: ^2.9.0
  geolocator: ^9.0.0
  geocoding: ^3.0.0
  flutter_map: ^7.0.2
  latlong2: ^0.9.1
  intl: ^0.19.0
  shared_preferences: ^2.3.3
  flutter_local_notifications: ^18.0.1
  firebase_messaging: ^15.1.4
  path_provider: ^2.1.5

## Principales funciones de estas dependencias:
**http:** Manejo de solicitudes HTTP para interactuar con el backend.
**provider:** Manejo del estado global de la aplicación.
**google_maps_flutter:** Renderización de mapas utilizando Google Maps.
**geolocator:** Obtención de ubicación en tiempo real.
**geocoding:** Conversión de coordenadas a direcciones y viceversa.
**flutter_map y latlong2:** Alternativa a Google Maps para visualización de mapas.
**intl**: Manejo de fechas, formatos y localización.
**shared_preferences:** Almacenamiento local de datos como tokens o preferencias del usuario.
**flutter_local_notifications:** Envío de notificaciones locales dentro de la app.
**firebase_messaging:** Recepción de notificaciones push desde Firebase.
**path_provider:** Gestión de rutas de almacenamiento de archivos.

# Notificaciones

**Firebase Messaging:** Implementado para recibir notificaciones push desde el servidor.
**Notificaciones Locales:** Implementado para mostrar notificaciones dentro de la aplicación.


# Configuración

Configura permisos en AndroidManifest.xml y Info.plist para notificaciones.
Inicializa el servicio de notificaciones en main.dart.

# Funcionalidades principales
**Inicio de sesión y registro:** Implementación de autenticación básica.
**Gestión de vehículos:** Registro y visualización de vehículos asociados.
**Pedidos y Ofertas:** Gestión de ofertas de transporte y pedidos en tiempo real.


# Ejecución del Proyecto

**Instala las dependencias:**
flutter pub get

**Ejecuta la aplicación en tu dispositivo o emulador:**

flutter run
