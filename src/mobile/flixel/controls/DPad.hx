package mobile.flixel.controls;

#if flixel
class DPad extends InputHandler {
    public var controlIDs:Array<String> = [];

    public function new(data:Dynamic) {
        var posX:Float = data.position != null ? data.position[0] : 0;
        var posY:Float = data.position != null ? data.position[1] : 0;
        super(posX, posY, data.showbounds == true);

        controlIDs = data.id;
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

        loadElementGraphics(tex, subTex, data.spritesheet, Config.DPAD_PATH, data.color, scale);

        var relMidX = baseGraphic.width / 2;
        var relMidY = baseGraphic.height / 2;
        var offsets = data.offset != null ? data.offset : data.clickposition;
        var hitboxesD = data.hitbox != null ? data.hitbox : data.clickbound;

        if (offsets != null && hitboxesD != null) {
            for (i in 0...controlIDs.length) {
                var cPos:Array<Float> = offsets[i];
                var cBnd:Array<Int> = hitboxesD[i];

                var relBoundX = relMidX + cPos[0] - (cBnd[0] / 2);
                var relBoundY = relMidY + cPos[1] - (cBnd[1] / 2);

                createBoundHitbox(relBoundX, relBoundY, cBnd[0], cBnd[1]);
            }
        }
        jsonName = data.name;
    }

    override public function updateInputs() {
        var anyPressed = false;
        for (i in 0...hitboxes.length) {
            var box = hitboxes[i];
            var isPressed = checkOverlap(box);

            if (isPressed) {
                activeIDs.push(controlIDs[i]);
                anyPressed = true;
            }

            updateBoundBrightness(box, isPressed);
        }

        applyBrightness(anyPressed);
    }
}
#end