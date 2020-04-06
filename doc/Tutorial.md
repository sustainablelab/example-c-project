# Tutorial transcribed from Barry Smith ATPESC 2016

This tutorial is my written version of Barry's talk.

Watch Barry's excellent presentation:
<https://www.youtube.com/watch?v=WFLvcMiG38w>

Barry's talk has few slides. Mostly he does live builds and
Makefile edits to show how a Makefile is built up to show how to
use `gnumake` and `GNU autotools`.

## More great talks

The Argonne National Labs talks from each year are available on
YouTube.

The YouTube Channel for 2016 is:
<https://www.youtube.com/channel/UCfwgjtIQB3puojz_N9ly_Ag/playlists?sort=dd&view=50&shelf_id=3>

Barry's talk is followed by talks on:
- documenting: <https://www.youtube.com/watch?v=FmMlBbbc_GE&list=PLGj2a3KTwhRaaztWIiUwKGSDKDFpwwxyR&index=4>
- testing: <https://www.youtube.com/watch?v=5AXbH43OSJo&list=PLGj2a3KTwhRaaztWIiUwKGSDKDFpwwxyR&index=5>
- refactoring: <https://www.youtube.com/watch?v=YXcEa-M7EBM&list=PLGj2a3KTwhRaaztWIiUwKGSDKDFpwwxyR&index=6>

# 1 - Build from a single source file
## First folder structure

```
.
├── build
│   └── a.out
└── src
    └── main.c
```

## First program

src/main.c:

```c
int main(int argc, char **argv)
{
    return 0;
}
```

## First build

### Build with `cc` and run

In bash, create executable `buid/a.out`:

```bash
$ cc -o build/a.out src/main.c
```

This worked if `cc` runs silently.

Run the executable:

```bash
$ build/a.out
```

The executable is OK if `a.out` runs silently.

### What is `cc`?

#### `cc` is a symbolic link to `gcc`

- `cc` is a *symbolic link* to `gcc.exe`
    - see <https://www.computerhope.com/unix/ucc.htm>

Now I show this.

`cc` is a C compiler, but which one?

In bash:

```
$ whereis cc
cc: /usr/bin/cc
```

List `cc` with `ls -l` to view details:

```bash
$ ls -l /usr/bin/cc
lrwxrwxrwx 1 lily None 7 Mar 31 13:41 /usr/bin/cc -> gcc.exe
```

The important part is at the end of the line:

```bash
/usr/bin/cc -> gcc.exe
```


#### Symbolic links
- see <https://www.computerhope.com/issues/ch001638.htm>

Now I demonstrate this.

Note `gcc` is in the same folder as the symbolic link `cc`:

```
$ ls -l /usr/bin | grep cc
lrwxrwxrwx   1 lily None        7 Mar 31 13:41 cc -> gcc.exe
-rwxr-xr-x   3 lily None  1356800 Mar 14 07:42 gcc.exe
...
-rwxr-xr-x   2 lily None    29696 Mar 14 07:42 x86_64-pc-cygwin-gcc-ranlib.exe
```

Prove this is a symbolic link by making one called `xx`.

First, make sure `xx` is not already the name of something:

```bash
$ whereis xx
xx:
```

`xx` is available as a name.

Make `xx` a symbolic link to `gcc`:

```bash
$ ln -s /usr/bin/gcc.exe /usr/bin/xx
ln: failed to create symbolic link '/usr/bin/xx': Permission denied
```

OK, make `xx` in the `~` directory:

```bash
$ ln -s /usr/bin/gcc.exe ~/xx
```

Now use `xx` to build `a.out`:

```bash
$ ~/xx -o build/a.out src/main.c
```

List details of `xx` with `ls -l`:

```bash
$ ls -l ~/xx
lrwxrwxrwx 1 mike mike 16 Apr  5 17:04 /home/mike/xx -> /usr/bin/gcc.exe
```

The important part is the symbolic link notation at the end:

```bash
/home/mike/xx -> /usr/bin/gcc.exe
```

Demonstration over. Now get rid of `xx`:

```bash
$ rm -i ~/xx
rm: remove symbolic link '/home/mike/xx'? y
```

## Add output to the program 

src/main.c:

```c
int main(int argc, char **argv)
{
    printf("Hi.")
    return 0;
}
```

There are two errors. Expect this build to fail.

```bash
$ cc -o build/a.out src/main.c
src/main.c: In function ‘main’:
src/main.c:5:5: warning: implicit declaration of function ‘printf’ [-Wimplicit-function-declaration]
    5 |     printf("Hi.")
      |     ^~~~~~
src/main.c:5:5: warning: incompatible implicit declaration of built-in function ‘printf’
src/main.c:1:1: note: include ‘<stdio.h>’ or provide a declaration of ‘printf’
  +++ |+#include <stdio.h>
    1 | // gcc -o build/a.out src/main.c
src/main.c:5:18: error: expected ‘;’ before ‘return’
    5 |     printf("Hi.")
      |                  ^
      |                  ;
    6 |     return 0;
      |     ~~~~~~
```

