import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';



// MAIN
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LicenseRegistry.addLicense(() async* {
    final String bytesizedOFL = await rootBundle.loadString('fonts/Bytesized-OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], bytesizedOFL);
  });

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(App());
}



// APP
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: Constants.title,
      theme: Constants.theme,
      routerConfig: Constants.router,
    );
  }
}



// ROOT
class Root extends StatelessWidget {
  const Root({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: Constants.width / Constants.height,
          child: GameWidget(game: Frame()),
        ),
      ),
    );
  }
}



// FRAME
class Frame extends FlameGame with HasKeyboardHandlerComponents {
  late Background background;
  late Character character;
  late JoystickComponent joystick;
  late Button leftButton;
  late Button rightButton;
  late Button jumpButton;
  late Button dashButton;
  late Button biteButton;
  late Button kickButton;

  @override
  Color backgroundColor() {
    return Theme.of(Constants.rootNavigatorKey.currentContext!).colorScheme.primary;
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    images.prefix = '';
    await images.loadAllImages();

    camera = CameraComponent.withFixedResolution(
      width: Constants.width,
      height: Constants.height,
    )..viewfinder.anchor = Anchor.topLeft;
    add(camera);

    background = Background();
    camera.backdrop.add(background);

    character = Character(
      name: CharacterNames.nico.name,
      isFacingRight: true,
      position: Vector2(100, Constants.height - (24.0 * 9.0)), // Initial position on ground
    );
    world.add(character);

    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache(Constants.joystickKnobImage)),
        size: Vector2.all(Constants.joystickSize / 2),
      ),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache(Constants.joystickBackgroundImage)),
        size: Vector2.all(Constants.joystickSize),
      ),
      margin: EdgeInsets.only(
        left: 32,
        bottom: 32,
      ),
    );
    //camera.viewport.add(joystick);

    leftButton = Button(
      sprite: Sprite(
        images.fromCache(Constants.gamepadControlsImage),
        srcSize: Vector2(16, 16),
        srcPosition: Vector2(64, 64),
      ),
      size: Vector2(64, 64),
      position: Vector2(50, Constants.height - 64),
      anchor: Anchor.center,
    );
    camera.viewport.add(leftButton);

    rightButton = Button(
      sprite: Sprite(
        images.fromCache(Constants.gamepadControlsImage),
        srcSize: Vector2(16, 16),
        srcPosition: Vector2(80, 64),
      ),
      size: Vector2(64, 64),
      position: Vector2(50 + 64 + 16, Constants.height - 64),
      anchor: Anchor.center,
    );
    camera.viewport.add(rightButton);

    jumpButton = Button(
      sprite: Sprite(
        images.fromCache(Constants.gamepadControlsImage),
        srcSize: Vector2(16, 16),
        srcPosition: Vector2(0, 0),
      ),
      size: Vector2(64, 64),
      position: Vector2(Constants.width - 64 - 64 - 16, Constants.height - 64),
      anchor: Anchor.center,
    );
    camera.viewport.add(jumpButton);

    dashButton = Button(
      sprite: Sprite(
        images.fromCache(Constants.gamepadControlsImage),
        srcSize: Vector2(16, 16),
        srcPosition: Vector2(32, 0),
      ),
      size: Vector2(64, 64),
      position: Vector2(Constants.width - 64 - 64 - 64 - 16, Constants.height - 64 - 64),
      anchor: Anchor.center,
    );
    camera.viewport.add(dashButton);

    biteButton = Button(
      sprite: Sprite(
        images.fromCache(Constants.gamepadControlsImage),
        srcSize: Vector2(16, 16),
        srcPosition: Vector2(16, 0),
      ),
      size: Vector2(64, 64),
      position: Vector2(Constants.width - 64 - 16, Constants.height - 64 - 64),
      anchor: Anchor.center,
    );
    camera.viewport.add(biteButton);

    kickButton = Button(
      sprite: Sprite(
        images.fromCache(Constants.gamepadControlsImage),
        srcSize: Vector2(16, 16),
        srcPosition: Vector2(48, 0),
      ),
      size: Vector2(64, 64),
      position: Vector2(Constants.width - 64 - 64 - 16, Constants.height - 64 - 64 - 64),
      anchor: Anchor.center,
    );
    camera.viewport.add(kickButton);
  }

  @override
  void update(double dt) {
    super.update(dt);
    background.parallax?.baseVelocity.x = character.velocity.x;
  }
}



