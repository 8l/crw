enum {
    LITERAL_STRING,
    LITERAL_CHAR,
    LITERAL_INT,
    LITERAL_FLOAT
}

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
            case LITERAL_STRING: return "string";
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
    Expr value;

public:
    this(string name) {
        this.name = name;
    }

    void set_value(Expr value) {
        this.value = value;
    }

    override string to_string() {
        string res = "variable: " ~ name;
        if (value !is null) {
            res ~= " " ~ value.to_string();
        }
        return res;
    }
}

class Func : Node {
private:
    string name;
    string[] params;
    Node[] nodes;
    bool prototype;

public:
    this(string name) {
        this.name = name;
        this.prototype = false;
    }

    void append_node(Node node) {
        if (!this.prototype) this.prototype = true;
        nodes ~= node;
    }

    void set_params(string[] params) {
        this.params = params;
    }

    void set_prototype(bool prototype) {
        this.prototype = prototype;
    }

    override string to_string() {
        string res = "function: " ~ name;
        if (prototype) {
            res ~= " [prototype] ";
        }
        foreach (i; 0 .. params.length) {
            res ~= " " ~ params[i];
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

class Call : Node {
private:
    Attribute attrib;
    string name;
    Expr[] arguments;
    string pass;

public:
    this(string name, Expr[] arguments) {
        this.name = name;
        this.arguments = arguments;
    }

    override string to_string() {
        string res = "call: " ~ name;
        foreach (i; 0 .. arguments.length) {
            res ~= " " ~ arguments[i].to_string();
        }
        res ~= " -> " ~ pass;
        return res;
    }
}
