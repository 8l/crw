enum {
    LITERAL_STRING,
    LITERAL_CHAR,
    LITERAL_INT,
    LITERAL_FLOAT,
    LITERAL_REFERENCE
}

import std.stdio;
import std.conv;
import std.typecons;

class Node {
public:
    string to_string() {
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
            case LITERAL_STRING: return "char*";
            case LITERAL_CHAR: return "char";
            case LITERAL_FLOAT: return "float";
            case LITERAL_INT: return "int";
            default: return "??";
        }
    }

    override string to_string() {
        return "(literal: " ~ value ~ " [" ~ get_type_str() ~ "])";
    }
}

class Expr : Node {
public:
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

    Expr get_value() {
        return value;
    }

    void set_value(Expr value) {
        this.value = value;
    }

    string get_type() {
        return type;
    }

    string get_name() {
        return name;
    }

    string get_mangled_name() {
        auto length = name.length;
        auto result =  "__V_" ~ to!string(length) ~ "_" ~ name ~ "_" ~ type;
        return result;
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

    string get_mangled_name() {
        auto length = name.length;
        auto result =  "__S_" ~ to!string(length) ~ "_" ~ name ~ "_";
        foreach (i; 0 .. members.length) {
            auto member = members[i];
            result ~= member[0] ~ "_" ~ member[1];
            if (i != members.length - 1) {
                result ~= "_";
            }
        }
        return result;
    }

    string get_name() {
        return name;
    }

    Tuple!(string, string)[] get_members() {
        return members;
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

    string get_mangled_name() {
        auto length = name.length;
        auto result =  "__F_" ~ to!string(length) ~ "_" ~ name ~ "_";
        foreach (i; 0 .. params.length) {
            auto param = params[i];
            result ~= param[0] ~ "_" ~ param[1];
            if (i != params.length - 1) {
                result ~= "_";
            }
        }
        result ~= "_" ~ get_type();
        return result;
    }

    string get_name() {
        return name;
    }

    Tuple!(string, string)[] get_params() {
        return params;
    }

    void set_params(Tuple!(string, string)[] params) {
        this.params = params;
    }

    Node[] get_nodes() {
        return nodes;
    }

    void set_prototype(bool prototype) {
        this.prototype = prototype;
    }

    void set_type(string type) {
        this.type = type;
    }

    string get_type() {
        return type;
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

    string get_name() {
        return name;
    }

    Expr[] get_arguments() {
        return arguments;
    }

    override string to_string() {
        string res = "call: " ~ name;
        foreach (i; 0 .. arguments.length) {
            res ~= " " ~ arguments[i].to_string();
        }
        return res;
    }
}