The first error is:

```bash
src/main.c:1:1: note: include ‘<stdio.h>’ or provide a declaration of ‘printf’
```

Add the include:

```c
#include <stdio.h>
int main(int argc, char **argv)
{
    printf("Hi.")
    return 0;
}
```

```bash
$ cc -o build/a.out src/main.c
src/main.c: In function ‘main’:
src/main.c:5:18: error: expected ‘;’ before ‘return’
    5 |     printf("Hi.")
      |                  ^
      |                  ;
    6 |     return 0;
      |     ~~~~~~
```

Add the missing semicolon to the `printf()`. Expect `a.out`
builds and runs without error.

Build and run `build/a.out`:

```bash
$ cc -o build/a.out src/main.c
$ build/a.out
Hi.
```

# 2 - Build with two source files
## Add a dependency to the program

Programs are *never* a single file.

```c
#include <stdio.h>

extern int util(int);

int main(int argc, char **argv)
{
    printf("Hi.");
    return util(argc);
}
```

### extern

`extern` is a C keyword. In this context, it says:

- I use `util` in this file
- function `util` is defined in another file

The `extern` statement tells the compiler the argument data types
and return value type for `util`. This is everything the compiler
needs to know to generate the placeholder in the `main.o` object
file.

*Calling functions defined in other source files is normally
handled using header files. I will get there. For now, this
`extern` statement is a shortcut to making a dependency.*

The compiler does all of the steps to make object file `main.o`.
The steps are:

- pre-process to one giant source file
    - copy and paste included files into the source file
    - expand macros
- compile to assembly .a (or .asm or .avra)
    - convert the C code to assembly code
    - the assembly instruction set is machine-dependent
    - the assembly file is still human-readable and is not
      machine-specific
- translate to an object file .o
    - convert the assembly code to machine-specific code that
      runs on this processor
    - this is not human-readable, unless you're Alan Turing

`main.o` has a placeholder for the call to `util`.

A final *linking* step links `main.o` with the object file that
has the definition of `util`. This linking step outputs the final
executable as a combination of the two object files.

In the final executable, the placeholder for `util` is filled in
with the address where the definition of `util` is found in the
executable.

## Build with a dependency

```bash
$ rm build/a.out
$ cc -o build/a.out src/main.c
/usr/lib/gcc/x86_64-pc-cygwin/9.3.0/../../../../x86_64-pc-cygwin/bin/ld: /tmp/ccEboH9S.o:main.c:(.text+0x24): undefined reference to `util'
/tmp/ccEboH9S.o:main.c:(.text+0x24): relocation truncated to fit: R_X86_64_PC32 against undefined symbol `util'
collect2: error: ld returned 1 exit status
```

The important part of the error is:

```bash
undefined symbol `util'
error: ld returned 1 exit status
```

- `ld` is the linker
- symbol `util` is undefined

Create `util.c`:

```
.
├── build
└── src
    ├── main.c
    └── util.c
```

Write `util.c`:

```c
int util(int input)
{
    return input;
}
```

Build again:

```bash
$ cc -o build/a.out src/main.c
```

The same error.

I must tell the compiler to use `util.c`. It is not enough that
the file exists.

Add `util.c` to the list of file inputs:

```bash
$ cc -o build/a.out src/main.c src/util.c
$ build/a.out
Hi.
```

### compiling, linking, -o, what?

The behavior of the compiler is dependent on the form of the
invocation. It is impossible to infer the syntax looking at a
single invocation of the compiler. These toy-example projects are
not a good example for understanding this syntax.

`-o` means output a file.

It does not matter what order input files and output filename are
given in. The compiler figures out what to do from the placement
of the `-o` flag.

I like putting the input files first:

```bash
$ cc src/main.c src/util.c -o build/a.out
```

For a single source file with no dependencies, this is enough:

```bash
$ cc src/main.c
```

Note:

- no flags
- no output file name

This builds `a.exe` in the project root directory.

The steps required to *create* the output file are implied by the
file extensions. Here, `gcc` knows to compile the files, and then
link the results to make the output file.

Enough with toy examples.

Later, I state explicitly state the steps to build intermediate
files, using `-c` to compile object files without linking. I
build the object files in a separate step from the final output
file.

And even later, some of this behavior is again handled
implicitly, eliminating the need for `-c`, but this time by the
implicit rules of GNU `make`.

# 3 - Build with a Makefile

## First Makefile

