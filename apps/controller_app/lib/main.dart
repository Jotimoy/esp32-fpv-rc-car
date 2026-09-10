import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(const ControllerApp());

class ControllerApp extends StatelessWidget {
  const ControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FPV RC Controller',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ControlScreen(),
    );
  }
}

enum CarConnectionState { disconnected, connecting, connected }

class CarConnection extends ChangeNotifier {
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  CarConnectionState state = CarConnectionState.disconnected;
  String status = 'Disconnected';
  int _sequence = 0;

  Future<void> connect(String url) async {
    await disconnect();
    state = CarConnectionState.connecting;
    status = 'Connecting...';
    notifyListeners();

    try {
      final channel = WebSocketChannel.connect(Uri.parse(url));
      await channel.ready.timeout(const Duration(seconds: 5));
      _channel = channel;
      _subscription = channel.stream.listen(
        (message) {
          final decoded = jsonDecode(message as String) as Map<String, dynamic>;
          status = '${decoded['type']}: ${decoded['message']}';
          notifyListeners();
        },
        onDone: _markDisconnected,
        onError: (Object error) => _markDisconnected(error.toString()),
      );
      state = CarConnectionState.connected;
      status = 'Connected';
    } catch (error) {
      state = CarConnectionState.disconnected;
      status = 'Connection failed: $error';
    }
    notifyListeners();
  }

  void drive(String action, {int speed = 180}) {
    if (state != CarConnectionState.connected) return;
    _channel!.sink.add(
      jsonEncode({
        'v': 1,
        'type': 'drive',
        'seq': ++_sequence,
        'action': action,
        'speed': speed,
      }),
    );
  }

  Future<void> disconnect() async {
    if (state == CarConnectionState.connected) drive('stop', speed: 0);
    await _subscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _subscription = null;
    _markDisconnected();
  }

  void _markDisconnected([String? detail]) {
    state = CarConnectionState.disconnected;
    status = detail == null ? 'Disconnected' : 'Disconnected: $detail';
    notifyListeners();
  }

  @override
  void dispose() {
    if (state == CarConnectionState.connected) drive('stop', speed: 0);
    _subscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final _urlController = TextEditingController(text: 'ws://192.168.4.1:81/');
  final _connection = CarConnection();
  Timer? _repeatTimer;
  int _speed = 180;

  @override
  void initState() {
    super.initState();
    _connection.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _startDriving(String action) {
    _repeatTimer?.cancel();
    _connection.drive(action, speed: _speed);
    _repeatTimer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => _connection.drive(action, speed: _speed),
    );
  }

  void _stopDriving() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
    _connection.drive('stop', speed: 0);
  }

  @override
  void dispose() {
    _repeatTimer?.cancel();
    _connection.removeListener(_refresh);
    _connection.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connected = _connection.state == CarConnectionState.connected;
    return Scaffold(
      appBar: AppBar(title: const Text('FPV RC Controller - Phase 1')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'ESP32 WebSocket URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: connected
                          ? _connection.disconnect
                          : () => _connection.connect(_urlController.text),
                      icon: Icon(connected ? Icons.link_off : Icons.link),
                      label: Text(connected ? 'Disconnect' : 'Connect'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(_connection.status, textAlign: TextAlign.center),
              const Spacer(),
              DirectionButton(
                icon: Icons.keyboard_arrow_up,
                label: 'Forward',
                enabled: connected,
                onStart: () => _startDriving('forward'),
                onStop: _stopDriving,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DirectionButton(
                    icon: Icons.keyboard_arrow_left,
                    label: 'Left',
                    enabled: connected,
                    onStart: () => _startDriving('left'),
                    onStop: _stopDriving,
                  ),
                  DirectionButton(
                    icon: Icons.stop_circle,
                    label: 'Stop',
                    enabled: connected,
                    color: Colors.red,
                    onStart: _stopDriving,
                    onStop: _stopDriving,
                  ),
                  DirectionButton(
                    icon: Icons.keyboard_arrow_right,
                    label: 'Right',
                    enabled: connected,
                    onStart: () => _startDriving('right'),
                    onStop: _stopDriving,
                  ),
                ],
              ),
              DirectionButton(
                icon: Icons.keyboard_arrow_down,
                label: 'Backward',
                enabled: connected,
                onStart: () => _startDriving('backward'),
                onStop: _stopDriving,
              ),
              const Spacer(),
              Text('Speed: $_speed / 255'),
              Slider(
                value: _speed.toDouble(),
                min: 80,
                max: 255,
                divisions: 175,
                onChanged: (value) => setState(() => _speed = value.round()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DirectionButton extends StatelessWidget {
  const DirectionButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onStart,
    required this.onStop,
    this.color,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Listener(
        onPointerDown: enabled ? (_) => onStart() : null,
        onPointerUp: enabled ? (_) => onStop() : null,
        onPointerCancel: enabled ? (_) => onStop() : null,
        child: SizedBox(
          width: 100,
          height: 82,
          child: FilledButton(
            onPressed: enabled ? () {} : null,
            style: FilledButton.styleFrom(
              backgroundColor: color,
              padding: EdgeInsets.zero,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(icon, size: 32), Text(label)],
            ),
          ),
        ),
      ),
    );
  }
}
