import std.stdio;
import std.string;

import lexer;
import parser;
import codegen;

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
    if (args.length <= 2) {
        writeln("error: no input files\nusage: ./main build file.crw");
        return -1;
    }

    string flag_arg = args[1];
    string file_name = args[2];

    int flag = COMPILE_C;
    switch (flag_arg) {
        case "build": flag = COMPILE_C; break;
        case "debug": flag = LOG_C; break;
        default:
            writeln("unknown command ", flag_arg);
            return -1;
    }

    auto lexer = new Lexer(read_file(file_name));
    lexer.start();

    auto parser = new Parser(lexer.get_tokens());
    parser.start();

    auto gen = new Codegen(parser.get_ast());
    gen.start(flag);

    return 0;
}