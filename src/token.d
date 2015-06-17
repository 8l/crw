module token;

enum {
    TOKEN_IDENTIFIER,
    TOKEN_NUMBER,
}

class Token {
private:
    string content;
    int type;

public:
    this(string content, int type) {
        this.content = content;
        this.type = type;
    }

    string get_type() {
        switch (type) {
            case TOKEN_IDENTIFIER: return "identifier";
            case TOKEN_NUMBER: return "digit";
            default: return "?";
        }
    }

    string to_string() {
        return "['" ~ content ~ "' = " ~ get_type() ~ "]";
    }
}