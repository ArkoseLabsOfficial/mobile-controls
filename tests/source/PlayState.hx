package;

#if flixel
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxColor;
import mobile.flixel.controls.MobileControls;
import mobile.flixel.screen.ScreenUtil;
#else
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.Lib;
import mobile.openfl.controls.MobileControls;
import mobile.openfl.screen.ScreenUtil;
#end

#if flixel
class PlayState extends FlxState {
#else
class PlayState extends Sprite {
#end

    var controls:MobileControls;
    
    #if flixel
    var statusText:FlxText;
    #else
    var statusText:TextField;
    #end
    
    var testsPassed:Int = 0;
    var testsFailed:Int = 0;

    #if !flixel
    public function new() {
        super();
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    function onAddedToStage(e:Event) {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        
        // OpenFL requires explicit init for ScreenUtil touch/swipe tracking
        ScreenUtil.init(stage);
        
        statusText = new TextField();
        statusText.x = 10;
        statusText.y = 10;
        statusText.width = stage.stageWidth - 20;
        statusText.height = stage.stageHeight - 20;
        statusText.defaultTextFormat = new TextFormat("_sans", 16, 0xFFFFFF);
        statusText.text = "Running Mobile Library Tests...\n";
        statusText.wordWrap = true;
        statusText.selectable = false;
        addChild(statusText);

        runDiagnostics();
        addEventListener(Event.ENTER_FRAME, update);
    }
    #else
    override public function create() {
        super.create();

        statusText = new FlxText(10, 10, FlxG.width - 20, "Running Mobile Library Tests...\n", 16);
        statusText.color = FlxColor.WHITE;
        add(statusText);

        runDiagnostics();
    }
    #end

    function runDiagnostics() {
        // 1. Test ScreenUtil
        try {
            var swipeExists = ScreenUtil.swipe != null;
            var touchExists = ScreenUtil.touch != null;
            assert(swipeExists && touchExists, "ScreenUtil initialized successfully");
        } catch(e:Dynamic) {
            assert(false, 'ScreenUtil failed: $e');
        }

        // 2. Test MobileControls Initialization
        try {
            #if flixel
            controls = new MobileControls();
            add(controls);
            #else
            // OpenFL version requires design dimensions
            controls = new MobileControls(1920, 1080);
            addChild(controls);
            #end

            controls.addButton("TEST");
            controls.addDPad("TEST");
            controls.addJoyStick("TEST");
            controls.addHitbox("TEST");
            assert(controls != null, "MobileControls instantiated and added to state");
        } catch(e:Dynamic) {
            assert(false, 'MobileControls init failed: $e');
        }

        // 3. Test Camera Setup (Flixel Only)
        #if flixel
        try {
            controls.addButtonCamera();
            controls.addDPadCamera();
            controls.addJoyStickCamera();
            controls.addHitboxCamera();
            assert(true, "Camera setup methods executed without crashing");
        } catch(e:Dynamic) {
            assert(false, 'Camera setup failed: $e');
        }
        #end

        // 4. Test State Fetching (Empty/Dummy)
        try {
            var check = controls.checkState("jump", "justPressed");
            assert(check == false, "checkState safely handles empty inputs");
        } catch(e:Dynamic) {
            assert(false, 'checkState failed: $e');
        }

        // Finish
        statusText.text += '\n==============================\n';
        if (testsFailed == 0) {
            statusText.text += 'SUCCESS: All $testsPassed tests passed! Library is stable.\n';
            
            #if flixel
            statusText.color = FlxColor.LIME;
            #else
            var fmt = statusText.defaultTextFormat;
            fmt.color = 0x00FF00;
            statusText.setTextFormat(fmt);
            #end
            
        } else {
            statusText.text += 'WARNING: $testsFailed tests failed. Check logs.\n';
            
            #if flixel
            statusText.color = FlxColor.RED;
            #else
            var fmt = statusText.defaultTextFormat;
            fmt.color = 0xFF0000;
            statusText.setTextFormat(fmt);
            #end
        }
    }

    function assert(condition:Bool, msg:String) {
        if (condition) {
            testsPassed++;
            statusText.text += '[PASS] ' + msg + '\n';
        } else {
            testsFailed++;
            statusText.text += '[FAIL] ' + msg + '\n';
        }
    }

    #if flixel
    override public function update(elapsed:Float) {
        super.update(elapsed);
        checkInputs();
    }
    #else
    function update(e:Event) {
        checkInputs();
    }
    #end

    // Kept separate so we don't have to duplicate the #if logic inside the loop
    function checkInputs() {
        if (ScreenUtil.touch.justPressed) {
            trace("Screen touched!");
        }
        if (controls.checkState("UP", "justPressed")) {
            trace("just pressed up");
        }
    }
}