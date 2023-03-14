module huffman;

import std.conv;
import std.file;
import std.algorithm;
import std.stdio;
import std.container;

class Node
{
    bool isSymbol = false;
    ubyte symbol;
    int freq = 0;
    Node left;
    Node right; 

    this(){}

    this(bool isSymbol, ubyte symbol, int freq){
        this.symbol = symbol;
        this.isSymbol = isSymbol;
        this.freq = freq;
    }

    string toStr(){
        string l  = left?left.toStr:"null";
        string r = right?right.toStr:"null";
        return "[" ~ to!string(isSymbol) ~ ", " ~ to!string(symbol) ~ ", " ~ to!string(freq) ~ "]" ~ 
            ": {" ~ l ~ "} {" ~ r ~ "}";
    }
}

class BitList{
    ubyte[] bytes;
    int bit = 0;
    void setBit(bool value, int pos){
        int bytePos = pos>>3;
        int bitPos = pos&7;
        if(bytePos>=bytes.length)
            bytes.length *= 2;
        ubyte b = bytes[bytePos];
        b &= ~(1<<bitPos);
        b |= (value?1:0) << bitPos;
        bytes[bytePos] = b;
    }
    void setNext(bool value){
        setBit(value, bit++);
    }
    ubyte getBit(int pos){
        int bytePos = pos>>3;
        int bitPos = pos&7;
        return (bytes[bytePos] >> bitPos) & 1;
    }
    this(){
        bytes.length = 2;
    }
    BitList copy(){
        BitList l = new BitList;
        l.bytes = this.bytes.dup;
        l.bit = this.bit;
        return l;
    }
    BitList moveAndCopy(int dir){
        assert(dir<=1 && dir>=0);
        BitList l = new BitList;
        l.bytes = this.bytes.dup;
        l.bit = this.bit;
        l.setNext(dir==1);
        return l; 
    }

    void append(BitList l){
        for(int i=0; i<l.bit; ++i)
            setNext(l.getBit(i)!=0);
    }


    //Overrides
    override string toString() const @safe pure nothrow 
    {
        string str = to!string(bit) ~ " ";
        foreach (b; bytes)
        {
            string binary_byte = "";
            for(int i=0; i<8; i++)
                binary_byte ~= to!string((b>>i)&1);
            str ~= binary_byte;
        }
        return str;
    }

    override bool opEquals(Object o) const {
        if(typeof(o).stringof=="BitList")
            return false;
        BitList l = cast(BitList)o;
        if(l.bit!=this.bit){
            return false;
        }
        //Compare all bytes
        for(int i=0; i<bytes.length; ++i){
            if(this.bytes[i] != l.bytes[i])
                return false;
        }
        return true;
    }

    override size_t toHash() const { 
        size_t hash = 0; //assume 4 byte long (not true on 64 bit systems!)
        int i=0;
        foreach (ubyte b; bytes)
        {
            hash ^= b << (i&4);
            i++;
        }
        return hash;
    }
}

int[ubyte] frequency(ubyte[] arr){
    int[ubyte] f = new int[ubyte];
    foreach (c; arr)
    {
        if(c in f)
            f[c] = f[c]+1;
        else
            f[c] = 1;
    }
    return f;
} 

int[ubyte] getFrequencyOfFile(string filePath){
    ubyte[]  file = cast(ubyte[]) std.file.read(filePath);
    return frequency(file);
}

Node getHuffmanTree(int[ubyte] freq){
    //Create list of nodes from freq:
    
    Node[] nodes = new Node[freq.length];
    int i=0;
    foreach (key; freq.byKey())
    {
        nodes[i] = new Node(true, key, freq[key]);
        ++i;
    }

    // Put together until one huffman tree is constructed:
    auto sorted = nodes.sort!("a.freq < b.freq");
    
    while(sorted.length>1){
        //Merge 0 and 1
        Node newNode  = new Node(false, 0, sorted[0].freq + sorted[1].freq);
        newNode.left  = sorted[0];
        newNode.right = sorted[1];
        sorted.popFront();
        sorted[0] = newNode;
        //Sort (can be done in a better way!)
        sorted = sorted.sort!("a.freq < b.freq");
    }

    return sorted[0];
}

class Encoder{
    BitList[int] encodeMap;

    this(Node huffmanTree){
        encodeMap = createEncodeMap(huffmanTree, new BitList);
    }

    //Slow
    BitList[int] createEncodeMap(Node huffmanTree, BitList list){
        auto map = new BitList[int];

        //Find all symbols in tree and add them
        if(huffmanTree.left !is null){
            auto leftSymbols = createEncodeMap(huffmanTree.left, list.moveAndCopy(1));
            //Add to map
            foreach(key; leftSymbols.byKey()){
                map[key] = leftSymbols[key];
            }
        }

        if(huffmanTree.right !is null){
            auto rightSymbols = createEncodeMap(huffmanTree.right, list.moveAndCopy(0)); //<--- Alltid här
            //Add to map
            foreach(key; rightSymbols.byKey()){
                map[key] = rightSymbols[key];
            }
        }

        // Add current if it is a symbol:
        if(huffmanTree.isSymbol){
            map[huffmanTree.symbol] = list;
        }
        return map;
    }

    BitList encode(int symblos){
        assert(encodeMap !is null);
        return encodeMap[symblos];
    }

    BitList encode(string symblos){
        assert(encodeMap !is null);
        BitList encoded = new BitList();
        foreach (s; symblos)
        {
            encoded.append(encodeMap[cast(int)s]);
        }
        return encoded;
    }
    
}

class Decoder{
    int[BitList] decodeMap;

    this(Node huffmanTree){
        decodeMap = createDecodeMap(huffmanTree, new BitList());
    }

    int[BitList] createDecodeMap(Node huffmanTree, BitList list){
        auto map = new int[BitList];

        //Find all symbols in tree and add them
        if(huffmanTree.left !is null){
            auto leftSymbols = createDecodeMap(huffmanTree.left, list.moveAndCopy(1));
            //Add to map
            foreach(key; leftSymbols.byKey()){
                map[key] = leftSymbols[key];
            }
        }

        if(huffmanTree.right !is null){
            auto rightSymbols = createDecodeMap(huffmanTree.right, list.moveAndCopy(0)); //<--- Alltid här
            //Add to map
            foreach(key; rightSymbols.byKey()){
                map[key] = rightSymbols[key];
            }
        }

        // Add current if it is a symbol:
        if(huffmanTree.isSymbol){
            map[list] = huffmanTree.symbol;
        }
        return map;
    }

    Array!int decode(BitList encoded){
        Array!int symbols = Array!int();
        //Decode all symbols
        int i=0;
        BitList run = new BitList; 
        while(i<encoded.bit){
            run.setNext(encoded.getBit(i++)!=0);
            //test if symbols has been found:
            if(run in decodeMap){
                symbols.insertBack(decodeMap[run]);
                run = new BitList(); // Should reset it to reduce memory usage
            }
        }

        return symbols;
    }

}

