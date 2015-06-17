module lexer;

class Lexer {
private:
    string source_file;
    int position;
    char current_char;
    bool running;

public:
    this(string source_file) {
        this.source_file = source_file;
        this.position = 0;
        this.current_char = source_file[position];
        this.running = true;
    }

    void consume() {
        if (position >= source_file.length - 1) {
            running = false;
            return;
        }
        this.current_char = source_file[++position];
    }

    void get_next_token() {
        
    }

    void start() {
        while (running) {
            get_next_token();
        }
    }
}