// BUTTON
class Button extends SpriteComponent with TapCallbacks {
  bool isPressed = false;

  Button({
    super.sprite,
    super.size,
    super.position,
    super.anchor,
  });

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    isPressed = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    isPressed = false;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    super.onTapCancel(event);
    isPressed = false;
  }
}



// BACKGROUND
class Background extends ParallaxComponent<Frame> {
  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    parallax = await game.loadParallax(
      [
        for (int i = 2; i <= 5; i++)
          ParallaxImageData(
            Functions.backgroundImage(i)
          )
      ],
      baseVelocity: Vector2(0, 0),
      velocityMultiplierDelta: Vector2(1.1, 1.0),
      repeat: ImageRepeat.repeatX,
      fill: LayerFill.height
    );
  }
}



// CHARACTER
enum CharacterNames {
  kuro,
  mono,
  nico,
}

enum CharacterState {
  idle,
  move,
  dash,
  bite,
  hurt,
  kick,
}

enum CharacterDirection {
  none,
  left,
  right,
}

class Character extends SpriteAnimationGroupComponent with HasGameReference<Frame>, KeyboardHandler {
  String name;

  CharacterDirection playerDirection = CharacterDirection.none;
  double moveSpeed = 350.0;
  double dashSpeed = 600.0;
  bool isDashing = false;
  bool isBiting = false;
  bool isKicking = false;
  Vector2 velocity = Vector2.zero();
  bool isFacingRight;
  double jumpSpeed = 800.0; // Initial upward velocity
  double gravity = 2400.0; // Downward acceleration
  bool isOnGround = true;
  double groundLevel = 0.0; // Will be set in onLoad

