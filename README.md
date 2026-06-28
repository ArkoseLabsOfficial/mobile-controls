# Mobile Controls

---

a library made to make the process of adding a mobile controls way easier.

---

- [Setup](https://github.com/ArkoseLabsOfficial/mobile-controls/blob/main/docs/SETUP.md)
- [Features](https://github.com/ArkoseLabsOfficial/mobile-controls/blob/main/docs/FEATURES.md)
- [Usage](#usage)

---

# USAGE

Creating & Handling a mobile controls should be fairly easy and very much self-explanatory. since everything is driven by JSON now, you just need to tell it which file to load

- NOTE: Because the library now checks states dynamically across all inputs, handling DPads, Hitboxes, and Joysticks is basically exactly the same!

HaxeFlixel Example:
```haxe
// *
// * src/PlayState.hx
// *

import flixel.FlxState;
import mobile.flixel.controls.MobileControls;

class PlayState extends FlxState {
    public static var instance:PlayState;
    public var manager:MobileControls;

    public function new() {
        super();
        instance = this;
    }

    override function create() {
        super.create();

        /* Manager Setup */
        manager = new MobileControls();
        add(manager);

        /* DPad Setup */
        manager.addDPad('my_dpad_data');
        manager.addDPadCamera(); // optional, renders it on top of the game

        /* Hitbox Setup */
        manager.addHitbox('my_hitbox_data');
        manager.addHitboxCamera();

        /* JoyStick & Button Setup */
        manager.addButton('my_button_data');
        manager.addJoyStick('my_joystick_data');
        // manager.addJoyStickCamera();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        // checking states is super easy now, it checks all active controls for the ID
        if (manager.checkState('A', 'justPressed')) {
            trace('hello from button A');
        }

        if (manager.checkState('up', 'pressed')) {
            trace('hello from holding up (works on dpad, hitbox, OR joystick!)');
        }
        
        if (manager.checkState('B', 'released')) {
            trace('goodbye from button B');
        }
    }
}
```

Pure OpenFL Example:
```haxe
// *
// * src/Main.hx
// *

import openfl.display.Sprite;
import openfl.events.Event;
import mobile.openfl.controls.MobileControls;
import mobile.openfl.screen.ScreenUtil;

class Main extends Sprite {
    public static var manager:MobileControls;

    public function new() {
        super();
        addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    function init(e:Event) {
        removeEventListener(Event.ADDED_TO_STAGE, init);
        
        // Init screen touch events first
        ScreenUtil.init(stage);

        /* Manager Setup (Pass in your design width & height for scaling) */
        manager = new MobileControls(1280, 720);
        addChild(manager);

        /* Setup controls from JSON */
        manager.addDPad('my_dpad_data');
        manager.addHitbox('my_hitbox_data');
        manager.addButton('my_button_data');
        manager.addJoyStick('my_joystick_data');

        addEventListener(Event.ENTER_FRAME, onUpdate);
    }

    function onUpdate(e:Event) {
        // works exactly the same as the flixel version!
        if (manager.checkState('A', 'justPressed')) {
            trace('hello from button A');
        }

        if (manager.checkState('up', 'pressed')) {
            trace('holding up!');
        }
    }
}
```

Wrapper Example:

Because of the new checkState function, making a custom wrapper for your game is much shorter than it used to be.
```haxe
// *
// * An Example Controls Wrapper
// * src/Controls.hx
// *

class Controls {
    public var LEFT(get, never):Bool;
    public var RIGHT(get, never):Bool;
    public var UP(get, never):Bool;
    public var DOWN(get, never):Bool;

    public function new() {}

    // the new checkState handles checking everything for you automatically!
    public function get_LEFT() return justPressed('left');
    public function get_RIGHT() return justPressed('right');
    public function get_UP() return justPressed('up');
    public function get_DOWN() return justPressed('down');

    public function justPressed(keyName:String) {
        return #if flixel requestedManager.checkState(keyName, 'justPressed') || #end Main.manager.checkState(keyName, "justPressed");
    }

    public function pressed(keyName:String) {
        return #if flixel requestedManager.checkState(keyName, 'pressed') || #end Main.manager.checkState(keyName, "pressed");
    }
    
    public function released(keyName:String) {
        return #if flixel requestedManager.checkState(keyName, 'justReleased') || #end Main.manager.checkState(keyName, "justReleased");
    }

	#if flixel
    public var requestedManager(get, default):Dynamic;
    @:noCompletion
    private function get_requestedManager():Dynamic
    {
        // replace this with wherever you store your MobileControls instance
        return PlayState.instance.manager;
    }
	#end
}
```