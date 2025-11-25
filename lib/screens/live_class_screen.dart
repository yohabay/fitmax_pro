import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../utils/theme.dart';

class LiveClassScreen extends StatefulWidget {
  final String className;
  final String instructor;

  const LiveClassScreen({
    Key? key,
    required this.className,
    required this.instructor,
  }) : super(key: key);

  @override
  _LiveClassScreenState createState() => _LiveClassScreenState();
}

class _LiveClassScreenState extends State<LiveClassScreen> {
  bool _isConnected = false;
  bool _isMuted = true;
  bool _isVideoOn = true;
  int _participantCount = 0;
  Timer? _participantTimer;
  Timer? _chatTimer;
  final List<Map<String, dynamic>> _chatMessages = [];
  final TextEditingController _chatController = TextEditingController();
  bool _showChat = false;
  bool _showParticipants = false;
  int _hearts = 0;
  Timer? _heartTimer;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isFrontCamera = true;
  List<Map<String, dynamic>> _participants = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _connectToLiveClass();
  }

  @override
  void dispose() {
    _participantTimer?.cancel();
    _chatTimer?.cancel();
    _heartTimer?.cancel();
    _chatController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        await _setupCamera(_isFrontCamera);
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _setupCamera(bool frontCamera) async {
    final lensDirection = frontCamera ? CameraLensDirection.front : CameraLensDirection.back;
    final selectedCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection == lensDirection,
      orElse: () => _cameras!.first,
    );

    _cameraController = CameraController(
      selectedCamera,
      ResolutionPreset.medium,
      enableAudio: true,
    );

    await _cameraController!.initialize();
    if (mounted) {
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    setState(() {
      _isCameraInitialized = false;
      _isFrontCamera = !_isFrontCamera;
    });

    await _cameraController?.dispose();
    await _setupCamera(_isFrontCamera);
  }

  void _connectToLiveClass() {
    // Simulate connection delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isConnected = true;
        });
        _startParticipantUpdates();
        _startChatSimulation();
        _startHeartAnimation();
        _initializeParticipants();
      }
    });
  }

  void _initializeParticipants() {
    // Add some initial participants
    final participantNames = [
      'Sarah M.',
      'Mike R.',
      'Emma W.',
      'Alex P.',
      'Lisa C.',
    ];

    for (int i = 0; i < 3; i++) {
      _participants.add({
        'name': participantNames[i],
        'isOnline': true,
        'hasVideo': Random().nextBool(),
        'isMuted': Random().nextBool(),
      });
    }

    // Simulate participants joining/leaving
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && Random().nextInt(4) == 0) { // 25% chance every 10 seconds
        if (Random().nextBool() && _participants.length < 8) {
          // Add new participant
          final newNames = ['John D.', 'Anna K.', 'Tom B.', 'Maria L.', 'David S.'];
          final availableNames = newNames.where((name) =>
            !_participants.any((p) => p['name'] == name)).toList();

          if (availableNames.isNotEmpty) {
            final newName = availableNames[Random().nextInt(availableNames.length)];
            setState(() {
              _participants.add({
                'name': newName,
                'isOnline': true,
                'hasVideo': Random().nextBool(),
                'isMuted': Random().nextBool(),
              });
            });
          }
        } else if (_participants.length > 2) {
          // Remove random participant
          setState(() {
            _participants.removeAt(Random().nextInt(_participants.length));
          });
        }
      }
    });
  }

  void _inviteParticipant() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final contacts = [
          {'name': 'John Doe', 'status': 'Available'},
          {'name': 'Jane Smith', 'status': 'Busy'},
          {'name': 'Bob Wilson', 'status': 'Available'},
          {'name': 'Alice Brown', 'status': 'Away'},
          {'name': 'Charlie Davis', 'status': 'Available'},
          {'name': 'Emma Wilson', 'status': 'Available'},
          {'name': 'Mike Johnson', 'status': 'Available'},
          {'name': 'Sarah Chen', 'status': 'Busy'},
          {'name': 'David Park', 'status': 'Available'},
          {'name': 'Lisa Wong', 'status': 'Available'},
        ];

        return AlertDialog(
          title: const Text('Invite Participants'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(contact['name']![0]),
                  ),
                  title: Text(contact['name']!),
                  subtitle: Text(contact['status']!),
                  trailing: ElevatedButton(
                    onPressed: contact['status'] == 'Available'
                        ? () {
                            Navigator.of(context).pop();
                            _sendInvitation(contact['name']!);
                          }
                        : null,
                    child: const Text('Invite'),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _sendInvitation(String name) {
    // Immediately add them to participants (like TikTok Live)
    setState(() {
      _participants.add({
        'name': name,
        'isOnline': true,
        'hasVideo': Random().nextBool(),
        'isMuted': Random().nextBool(),
      });
    });

    // Show "joined" animation/notification on screen
    _showJoinNotification(name);
  }

  void _showJoinNotification(String name) {
    // Show a brief overlay notification like TikTok Live
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.of(context).pop();
        });

        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 100, left: 20, right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 40,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_add,
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '$name joined the live class!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startChatSimulation() {
    final chatMessages = [
      'Great workout! 💪',
      'Love this class! 🔥',
      'Thanks for the motivation! 🙌',
      'Amazing form! 👏',
      'Keep it up everyone! 💯',
      'This is so intense! 😅',
      'You got this! 🚀',
      'Inspiring session! ✨',
    ];

    final usernames = [
      'FitnessFan123',
      'WorkoutWarrior',
      'GymGuru',
      'HealthHero',
      'FitFam',
      'SweatSquad',
      'PowerLifter',
      'YogaMaster',
    ];

    _chatTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && Random().nextInt(3) == 0) {
        // 33% chance every 3 seconds
        final username = usernames[Random().nextInt(usernames.length)];
        final message = chatMessages[Random().nextInt(chatMessages.length)];

        setState(() {
          _chatMessages.add({
            'username': username,
            'message': message,
            'timestamp': DateTime.now(),
          });

          // Keep only last 10 messages
          if (_chatMessages.length > 10) {
            _chatMessages.removeAt(0);
          }
        });
      }
    });
  }

  void _startHeartAnimation() {
    _heartTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted && Random().nextInt(5) == 0) {
        // 20% chance every 2 seconds
        setState(() {
          _hearts += Random().nextInt(3) + 1; // 1-3 hearts
        });

        // Reset hearts after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _hearts = 0;
            });
          }
        });
      }
    });
  }

  void _sendMessage() {
    if (_chatController.text.trim().isNotEmpty) {
      setState(() {
        _chatMessages.add({
          'username': 'You',
          'message': _chatController.text.trim(),
          'timestamp': DateTime.now(),
          'isMe': true,
        });
        _chatController.clear();
      });
    }
  }

  void _sendHeart() {
    setState(() {
      _hearts += 5; // Send 5 hearts
    });

    // Reset after animation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _hearts = 0;
        });
      }
    });
  }

  void _startParticipantUpdates() {
    _participantTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _participantCount =
              (_participantCount + 1) % 50 + 10; // 10-59 participants
        });
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _toggleVideo() async {
    if (_cameraController == null) return;

    if (_isVideoOn) {
      await _cameraController!.stopImageStream();
    } else {
      await _cameraController!.startImageStream((image) {
        // Handle camera frames if needed for processing
      });
    }

    setState(() {
      _isVideoOn = !_isVideoOn;
    });
  }

  void _leaveClass() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main video area
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child:
                _isConnected
                    ? Stack(
                      children: [
                        // Camera preview or simulated background
                        if (_isCameraInitialized && _isVideoOn && _cameraController != null)
                          SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _cameraController!.value.previewSize!.height,
                                height: _cameraController!.value.previewSize!.width,
                                child: CameraPreview(_cameraController!),
                              ),
                            ),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  colorScheme.primary.withOpacity(0.3),
                                  colorScheme.secondary.withOpacity(0.3),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isVideoOn ? Icons.live_tv : Icons.videocam_off,
                                    size: 80,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    widget.className,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'with ${widget.instructor}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (!_isVideoOn)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 16),
                                      child: Text(
                                        'Camera is off',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                        // Live indicator
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Participant count
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.people,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$_participantCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Live viewers list (like TikTok)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 160,
                          child: Container(
                            height: 40,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _participants.length + 1, // +1 for current user
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  // Current user
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.blue,
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  );
                                } else {
                                  // Other participants
                                  final participant = _participants[index - 1];
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: participant['isOnline']
                                          ? Colors.green
                                          : Colors.grey,
                                      child: Text(
                                        participant['name'][0],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),

                        // Chat messages overlay
                        Positioned(
                          left: 16,
                          bottom: 210, // Moved up to make room for viewers list
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                _chatMessages.map((msg) {
                                  final isMe = msg['isMe'] == true;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isMe
                                              ? Colors.blue.withOpacity(0.8)
                                              : Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${msg['username']}: ',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          TextSpan(
                                            text: msg['message'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),

                        // Heart animations
                        if (_hearts > 0)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Center(
                                child: Text(
                                  '❤️' * _hearts,
                                  style: TextStyle(
                                    fontSize: 40 + (_hearts * 5),
                                    color: Colors.red.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ),
                          ),
  
                        // Participants overlay
                        if (_showParticipants)
                          Positioned(
                            right: 16,
                            top: 80,
                            bottom: 210, // Moved up to make room for viewers list
                            child: Container(
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Header
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.people,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Participants (${_participants.length + 1})',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
  
                                  // Participants list
                                  Expanded(
                                    child: ListView(
                                      padding: const EdgeInsets.all(8),
                                      children: [
                                        // Current user (you)
                                        ListTile(
                                          dense: true,
                                          leading: CircleAvatar(
                                            radius: 16,
                                            backgroundColor: Colors.blue,
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                          title: const Text(
                                            'You',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (_isVideoOn)
                                                Icon(
                                                  Icons.videocam,
                                                  color: Colors.green,
                                                  size: 16,
                                                ),
                                              if (!_isMuted)
                                                Icon(
                                                  Icons.mic,
                                                  color: Colors.green,
                                                  size: 16,
                                                ),
                                            ],
                                          ),
                                        ),
  
                                        // Other participants
                                        ..._participants.map((participant) {
                                          return ListTile(
                                            dense: true,
                                            leading: CircleAvatar(
                                              radius: 16,
                                              backgroundColor: participant['isOnline']
                                                  ? Colors.green
                                                  : Colors.grey,
                                              child: Text(
                                                participant['name'][0],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              participant['name'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (participant['hasVideo'])
                                                  Icon(
                                                    Icons.videocam,
                                                    color: Colors.green,
                                                    size: 16,
                                                  ),
                                                if (!participant['isMuted'])
                                                  Icon(
                                                    Icons.mic,
                                                    color: Colors.green,
                                                    size: 16,
                                                  ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    )
                    : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Connecting to live class...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
          ),

          // Control buttons
          if (_isConnected)
            Positioned(
              bottom: _showChat ? 210 : 32, // Moved down to make room for viewers list
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Chat input (when chat is shown)
                  if (_showChat)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Say something...',
                                hintStyle: TextStyle(color: Colors.white70),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          IconButton(
                            onPressed: _sendMessage,
                            icon: const Icon(Icons.send, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                  // Main controls
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Mute button
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _toggleMute,
                            icon: Icon(
                              _isMuted ? Icons.mic_off : Icons.mic,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),

                        // Video button
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _toggleVideo,
                            icon: Icon(
                              _isVideoOn ? Icons.videocam : Icons.videocam_off,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),

                        // Camera switch button
                        if (_cameras != null && _cameras!.length > 1)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: _switchCamera,
                              icon: const Icon(
                                Icons.flip_camera_ios,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),

                        // Invite button
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _inviteParticipant,
                            icon: const Icon(
                              Icons.person_add,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),

                        // Participants button
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: _showParticipants
                                ? Colors.green
                                : Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _showParticipants = !_showParticipants;
                              });
                            },
                            icon: Icon(
                              _showParticipants
                                  ? Icons.people
                                  : Icons.people_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),

                        // Chat button
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color:
                                _showChat
                                    ? Colors.blue
                                    : Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _showChat = !_showChat;
                              });
                            },
                            icon: Icon(
                              _showChat
                                  ? Icons.chat_bubble
                                  : Icons.chat_bubble_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),

                        // Heart button
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _sendHeart,
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                        ),

                        // Leave button
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _leaveClass,
                            icon: const Icon(
                              Icons.call_end,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Connection status overlay
          if (!_isConnected) Container(color: Colors.black.withOpacity(0.7)),
        ],
      ),
    );
  }
}
