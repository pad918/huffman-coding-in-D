import std.stdio;
import std.string;
import std.array;
import std.conv;
import std.algorithm;
import huffman;
import test;


void main()
{
    //simpleTest();
    //testBitList();
    
    

    
    auto freq = huffman.getFrequencyOfFile("dlang.html");
    printf("Fungerar!\n");
    //writeln(freq);

    Node testTree = huffman.getHuffmanTree(freq);
    //writeln(testTree.toStr);
    auto encoder = new Encoder(testTree);
    writeln(encoder);
    auto a = "Wikipedia is a good source of information!";
    BitList enc = encoder.encode(a);
    printf("Total encoded string: \n");
    writeln(enc.toString());
    auto decoder = new Decoder(testTree);
    auto symbols = decoder.decode(enc);
    printf("Decoded text:\n");
    
    symbols.each!(a => write(to!string(cast(char)a)));
    
}
