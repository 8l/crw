class Node {
public:
    string to_string() {
        return "";
    }
}

class Expr : Node {
private:
    string left;
    char op;
    string right;
public:
    this(string left, char op, string right) {
        this.left = left;
        this.op = op;
        this.right = right;
    }

    override string to_string() {
        return left ~ " " ~ op ~ " " ~ right;
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
