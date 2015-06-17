module codegen;

import std.stdio;
import std.process;

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

        // writeln("generated source file\n", source_code);
        auto file = File("__gen_file_.c", "w");
        file.writeln(source_code);
        file.close();

        auto pid = spawnShell("cc __gen_file.c -o main");

        scope(exit) {
            auto exit_code = wait(pid);
            writeln("exited with ", exit_code);
        }
    }
}