import haxe.io.Path;

//The class that does the work for the asset packing and unpacking 
//doesn't have any dependencies, it uses plain haxe features.
//If you want to use this in any haxe project, you can customize
//the types in the AssetPack easily and the rest will still work automatically.

//The asset packs generated by the tool (written in luxe) will work
//for frameworks or code not using luxe, but the asset unpacking simply 
//undoes the packing / compression, you have to feed that to your framework
//as needed!

/*
var to_pack:AssetPack = {
    bytes: ..
    ...
}
var bytes = Packer.compress_pack(to_pack);
var unpacked = Packer.uncompress_pack(bytes);

for(item in unpacked.bytes) {
    ..
}
*/


typedef AssetItem = {
    var id: String;
    var bytes:haxe.io.Bytes;
}

typedef AssetPack = {
    var id:         String;
    var bytes:      Map<String, AssetItem>;
    var texts:      Map<String, AssetItem>;
    var jsons:      Map<String, AssetItem>;
    var textures:   Map<String, AssetItem>;
    var shaders:    Map<String, AssetItem>;
    var fonts:      Map<String, AssetItem>;
    var sounds:     Map<String, AssetItem>;
}

class Packer {

    public static var use_zip = true;

    public static function compress_pack( pack:AssetPack ) : haxe.io.Bytes {

        var s = new haxe.Serializer();
            s.serialize( pack );

        var raw = s.toString();
        var finalbytes = haxe.io.Bytes.ofString(raw);
        var presize = finalbytes.length;

        if(use_zip) {

            finalbytes = haxe.zip.Compress.run(finalbytes, 9);

        }

        var postsize = finalbytes.length;

        trace('${pack.id}: packed ${Pack.count(pack)} items / before:$presize / after:$postsize');

        return finalbytes;

    } //compress_pack

    public static function uncompress_pack( bytes:haxe.io.Bytes ) : AssetPack {

        var inputbytes = bytes;
        var presize = bytes.length;

        if(use_zip) {

            inputbytes = haxe.zip.Uncompress.run(inputbytes);

        }

        var uraw = inputbytes.toString();
        var u = new haxe.Unserializer( uraw );
        var pack : AssetPack = u.unserialize();

        var postsize = inputbytes.length;

        trace('${pack.id}: unpacked ${Pack.count(pack)} items / before:$presize / after:$postsize');

        return pack;

    } //uncompress_pack

} //Packer

