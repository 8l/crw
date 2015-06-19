module codegen;

import std.stdio;
import std.process;
import std.string;
import std.conv;

import ast;

enum {
    LOG_C,
    COMPILE_C,
    SOURCE_FILE,
    HEADER_FILE
}

class Codegen {
private:
    Node[] nodes;
    int where;
    Node[string] stab;
    string[string] types;

    string header_file;
    string source_file;

public:
    this(Node[] nodes) {
        this.nodes = nodes;

        types["int"] = "int";
        types["string"] = "char*";
        types["double"] = "double";
        types["float"] = "float";
        types["byte"] = "char";
        types["void"] = "void";
    }

    void generate_func(Func func) {
        // store the function
        stab[func.get_name()] = func;

        set_writer(HEADER_FILE);
        write_line(func.get_type() ~ " " ~ func.get_mangled_name() ~ "(");
        foreach (i; 0 .. func.get_params().length) {
            auto param = func.get_params()[i];
            write_line(get_type(param[0]) ~ " " ~ param[1]);
            if (i != func.get_params().length - 1) {
                write_line(", ");
            }
        }
        write_line(");\n");

        set_writer(SOURCE_FILE);
        write_line(func.get_type() ~ " " ~ func.get_mangled_name() ~ "(");
        foreach (i; 0 .. func.get_params().length) {
            auto param = func.get_params()[i];
            write_line(get_type(param[0]) ~ " " ~ param[1]);
            if (i != func.get_params().length - 1) {
                write_line(", ");
            }
        }
        write_line(") {\n");

        foreach (i; 0 .. func.get_nodes().length) {
            write_line("\t");
            auto node = func.get_nodes()[i];
            generate_node(node);
            write_line(";\n");
        }

        write_line("}\n");
    }

    void generate_var(Var var) {

    }

    void generate_unary_expr(UnaryExpr unary) {
        write_line(unary.get_op());
        generate_expr(unary.get_rhand());
    }

    void generate_binary_expr(BinaryExpr expr) {
        generate_expr(expr.get_lhand());
        write_line(expr.get_op());
        generate_expr(expr.get_rhand());
    }

    void generate_literal_expr(LiteralExpr expr) {
        write_line(expr.get_value());
    }

    void generate_expr(Expr expr) {
        if (auto x = cast(UnaryExpr) expr) {
            generate_unary_expr(x);
        } else if (auto x = cast(BinaryExpr) expr) {
            generate_binary_expr(x);
        } else if (auto x = cast(LiteralExpr) expr) {
            generate_literal_expr(x);
        }
    }

    void generate_call(Call call) {
        auto func = cast(Func) stab[call.get_name()];
        
        set_writer(SOURCE_FILE);
        write_line(func.get_mangled_name() ~ "(");
        foreach (i; 0 .. call.get_arguments().length) {
            auto arg = cast(Expr) call.get_arguments()[i];
            generate_expr(arg);
            if (i != call.get_arguments().length - 1) {
                write_line(", ");
            }
        }
        write_line(")");
    }

    string get_type(string type) {
        if (type !in types) {
            writeln("shit: ", type, " not defined");
        }
        return types[type];
    }

    void generate_type(Type type) {
        stab[type.get_name()] = type;
        types[type.get_name()] = type.get_mangled_name();

        set_writer(HEADER_FILE);
        write_line("typedef struct {\n");
        foreach (i; 0 .. type.get_members().length) {
            auto member = type.get_members()[i];
            write_line("\t" ~ get_type(member[0]) ~ " " ~ member[1] ~ ";\n");
        }
        write_line("} " ~ type.get_mangled_name() ~ "; \n");
    }

    void generate_node(Node node) {
        if (auto x = cast(Func) node) {
            generate_func(x);
        } else if (auto x = cast(Var) node) {
            generate_var(x);
        } else if (auto x = cast(Call) node) {
            generate_call(x);
        } else if (auto x = cast(Type) node) {
            generate_type(x);
        }
    }

    void start(int flag) {
        foreach (i; 0 .. nodes.length) {
            generate_node(nodes[i]);
        }

        writeln("dumped sourcefile: \n", source_file);
        writeln("dumped headerfile: \n", header_file);
    }

    void set_writer(int where) {
        this.where = where;
    }

    void write_line(string fmt) {
        switch (where) {
            case SOURCE_FILE: source_file ~= fmt; break;
            case HEADER_FILE: header_file ~= fmt; break;
            default: break;
        }
    }
}