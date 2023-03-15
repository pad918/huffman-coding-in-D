import std.stdio;
import std.string;
import std.array;
import std.conv;
import std.algorithm;
import std.file;
import std.getopt;
import huffman;
import test;
import bench;


void main(string[] args)
{
    //bench.bench();
    string inPath, outPath;
    bool encode=false, decode=false;
    auto helpInformation = getopt(
        args,
        "i", "Select an input file",    &inPath,    // numeric
        "o", "Select an output file",   &outPath,      // string
        "encode", "encode input file",  &encode,      // string
        "decode", "decode input file",  &decode,      // string
    );

    if (helpInformation.helpWanted)
    {
      defaultGetoptPrinter("Huffman compressor v_0.0",
        helpInformation.options);
    }

    if(encode && decode){
        printf("Can not encode and decode at the same time\n");
        return;
    }
    else if(!encode && !decode){
        printf("Use -encode or -decode\n");
        return;
    }

    if(encode){
        auto freq = huffman.getFrequencyOfFile(inPath);
        Node testTree = huffman.Node.fromFrequency(freq);
        auto encoder = new Encoder(testTree);
        auto decoder = new Decoder(testTree);
        auto str = cast(ubyte[]) std.file.read(inPath);
        auto cf = CompressedFile.fromBytes(str, encoder, decoder);
        cf.writeToFile(outPath);
        auto inSize = std.file.getSize(inPath);
        auto outSize = std.file.getSize(outPath);
        float compressionRatio = 1.0f-(cast(float)outSize/cast(float)inSize);
        printf("Compressed %s by %.1f%%", toStringz(inPath), 100.0*compressionRatio);
    }

    //Slow copy...
    else if(decode){
        auto cf = CompressedFile.fromFile(inPath);
        auto uncompressed = cf.uncompress();
        ubyte[] copy = new ubyte[uncompressed.length];
        int i=0;
        foreach (uint b; uncompressed)
        {
            copy[i++] = cast(ubyte)b;
        } 
        std.file.write(outPath, copy);
    }

}