  Character({
    required this.name,
    required this.isFacingRight,
    Vector2? position,
  }) : super(position: position ?? Vector2.zero()); // Pass position to super, default to zero

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    animations = {
      CharacterState.idle: SpriteAnimation.fromFrameData(
        game.images.fromCache(Functions.characterImage(name, CharacterState.idle.name)),
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.15,
          textureSize: Vector2(24.0, 24.0),
        ),
      ),
      CharacterState.move: SpriteAnimation.fromFrameData(
        game.images.fromCache(Functions.characterImage(name, CharacterState.move.name)),
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(24.0, 24.0),
        ),
      ),
      CharacterState.dash: SpriteAnimation.fromFrameData(
        game.images.fromCache(Functions.characterImage(name, CharacterState.dash.name)),
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(24.0, 24.0),
        ),
      ),
      CharacterState.bite: SpriteAnimation.fromFrameData(
        game.images.fromCache(Functions.characterImage(name, CharacterState.bite.name)),
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.05,
          textureSize: Vector2(24.0, 24.0),
          loop: false,
        ),
      ),
      CharacterState.kick: SpriteAnimation.fromFrameData(
        game.images.fromCache(Functions.characterImage(name, CharacterState.kick.name)),
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.05,
          textureSize: Vector2(24.0, 24.0),
          loop: false,
        ),
      ),
    };
    current = CharacterState.idle;
    scale = Vector2(5.0, 5.0);

    // Set ground level based on initial position after scaling
    // This assumes the character's initial position is the ground.
    groundLevel = position.y;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Poll both Keyboard and Joystick states
    final keys = HardwareKeyboard.instance.logicalKeysPressed;

    bool isLeft = keys.contains(LogicalKeyboardKey.arrowLeft) || 
                 keys.contains(LogicalKeyboardKey.keyA) ||
                 game.joystick.direction == JoystickDirection.left ||
                 game.joystick.direction == JoystickDirection.upLeft ||
                 game.joystick.direction == JoystickDirection.downLeft ||
                 game.leftButton.isPressed;

    bool isRight = keys.contains(LogicalKeyboardKey.arrowRight) || 
                  keys.contains(LogicalKeyboardKey.keyD) ||
                  game.joystick.direction == JoystickDirection.right ||
                  game.joystick.direction == JoystickDirection.upRight ||
                  game.joystick.direction == JoystickDirection.downRight ||
                  game.rightButton.isPressed;

    if (!isBiting) isBiting = game.biteButton.isPressed;
    if (!isKicking) isKicking = game.kickButton.isPressed;

    isDashing = game.dashButton.isPressed;

    if (game.jumpButton.isPressed && isOnGround) {
      velocity.y = -jumpSpeed;
      isOnGround = false;
    }

    // Resolve movement direction
    playerDirection = (isLeft && !isRight) 
        ? CharacterDirection.left 
        : (isRight && !isLeft) 
            ? CharacterDirection.right 
            : CharacterDirection.none;

    double directionX = 0.0;
    double currentSpeed = isDashing ? dashSpeed : moveSpeed;

    // Apply gravity
    if (!isOnGround) {
      velocity.y += gravity * dt;
    }

    // Update vertical position
    position.y += velocity.y * dt;

    // Check for ground collision
    if (position.y >= groundLevel) {
      position.y = groundLevel;
      velocity.y = 0;
      isOnGround = true;
    }

    // Determine horizontal movement
    switch (playerDirection) {
      case CharacterDirection.left:
        if (isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = false;
        }
        directionX -= currentSpeed;
        break;
      case CharacterDirection.right:
        if (!isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = true;
        }
        directionX += currentSpeed;
        break;
      case CharacterDirection.none:
        // No horizontal movement
        break;
    }

    velocity.x = directionX;
    //position += velocity * dt;

    // Set animation state - priority: Bite > Kick > Dash > Jump > Move > Idle
    if (isBiting) {
      current = CharacterState.bite;
      if (animationTicker?.done() ?? false) {
        isBiting = false;
      }
    } else if (isKicking) {
      current = CharacterState.kick;
      if (animationTicker?.done() ?? false) {
        isKicking = false;
      }
    } else if (isDashing) { // Dash animation plays if Shift is held, regardless of arrow keys
      current = CharacterState.dash;
      if (playerDirection == CharacterDirection.none && isOnGround) {
        animationTicker?.currentIndex = 1;
      }
    } else if (!isOnGround) {
      current = CharacterState.move;
    } else if (playerDirection != CharacterDirection.none) {
      current = CharacterState.move;
    } else {
      current = CharacterState.idle;
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter) {
        isBiting = true;
      } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
        isKicking = true;
      }
    }

    isDashing = keysPressed.contains(LogicalKeyboardKey.shiftLeft) || keysPressed.contains(LogicalKeyboardKey.shiftRight);

    // Jump logic
    if (keysPressed.contains(LogicalKeyboardKey.space) && isOnGround) {
      velocity.y = -jumpSpeed;
      isOnGround = false;
    }

    return super.onKeyEvent(event, keysPressed);
  }
}




// CONSTANTS
class Constants {
  Constants._();

  static const String title = "Dino Flame";

  static final ThemeData theme = ThemeData.from(
    colorScheme: ColorScheme.light(
      primary: Color(0xFFFDF8F1),
    ),
    textTheme: GoogleFonts.bytesizedTextTheme(
      ThemeData.light().textTheme
    ),
    useMaterial3: true,
  );

  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'root',
        builder: (_, _) => Root(),
      ),
    ],
  );

  static const double width = 1280.0;
  static const double height = 720.0;

  static const double joystickSize = 100.0; // Define a suitable size for your joystick
  static const String joystickBackgroundImage = 'images/gamepad/background.png';
  static const String joystickKnobImage = 'images/gamepad/knob.png';

  static const String gamepadControlsImage = 'images/gamepad/controls.png';
}



// FUNCTIONS
class Functions {
  Functions._();

  static Future<void> setAppTitle(String label) async {
    Future.microtask(() {
      SystemChrome.setApplicationSwitcherDescription(
        ApplicationSwitcherDescription(
          label: label,
        )
      );
    });
  }

  static String backgroundImage(int index) {
    return 'images/backgrounds/parallax_$index.png';
  }

  static String characterImage(String name, String action) {
    return 'images/characters/$name/$action.png';
  }
}
