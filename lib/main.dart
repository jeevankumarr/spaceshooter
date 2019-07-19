import 'package:flutter/gestures.dart';
import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
var game;

main() async {
    Flame.images.loadAll(['fire.png', 'dragon.png',
        'gun.png', 'bullet.png']);
    var dimensions = await Flame.util.initialDimensions();

    game = MyGame(dimensions);

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

//    Flame.util.addGestureRecognizer(horizontalDragGestureRecognizer
//        ..onUpdate = (startDetails) => game.dragInput(startDetails.globalPosition));
//
//    Flame.util.addGestureRecognizer(new TapGestureRecognizer()
//        ..onTapDown = (TapDownDetails evt) => game.tapInput(evt.globalPosition));
//
//    // Adds onUP feature to fire bullets
//    Flame.util.addGestureRecognizer(new TapGestureRecognizer()
//        ..onTapUp = (TapUpDetails evt) => game.onUp(evt.globalPosition));
}

class GameWrapper extends StatelessWidget {
    final MyGame game;
    GameWrapper(this.game);
    @override
    Widget build(BuildContext context) {
        return game.widget;
    }
}

const SPEED = 120.0;
const ComponentSize = 40.0;

class Component extends SpriteComponent {
    Size dimensions;
    Component(this.dimensions): super.square(ComponentSize, 'dragon.png');
    double maxY;
    bool remove = false;

    @override
    void update(double t) {
        y += t * SPEED;
    }

    @override
    bool destroy() {
        return remove;
    }

    @override
    void resize(Size size) {
        this.x = size.width / 2;
        this.y = 0;
        this.maxY = size.height;
    }
}

Component component;

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
            component = new Component(dimensions);
            add(component);
        }
        super.update(t);

    }
}

