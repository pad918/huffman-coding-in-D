module bench;
import std.file;
import std.datetime;
import std.datetime.stopwatch : benchmark, StopWatch;
import std.stdio;
import core.time;
import std.conv;
import huffman;

long[] bench_file(string fileName){
    //Create encoder/decoder

    auto freq = huffman.getFrequencyOfFile(fileName);
    Node testTree = huffman.Node.fromFrequency(freq);
    auto encoder = new Encoder(testTree);
    auto decoder = new Decoder(testTree);

    long[] times = [0, 0];
    auto toEncode = cast(ubyte[]) std.file.read(fileName);
    auto sw = StopWatch();
    sw.stop(); sw.reset();
    sw.start();
    BitList encoded;
    encoded = encoder.encode(toEncode);
    sw.stop();
    times[0] = sw.peek.total!"msecs";
    sw.reset();
    sw.start();
    auto decodedText = decoder.decode(encoded);
    sw.stop();

    writefln("Length of decoded text: (bytes): " ~ to!string(decodedText.length()));
    float compressionRatio = 1.0 - ((encoded.bit/8)/cast(float)decodedText.length());
    printf("Compression ratio = %f %%\n", 100.0f*compressionRatio);

    times[1] = sw.peek.total!"msecs";
    return times; 
}

void bench(){
    string[] files = ["source/app.d", "dlang.html", "C:/Users/Mans/Downloads/helloworld.wav"]; //, "C:/Users/Mans/Downloads/cpu-z_2.05-en.exe"];
    foreach (string file; files)
    {
        long[] time = bench_file(file);
        write("File: " ~ file ~ " | ");
        printf("enc time: ");
        write(time[0]);
        printf("ms | dec time: ");
        write(time[1]);
        printf("ms\n");
    }
}

/*
    Decode Speed: 418kB in 331ms ==> 1.3 MB/s decoding speed
    Encode Speed: 418kB in  70ms ==> 6.0 MB/s encoding speed

    helloworld.wav:
    Decode Speed: 9.2MB in 5612ms ==> 1.6 MB/s decoding speed
    Encode Speed: 9.2MB in 1240ms ==> 7.4 MB/s encoding speed

*/