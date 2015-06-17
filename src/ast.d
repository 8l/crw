enum {
    LITERAL_STRING,
    LITERAL_CHAR,
    LITERAL_INT,
    LITERAL_FLOAT
}

import std.stdio;
import std.typecons;

class Node {
public:
    string to_string() {
        return "";
    }

    string codegen() {
        return "";
    }
}

class UnaryExpr : Expr {
private:
    Expr rhand;
    string op;
public:
    this(string op, Expr rhand) {
        this.op = op;
        this.rhand = rhand;
    }

    Expr get_rhand() {
        return rhand;
    }

    string get_op() {
        return op;
    }

    override string codegen() {
        return rhand.codegen() ~ " " ~ op;
    }

    override string to_string() {
        return rhand.to_string() ~ " " ~ op;
    }
}

class BinaryExpr : Expr {
private:
    Expr lhand;
    string op;
    Expr rhand;

public:
    this(Expr lhand, string op, Expr rhand) {
        this.lhand = lhand;
        this.op = op;
        this.rhand = rhand;
    }

    Expr get_lhand() {
        return lhand;
    }

    string get_op() {
        return op;
    }

    Expr get_rhand() {
        return rhand;
    }

    override string codegen() {
        return lhand.codegen() ~ " " ~ op ~ " " ~ rhand.codegen();
    }

    override string to_string() {
        return lhand.to_string() ~ " " ~ op ~ " " ~ rhand.to_string();
    }
}

class LiteralExpr : Expr {
private:
    string value;
    int type;

public:
    this(string value, int type) {
        this.value = value;
        this.type = type;
    }

    string get_value() {
        return value;
    }

    int get_type() {
        return type;
    }

    string get_type_str() {
        switch (type) {
            case LITERAL_STRING: return "string";
            case LITERAL_CHAR: return "char";
            case LITERAL_FLOAT: return "float";
            case LITERAL_INT: return "int";
            default: return "??";
        }
    }

    override string codegen() {
        return value;
    }

    override string to_string() {
        return "(literal: " ~ value ~ " [" ~ get_type_str() ~ "])";
    }
}

class Expr : Node {
public:
    override string codegen() {
        return "";
    }

    override string to_string() {
        return "";
    }
}

class Var : Node {
private:
    string name;
    string type;
    Expr value;

public:
    this(string name, string type) {
        this.name = name;
        this.type = type;
    }

    void set_value(Expr value) {
        this.value = value;
    }

    override string codegen() {
        string res = type ~ " " ~ name;
        if (value !is null) {
            res ~= " = " ~ value.codegen();
        }
        if (!cast(Call) value) {
            res ~= ";";
        }
        res ~= "\n";
        return res;
    }

    override string to_string() {
        string res = "variable: " ~ name;
        if (value !is null) {
            res ~= " " ~ value.to_string();
        }
        return res;
    }
}

class Type : Node {
private:
    string name;
    Tuple!(string, string)[] members;

public:
    this(string name, Tuple!(string, string)[] members) {
        this.name = name;
        this.members = members;
    }

    string get_name() {
        return name;
    }

    Tuple!(string, string)[] get_members() {
        return members;
    }

    override string codegen() {
        string result = "typedef struct {\n";
        foreach (i; 0 .. members.length) {
            result ~= members[i][0] ~ " " ~ members[i][1];
            result ~= ";\n";
        }
        result ~= "\n} " ~ name ~ ";\n";
        return result;
    }
}

class Func : Node {
private:
    string name;
    Tuple!(string, string)[] params;
    Node[] nodes;
    bool prototype;
    string type;

public:
    this(string name) {
        this.name = name;
        this.prototype = false;
        this.type = "void";
    }

    void append_node(Node node) {
        nodes ~= node;
    }

    void set_params(Tuple!(string, string)[] params) {
        this.params = params;
    }

    void set_prototype(bool prototype) {
        this.prototype = prototype;
    }

    void set_type(string type) {
        this.type = type;
    }

    override string codegen() {
        string result = type ~ " " ~ name ~ "(";

        foreach (i; 0 .. params.length) {
            result ~= params[i][0] ~ " " ~ params[i][1];
            if (i != params.length - 1) {
                result ~= ", ";
            }
        }
        result ~= ")";

        if (!prototype) {
            result ~= "{\n";
            if (nodes.length > 0) {
                foreach (i; 0 .. nodes.length) {
                    result ~= nodes[i].codegen();
                }
            }
            result ~= "\n}\n";
        } else {
            result ~= ";\n";
        }

        return result;
    }

    override string to_string() {
        string res = "function: " ~ name;
        if (prototype) {
            res ~= " [prototype] ";
        }
        foreach (i; 0 .. params.length) {
            res ~= params[i][0] ~ " " ~ params[i][1];
        }
        return res;
    }
}

class Attribute {
private:
    string name;
public:
    this(string name) {
        this.name = name;
    }
}

class Call : Expr {
private:
    Attribute attrib;
    string name;
    Expr[] arguments;

public:
    this(string name, Expr[] arguments) {
        this.name = name;
        this.arguments = arguments;
    }

    override string codegen() {
        string res = name ~ "(";
        foreach (i; 0 .. arguments.length) {
            res ~= arguments[i].codegen();
            if (i != arguments.length - 1) {
                res ~= ", ";
            }
        }
        res ~= ");\n";
        return res;
    }

    override string to_string() {
        string res = "call: " ~ name;
        foreach (i; 0 .. arguments.length) {
            res ~= " " ~ arguments[i].to_string();
        }
        return res;
    }
}
