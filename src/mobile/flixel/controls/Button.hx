package mobile.flixel.controls;

#if flixel
class Button extends InputHandler {
    public var controlID:String;

    public function new(data:Dynamic) {
        var posX:Float = data.position != null ? data.position[0] : 0;
        var posY:Float = data.position != null ? data.position[1] : 0;
        super(posX, posY, false);
        jsonName = data.name;

        controlID = data.id;
        var scale:Float = data.scale != null ? data.scale : 1.0;
        var tex:String = data.texture != null ? data.texture : data.graphic;
        var subTex:String = null;

        if (data.subgraphic != null) {
            subTex = data.subgraphic.texture != null ? data.subgraphic.texture : data.subgraphic;
            if (data.subgraphic.position != null) {
                subOffsetX = data.subgraphic.position[0];
                subOffsetY = data.subgraphic.position[1];
            }
            if (data.subgraphic.scale != null) {
                subScale = data.subgraphic.scale;
            }
        }

        loadElementGraphics(tex, subTex, data.spritesheet, Config.BUTTON_PATH, data.color, scale);
    }

    override public function updateInputs() {
        if (checkOverlap(baseGraphic)) {
            activeIDs.push(controlID);
        }
        applyBrightness(activeIDs.length > 0);
    }
}
#end