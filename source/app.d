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
    auto helpInformation = getopt(
        args,
        "i", "Select an input file",   &inPath,    // numeric
        "o", "Select an output file",  &outPath,      // string
    );

    if (helpInformation.helpWanted)
    {
      defaultGetoptPrinter("Huffman compressor v_0.0",
        helpInformation.options);
    }

    if(inPath !is null){
        write("Input = ");
        writeln(inPath);
    }

    //TEST

    auto freq = huffman.getFrequencyOfFile(inPath);
    Node testTree = huffman.Node.fromFrequency(freq);
    auto encoder = new Encoder(testTree);
    auto decoder = new Decoder(testTree);
    auto bytes = decoder.serialize();
    ubyte[] str = cast(ubyte[]) "small test";
    auto cf = CompressedFile.fromBytes(str, encoder, decoder);
    cf.writeToFile(outPath);//
}
