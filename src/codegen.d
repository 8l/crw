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
    string source_code;

public:
    this(Node[] nodes) {
        this.nodes = nodes;
    }

    void compile() {
        system(std.string.toStringz("cc __gen_file.c"));
        remove("__gen_file.c");
    }

    void make_file() {
        auto file = File("__gen_file.c", "w");
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