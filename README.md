# crw
a tiny little compiler I'm writing to learn D. It compiles to CC, so you'll need a C compiler like gcc or clang to use crw.

## building

    $ git clone https://www.github.com/felixangell/crw
    $ cd crw
    $ make

To compile your code to an executable:

    $ ./main build tests/test.crw

To log the generated code:

    $ ./main debug tests/test.crw

## example
here's an example...

    int variable;
    int another_variable = 1;

    type make_our_custom_type ->
        int a,
        double c,
        float z,
        str e;

    func this_returns_void {

    }

    func this_returns_an_int [int] {

    }

    func this_takes_two_params_and_returns_void -> int a, int b {

    }

    func this_takes_one_param_and_returns_int -> int z [int] {

    }