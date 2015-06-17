module codegen;

import std.stdio;
import std.process;
import std.string;

import ast;

// fuck off C
extern (C) int system(const char *str);

class Codegen {
private:
    Node[] nodes;
    string file_name;
    string source_code;

public:
    this(Node[] nodes) {
        this.nodes = nodes;
        this.file_name = "__gen_filename.c";
    }

    void compile() {
        system(std.string.toStringz("cc " ~ file_name));
        remove(std.string.toStringz(file_name));
    }

    void make_file() {
        auto file = File(file_name, "w");
        file.writeln(source_code);
        file.close();
    }

    void start() {
        foreach (i; 0 .. nodes.length) {
            source_code ~= nodes[i].codegen();
        }

        make_file();
        compile();
    }
}