# crw
a tiny little compiler I'm writing to learn D...

## example
here's an example...

    int test;
    int another = test;
    int swag = 5 + 5;

    func add -> int a, int b, int c {
        ret a + b + c;
    }

    func print -> int a {
        #foreign printf "%d\n", a;
    }

    func no_args {
        print "no args";
    }

    func main [int] {
        add 1, 2, 3 -> print;
        no_args _;
    }