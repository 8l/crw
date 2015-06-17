module codegen;

import std.stdio;

import ast;

class Codegen {
private:
    Node[] nodes;
    string source_code;

public:
    this(Node[] nodes) {
        this.nodes = nodes;
    }

    void start() {
        foreach (i; 0 .. nodes.length) {
            source_code ~= nodes[i].codegen();
        }

        writeln("generated source file\n", source_code);
    }
}