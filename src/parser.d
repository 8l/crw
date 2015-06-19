module parser;

import std.stdio;
import std.typecons;
import std.conv;

import ast;
import token;

class Parser {
private:
    Token[] tokens;
    Node[] nodes;
    int[string] precedence;
    bool[string] types;
    bool[string] functions;
    int position;

public:
    this(Token[] tokens) {
        this.tokens = tokens;
        this.position = 0;

        types["int"] = true;
        types["double"] = true;
        types["float"] = true;
        types["string"] = true;
        types["char"] = true;
        types["void"] = true;

        precedence["++"] = 11;
        precedence["--"] = 11;
        precedence["!"] = 11;
        precedence["~"] = 11;

        precedence["."] = 10;

        precedence["*"] = 9;
        precedence["/"] = 9;
        precedence["%"] = 9;

        precedence["+"] = 8;
        precedence["-"] = 8;

        precedence[">"] = 7;
        precedence["<"] = 7;
        precedence[">="] = 7;
        precedence["<="] = 7;

        precedence["=="] = 6;
        precedence["!="] = 6;

        precedence["&"] = 5;
        precedence["|"] = 4;
        precedence["&&"] = 3;
        precedence["||"] = 2;
        precedence["="] = 1;
    }

    Var parse_var() {
        if (peek(0).get_content() in types) {
            string type = consume().get_content();

            if (match_type(TOKEN_IDENTIFIER, 0)) {
                string name = consume().get_content();

                Var v = new Var(name, type);

                if (match_content("=", 0)) {
                    consume();

                    Expr expr = parse_expr();
                    if (expr !is null) {
                        v.set_value(expr);
                    } else {
                        writeln("expected expression after assignment operator for `", name, "`");
                    }
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

    Type parse_type() {
        if (match_content("type", 0)) {
            consume();

            if (match_type(TOKEN_IDENTIFIER, 0)) {
                string name = consume().get_content();

                // store the type as a function constructor, add 
                // a shit load of mangledness so it's unlikely anyone
                // would replicate this with an actual function
                auto type_ctor_mangled = "__T_" ~ to!string(name.length) ~ "_" ~ name ~ "_type_ctor";
                functions[type_ctor_mangled] = true;
                writeln("STORED ", type_ctor_mangled);

                if (name !in types) {
                    types[name] = true;
                } else {
                    writeln("error: type ", name, " already exists");
                }

                if (match_content("-", 0) && match_content(">", 1)) {
                    consume(); // eat -
                    consume(); // eat >

                    Tuple!(string, string)[] members = parse_parameters();

                    if (match_content(";", 0)) {
                        consume();
                        if (members.length == 0) {
                            writeln("warning: empty type, please remove the arrow operator");
                        }
                    }

                    return new Type(name, members);
                }
            }
        }

        return null;
    }

    Tuple!(string, string)[] parse_parameters() {
        Tuple!(string, string)[] params;

        while (true) {
            if (match_type(TOKEN_IDENTIFIER, 0) && peek(0).get_content() in types) {
                string type = consume().get_content();

                if (match_type(TOKEN_IDENTIFIER, 0)) {
                    string name = consume().get_content();

                    params ~= tuple(type, name);

                    if (match_content(",", 0)) {
                        consume();
                    } else {
                        break;
                    }
                }
            }
            else if (match_content("_", 0)) {
                consume();
                params ~= tuple("", "...");

                if (match_content(",", 0)) {
                    consume();
                } else {
                    break;
                }
            }
        }

        return params;
    }

    Call parse_call() {
        auto tok = peek(0);

        // mangle everything to see if it matches the constructors
        // in the stab for ctors
        auto type_ctor = "__T_" ~ to!string(tok.get_content().length) ~ "_" ~ tok.get_content() ~ "_type_ctor";
        if (tok.get_content() in functions || type_ctor in functions 
            || (match_content("-", 1) && match_content(">", 2))) {
            string name = consume().get_content();

            consume();
            consume();

            Expr[] args;
            while (true) {
                Expr e = parse_expr();
                if (e !is null) {
                    args ~= e;
                }

                if (match_content(",", 0)) {
                    consume();
                } else {
                    break;
                }
            }

            Call c = new Call(name, args);

            if (match_content(";", 0)) {
                consume();
            }

            return c;
        }

        return null;
    }

    Expr parse_expr() {
        Expr expr = parse_primary_expr();
        if (expr is null) {
            return null;
        }

        if (peek(0).get_content() == ";") {
            return expr;
        }

        return parse_binary_op(0, expr);
    }

    UnaryExpr parse_unary() {
        if (is_unary_op(peek(0).get_content())) {
            string op = consume().get_content();
            Expr rhand = parse_primary_expr();
            if (rhand !is null) {
                return new UnaryExpr(op, rhand);
            }
        }

        return null;
    }

    LiteralExpr parse_literal() {
        int type = match_literal(0);
        if (type == -1) {
            return null;
        }

        return new LiteralExpr(consume().get_content(), type);
    }

    Expr parse_primary_expr() {
        Call c = parse_call();
        if (c !is null) {
            return c;
        }

        UnaryExpr unary = parse_unary();
        if (unary !is null) {
            return unary;
        }

        LiteralExpr literal = parse_literal();
        if (literal !is null) {
            return literal;
        }

        return null;        
    }

    int get_token_prec() {
        Token tok = peek(0);

        if (!is_binary_op(tok.get_content())) {
            return -1;
        }

        int prec = precedence[tok.get_content()];
        if (prec <= 0) {
            return -1;
        }
        return prec;
    }

    Expr parse_binary_op(int prec, Expr lhand) {
        while (true) {
            int tok_prec = get_token_prec();
            if (tok_prec < prec) return lhand;

            if (!is_binary_op(peek(0).get_content())) {
                writeln("error: invalid binary op in expression `", peek(0).get_content(), "`");
                return null;
            }
            string operator = consume().get_content();

            Expr rhand = parse_expr();
            if (rhand is null) {
                return null;
            }

            int next_prec = get_token_prec();
            if (tok_prec < next_prec) {
                rhand = parse_binary_op(tok_prec + 1, rhand);
                if (rhand is null) {
                    return null;
                }
            }

            lhand = new BinaryExpr(lhand, operator, rhand);
        }

        return null;
    }

    Func parse_func() {
        if (match_content("func", 0)) {
            consume();

            if (match_type(TOKEN_IDENTIFIER, 0)) {
                string name = consume().get_content();

                if (name in functions) {
                    writeln("function already defined");
                } else {
                    functions[name] = true;
                }

                Func f = new Func(name);

                if (match_content("-", 0) && match_content(">", 1)) {
                    consume(); // eat -
                    consume(); // eat >

                    Tuple!(string, string)[] params = parse_parameters();
                    f.set_params(params);
                }

                if (match_content("[", 0)) {
                    consume();

                    if (peek(0).get_content() in types) {
                        string type = consume().get_content();
                        f.set_type(type);

                        if (match_content("]", 0)) {
                            consume();
                        }
                    }
                }

                // block
                if (match_content("{", 0)) {
                    consume();

                    while (true) {
                        if (match_content("}", 0)) {
                            consume();
                            break;
                        }

                        Node n = parse_node();
                        if (n !is null) {
                            f.append_node(n);
                        }
                    }
                } 
                // prototype
                else if (match_content(";", 0)) {
                    consume();
                    f.set_prototype(true);
                    return f;
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

        Type t = parse_type();
        if (t !is null) {
            return t;
        }

        Func f = parse_func();
        if (f !is null) {
            return f;
        }

        Call c = parse_call();
        if (c !is null) {
            return c;
        }

        return null;
    }

    Token peek(int offset) {
        if (position + offset > tokens.length) {
            writeln("attempting to peek out of bounds %d", position + offset);
            return null;
        }
        return this.tokens[position + offset];
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
    }

    Node[] get_ast() {
        return nodes;
    }

    int match_literal(int offset) {
        int lit = tokens[position + offset].get_type();
        switch (lit) {
            case TOKEN_CHARACTER:
                return LITERAL_CHAR;
            case TOKEN_NUMBER:
                return LITERAL_INT;
            case TOKEN_STRING:
                return LITERAL_STRING;
            case TOKEN_IDENTIFIER:
                return LITERAL_REFERENCE;
            default:
                return -1;
        }
    }

    bool is_unary_op(string op) {
        switch (op) {
            case "+": case "-": case "/": case "*":
                return true;
            default:
                return false;
        }
    }

    bool is_binary_op(string op) {
        switch (op) {
            case "+": case "-": case "/": case "*":
                return true;
            default:
                return false;
        }
    }
}