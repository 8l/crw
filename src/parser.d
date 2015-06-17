module parser;

import std.stdio;
import ast;
import token;

class Parser {
private:
    Token[] tokens;
    Node[] nodes;
    int[string] precedence;
    int position;

public:
    this(Token[] tokens) {
        this.tokens = tokens;
        this.position = 0;

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
        if (match_content("var", 0)) {
            consume();

            if (match_type(TOKEN_IDENTIFIER, 0)) {
                string name = consume().get_content();

                Var v = new Var(name);

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

    Expr parse_expr() {
        Expr expr = parse_primary_expr();
        if (expr is null) {
            return null;
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
        foreach (i; 0 .. nodes.length) {
            writeln(nodes[i].to_string());
        }
    }

    int match_literal(int offset) {
        int lit = tokens[position + offset].get_type();
        switch (lit) {
            case LITERAL_CHAR:
            case LITERAL_INT:
            case LITERAL_FLOAT:
            case LITERAL_STRING:
                return lit;
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