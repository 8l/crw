module token;

enum {
    TOKEN_IDENTIFIER,
    TOKEN_NUMBER,
    TOKEN_OPERATOR,
    TOKEN_SEPARATOR,
    TOKEN_CHARACTER,
    TOKEN_STRING,
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

    string get_type_str() {
        switch (type) {
            case TOKEN_IDENTIFIER: return "identifier";
            case TOKEN_NUMBER: return "digit";
            case TOKEN_CHARACTER: return "character";
            case TOKEN_STRING: return "string";
            case TOKEN_SEPARATOR: return "separator";
            case TOKEN_OPERATOR: return "operator";
            default: return "?";
        }
    }

    string get_content() {
        return content;
    }

    int get_type() {
        return type;
    }

    string to_string() {
        return "['" ~ content ~ "' = " ~ get_type_str() ~ "]";
    }
}