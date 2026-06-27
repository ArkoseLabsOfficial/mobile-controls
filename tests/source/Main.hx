package;

#if flixel
import flixel.FlxGame;
#end
import openfl.display.Sprite;

class Main extends Sprite {
    public function new() {
        super();
        addChild(#if flixel new FlxGame(1920, 1080, PlayState, 60, 60, true, false) #else new PlayState() #end);
    }
}