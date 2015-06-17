var test;

func add -> a, b, c {
    ret a + b + c;
}

func print -> a {
    #foreign printf "%d\n", a;
}

func no_args {
    print "no args";
}

func main {
    add 1, 2, 3 -> print;
    no_args _;
}