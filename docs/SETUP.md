# INSTALLATION

For stable versions, use this

```
haxelib install mobile-controls
```

For unstable versions however, use this

```
haxelib git mobile-controls https://github.com/KralOyuncu2010x/mobile-controls
```

Once this is done, go to your Project File, whether that be a build.hxml for Haxe Projects, or Project.xml for OpenFL and Flixel projects, and add `mobile-controls` to your libraries

---

# SETUP IN HAXE PROJECTS

### Haxe Project Example
```hxml
--library mobile-controls
# this is optional and can be added if wanted to use File instead of Assets
-D mobile_controls_file_support
```

### OpenFL / Flixel Project Example

```xml
<haxelib name="mobile-controls"/>
<haxedef name="mobile_controls_file_support"/>
```