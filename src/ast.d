class Node {

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
}

class Var : Node {
private:
    string name;
    Expr value;

public:
    this(string name) {
        this.name = name;
    }
}

class Param {
private:
    string name;

public:
    this(string name) {
        this.name = name;
    }
}

class Func : Node {
private:
    string name;
    Param[] params;
    Node[] nodes;
    bool prototype;

public:
    this(string name) {
        this.name = name;
    }

    void append_param(Param param) {
        params ~= param;
    }

    void append_node(Node node) {
        nodes ~= node;
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
}
