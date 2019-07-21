import 'package:flutter/gestures.dart';
import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components/animation_component.dart';

var game;

const DRAGONSPEED = 20.0;
const DRAGON_SIZE = 40.0;
const BULLET_SPEED = 60.0;
const BULLET_SIZE = 20.0;
const ComponentSize = 40.0;
bool gameOver = false;

var points = 0;
Dragon dragon;
Bullet bullet;
Dragon component;

bool bulletStartStop = false;
double touchPositionDx = 0.0;
double touchPositionDy = 0.0;

main() async {
    Flame.audio.disableLog(); //why is this required?
    Flame.images.loadAll(['fire.png', 'dragon.png',
        'gun.png', 'bullet.png']);
    var dimensions = await Flame.util.initialDimensions();

    game = Galaxy(dimensions);

    runApp(MaterialApp(
        home:Scaffold(
            body: Container(
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                        image: new AssetImage("assets/images/background.jpg"),
                        fit: BoxFit.cover,
                    ),
                ),
                child:GameWrapper(game),
            )
        )
    ));
    HorizontalDragGestureRecognizer horizontalDragGestureRecognizer =
    new HorizontalDragGestureRecognizer();

    Flame.util.addGestureRecognizer(horizontalDragGestureRecognizer
        ..onUpdate = (startDetails) => game.dragInput(startDetails.globalPosition));

    Flame.util.addGestureRecognizer(new TapGestureRecognizer()
        ..onTapDown = (TapDownDetails evt) => game.tapInput(evt.globalPosition));

    // Adds onUP feature to fire bullets
    Flame.util.addGestureRecognizer(new TapGestureRecognizer()
        ..onTapUp = (TapUpDetails evt) => game.onUp(evt.globalPosition));
}

class GameWrapper extends StatelessWidget {
    //final MyGame game;
    final Galaxy game;
    GameWrapper(this.game);

    @override
    Widget build(BuildContext context) {
        return game.widget;
    }
}

class Dragon extends SpriteComponent {
    Size dimensions;
    int position;
    int yPosition;
    double maxY;
    bool explode = false;

    Dragon(this.dimensions, this.position, this.yPosition):
            super.square(ComponentSize, 'dragon.png');

    @override
    void update(double t) {
        y += gameOver ? 0: (t * DRAGONSPEED);
    }

    @override
    bool destroy() {
        if (explode) {
            return true;
        }

        if (y == null || maxY == null) {
            return false;
        }

        bool destroy = y >= maxY + DRAGON_SIZE / 2;
        if (destroy) {
            gameOver = true;
            print('Game Over');
            return true;
        }

        return destroy;
    }

    @override
    void resize(Size size) {
        this.x = DRAGON_SIZE * position;
        this.y = DRAGON_SIZE * yPosition;
        this.maxY = size.height;
    }
}


class Bullet extends SpriteComponent {
    bool explode = false;
    double maxY;

    List<Dragon> dragonList = <Dragon>[];
    List<Bullet> bulletList = <Bullet>[];
    Bullet(this.dragonList, this.bulletList):
            super.square(BULLET_SIZE, 'gun.png');

    @override
    void update(double t) {
        y -= gameOver ? 0: t * BULLET_SPEED;

        if (dragonList.isNotEmpty)
            dragonList.forEach((dragon) {
                bool remove = this.toRect().contains(dragon.toRect().bottomCenter) ||
                        this.toRect().contains(dragon.toRect().bottomLeft) ||
                        this.toRect().contains(dragon.toRect().bottomRight);

                if (remove) {
                    points++;
                    dragon.explode = true;
                    this.explode = true;
                    dragonList.remove(dragon);

                    game.add(new Explosion(dragon));

                }
            });
    }

    @override
    bool destroy() {
        if (explode) {
            return true;
        }
        if (y == null || maxY == null) {
            return false;
        }

        return y >= maxY;
    }

    @override
    void resize(Size size) {
        this.x = touchPositionDx;
        this.y = touchPositionDy;
        this.maxY = size.height;
    }

}


class MyGame extends BaseGame {
    Size dimensions;
    MyGame(this.dimensions);
    double creationTimer = 0.0;

    @override
    void render(Canvas canvas) {
        super.render(canvas);
        String text = "Score: 0";
        TextPainter textPainter = 
            Flame.util.text(text, color: Colors.white, fontSize: 32.0);
        textPainter.paint(canvas, Offset(size.width / 3, size.height - 50));
    }

    @override
    void update(double t) {
        creationTimer += t;
        if(creationTimer >= 4) {
            creationTimer = 0.0;
            component = new Dragon(dimensions, 0, 0);
            add(component);
        }
        super.update(t);

    }
}

class Galaxy extends BaseGame {
    bool checkOnce = true;
    double creationTimer = 0.0;

    List<Dragon> dragonList = <Dragon>[];
    List<Bullet> bulletList = <Bullet>[];

    Size dimensions;

    Galaxy(this.dimensions);

    @override
    void render(Canvas canvas) {
        super.render(canvas);

        String text = points.toString();
        TextPainter p = Flame.util.text(text,
            color: Colors.white, fontSize: 48.0, fontFamily: 'Halo');

        String over = "Game Over";

        TextPainter overGame = Flame.util.text(over,
            color: Colors.white, fontSize: 48.0, fontFamily: 'Halo');

        if (gameOver) {
            overGame.paint(canvas, Offset(size.width/5, size.height/2));
        } else {
            p.paint(canvas,
                new Offset(size.width - p.width - 10,
                    size.height - p.height - 10));
        }
    }

    @override
    void update(double t) {
        creationTimer += t;
        if (creationTimer >= 4) {
            creationTimer = 0.0;

            for (int i = 1; i <= DRAGON_SIZE / 7; i++) {
                for (int j = 0; j < i; ++j) {
                    dragon = new Dragon(dimensions, i, j);
                    dragonList.add(dragon);
                    add(dragon);

                }
            }
        }
        super.update(t);
    }

    void tapInput(Offset position) {
        touchPositionDx = position.dx;
        touchPositionDy = position.dy;

        bulletStartStop = true;
        bulletList.add(bullet);
        bullet = new Bullet(dragonList, bulletList);
        add(bullet);
    }

    void dragInput(Offset position) {
        touchPositionDx = position.dx;
        touchPositionDy = position.dy;
        bulletStartStop = true;
    }

    void onUp() {
        bulletStartStop = false;
    }
}

class Explosion extends AnimationComponent {
    static const TIME = 0.75;

    Explosion(Dragon dragon)
        : super.sequenced(DRAGON_SIZE, DRAGON_SIZE, 'explosion-0.png', 7,
        textureWidth: 31.0, textureHeight: 31.0) {
        this.x = dragon.x;
        this.y = dragon.y;
        this.animation.stepTime = TIME / 7;
    }

    bool destroy() {
        return this.animation.isLastFrame;
    }
}
