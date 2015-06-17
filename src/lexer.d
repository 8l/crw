module lexer;

import std.stdio;

class Lexer {
private:
    string source_file;
    int position;
    int initial_pos;
    char current_char;
    bool running;

public:
    this(string source_file) {
        this.source_file = source_file;
        this.position = 0;
        this.initial_pos = 0;
        this.current_char = source_file[position];
        this.running = true;
    }

    void eat_layout() {
        while (current_char == ' '
            || current_char == '\t'
            || current_char == '\n') {
            consume();
        }
    }

    void consume() {
        if (position + 1>= source_file.length) {
            position++;
            current_char = '\0';
            return;
        }
        current_char = source_file[++position];
    }

    void recognize_identifier() {
        while (is_identifier(current_char)) {
            consume();
        }
        writeln("recognized identifier {", source_file[initial_pos .. position], "}");
    }

    void recognize_digit() {
        while (is_digit(current_char)) {
            consume();
        }
        if (current_char == '.') {
            consume();
            while (is_digit(current_char)) {
                consume();
            }
        }
        writeln("recognized digit {", source_file[initial_pos .. position], "}");
    }

    void get_next_token() {
        eat_layout();
        initial_pos = position;

        if (current_char == '\0') {
            running = false;
            return;
        }
        // identifiers must start with a letter
        else if (is_letter(current_char)) {
            recognize_identifier();
        }
        // digits must start with a digit..
        else if (is_digit(current_char)) {
            recognize_digit();
        }
    }

    void start() {
        while (running) {
            get_next_token();
        }
    }

    bool is_digit(char c) {
        return (c >= '0' && c <= '9');
    }

    bool is_letter(char c) {
        return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');
    }

    bool is_letter_or_digit(char c) {
        return is_letter(c) || is_digit(c);
    }

    bool is_identifier(char c) {
        return is_letter_or_digit(c) || c == '_';
    }
}