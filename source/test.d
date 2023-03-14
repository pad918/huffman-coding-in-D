module test;

import std.conv;
import std.file;
import std.algorithm;
import std.stdio;
import huffman;

void testBitList(){
    BitList list = new BitList();
    for(int B = 0; B<256; B++){
        for(int i=0; i<8; i++)
            list.setNext(((B>>i)&1)!=0);
    }

    //Read the bits back
    for(int B=0; B<256; B++){
        int b=0;
        for(int i=0; i<8; i++)
            b |= list.getBit(B*8+i)<<i;
        assert(b==B);
    }
    printf("Passed bitlist test\n");

}

void simpleTest(){
    for(int i=0; i<17; i++){
        BitList list = new BitList();
        list.setBit(true, i);
        int k = list.getBit(i);
        assert(k==1);
    }
    printf("Passed simple bitlist test\n");
}
