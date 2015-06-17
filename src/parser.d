module parser;

import std.stdio;
import ast;
import token;

class Parser {
private:
    Token[] tokens;
    Node[] nodes;
    bool running;
    int position;

public:
    this(Token[] tokens) {
        this.tokens = tokens;
        this.position = 0;
        this.running = true;
    }

    Var parse_var() {
        if (match_content("var", 0)) {
            consume();

            if (match_type(TOKEN_IDENTIFIER, 0)) {
                string name = consume().get_content();

                if (match_content("=", 1)) {
                    writeln("todo var assignment!");
                } else {
                    writeln("var node with name ", name);
                }

                if (match_content(";", 0)) {
                    consume();
                } else {
                    writeln("error: missing semi-colon at the end of variable definition for `", name, "`");
                }

                return new Var(name);
            }
        }

        return null;
    }

    string[] parse_parameters() {
        string[] params;

        while (true) {
            if (match_type(TOKEN_IDENTIFIER, 0)) {
                string res = consume().get_content();
                params ~= res;

                if (match_content(",", 0)) {
                    consume();
                } else {
                    break;
                }
            }
        }

        return params;
    }

    Func parse_func() {
        if (match_content("func", 0)) {
            consume();

            if (match_type(TOKEN_IDENTIFIER, 0)) {
                string name = consume().get_content();

                if (match_content("-", 0) && match_content(">", 1)) {
                    consume(); // eat -
                    consume(); // eat >

                    string[] params = parse_parameters();
                    foreach (i; 0 .. params.length) {
                        writeln("param: ", params[i]);
                    }

                    // block
                    if (match_content("{", 0)) {

                    } 
                    // prototype
                    else {

                    }
                } else {
                    writeln("no parameters");
                }
            }
        }

        return null;
    }

    Node parse_node() {
        Var v = parse_var();
        if (v !is null) {
            return v;
        }

        Func f = parse_func();
        if (f !is null) {
            return f;
        }

        return null;
    }

    Token consume() {
        return this.tokens[position++];
    }

    bool match_content(string content, int offset) {
        return tokens[position + offset].get_content() == content;
    }

    bool match_type(int type, int offset) {
        return tokens[position + offset].get_type() == type;
    }

    void start() {
        while (running) {
            Node n = parse_node();
            if (n !is null) {
                nodes ~= n;
            }
        }
    }
}