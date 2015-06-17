module parser;

import std.stdio;
import ast;
import token;

class Parser {
private:
    Token[] tokens;
    Node[] nodes;
    int position;

public:
    this(Token[] tokens) {
        this.tokens = tokens;
        this.position = 0;
    }

    Var parse_var() {
        if (match_content("var", 0)) {
            consume();

            if (match_type(TOKEN_IDENTIFIER, 0)) {
                string name = consume().get_content();

                Var v = new Var(name);

                if (match_content("=", 1)) {
                    writeln("todo var assignment!");
                }

                if (match_content(";", 0)) {
                    consume();
                } else {
                    writeln("error: missing semi-colon at the end of variable definition for `", name, "`");
                }

                return v;
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

                Func f = new Func(name);

                if (match_content("-", 0) && match_content(">", 1)) {
                    consume(); // eat -
                    consume(); // eat >

                    string[] params = parse_parameters();
                    f.set_params(params);
                }

                // block
                if (match_content("{", 0)) {
                    consume();

                    while (true) {
                        if (match_content("}", 0)) {
                            consume();
                            break;
                        }

                        // for now just consume it all
                        consume();

                        //Node n = parse_node();
                        //if (n !is null) {
                        //    f.append_node(n);
                        //}
                    }
                } 
                // prototype
                else if (match_content(";", 0)) {
                    f.set_prototype(true);
                }
                // ??
                else {
                    writeln("error: illegal token in function signature `", name, "`");
                }

                return f;
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
        while (position < tokens.length) {
            Node n = parse_node();
            if (n !is null) {
                nodes ~= n;
            }
        }
        foreach (i; 0 .. nodes.length) {
            writeln(nodes[i].to_string());
        }
    }
}