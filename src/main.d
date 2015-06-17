import std.stdio;
import std.string;
import lexer;

string read_file(string file_name) {
    string source_file = "";
    File file = File(file_name, "r");
    while (!file.eof()) {
        string line = chomp(file.readln());
        source_file = source_file ~ line;
    }
    return source_file;
}

int main(string[] args) {
    if (args.length <= 1) {
        writeln("error: no input files");
        return -1;
    }

    auto lexer = new Lexer(read_file(args[1]));
    lexer.start();

    return 0;
}