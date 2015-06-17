module codegen;

import std.stdio;
import std.process;
import std.string;

import ast;

enum {
    LOG_C,
    COMPILE_C
}

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

    void start(int flag) {
        foreach (i; 0 .. nodes.length) {
            source_code ~= nodes[i].codegen();
        }

        switch (flag) {
            case LOG_C:
                writeln(source_code);
                break;
            case COMPILE_C:
                make_file();
                compile();
                break;
            default:
                writeln("error: unknown option ", flag);
                break;
        }
    }
}