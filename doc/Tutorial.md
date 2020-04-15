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

- see <https://www.computerhope.com/unix/ucc.htm>

#### Symbolic link demonstration

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

### What is `gcc`?
GCC is the GNU Compiler Collection. It includes compilers for
many languages.

`gcc` also refers to the C compiler in the GNU Compiler
collection. Similarly, `g++` is the C++ compiler.

GCC handles compiling:

- preprocess to a single, expanded source file
- translate to an assembly file

GNU Binutils (Binary Utilities) is many software development
utilities, including the GNU assembler `gas` and GNU linker `ld`.
The assembler converts assembly files to object files. The linker
combines object files to make a single executable file.

GCC and GNU Binutils <https://www.gnu.org/software/binutils/> are
part of the GNU Project: <https://www.gnu.org/>.

The GNU Project is supported and funded by the Free Software
Foundation: <https://www.fsf.org/>.

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

And actually the `extern` keyword isn't even necessary for the
compiler. All functions are `extern`. The `extern` is for human
readers. All that's necessary is the function signature:

```c
int util(int input);
```

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

### Hello

Simple two-line Makefile that prints `Hello`:

```
hello:
	echo Hello
```

* `hello:` is the *target*
* `echo Hello` is a *recipe*
** each recipe must be indented with a tab
** Vim automatically uses tabs when `filetype=make`
*** Vim recognizes files named `Makefile` are a Makefile
*** or do `:set ft=make` to switch to Makefile formatting

Build a target with the syntax `make target-name`. From bash:

```
$ make hello
echo Hello
Hello
```

By default, **make** prints each recipe before it runs it. Place an `@` in front of a recipe to suppress printing:


```
hello:
	@echo Hello
```

*Added the `@`.*

```
$ make hello
Hello
```

*Now the recipe does not print, only the result.*

### Build command as a Makefile

The final build command in the previous tutorial was:

```
$ cc -o build/a.out src/main.c src/util.c
```

Here is the initial translatation into a Makefile:

```
build/a.out: src/main.c src/util.c
	cc -o build/a.out src/main.c src/util.c
```

*Note:* this works, but it is *not* how Makefiles will look
by the end of the tutorial.

Run `make` from bash:

```
$ make
make: 'build/a.out' is up to date.
```

I do not specify the target name because this is the only target
in my Makefile. Later, when there are more targets, the default
target is the *first* target in the file.

Note `make` does not do anything because the target is already
`up to date`.

Delete `build/a.out` and try again:

```
$ rm build/a.out
$ make
cc -o build/a.out src/main.c src/util.c
```

This time `make` does the build. `make` prints the recipe before
it runs it.

Add another recipe to the target that runs the executable after
it is built:

```
build/a.out: src/main.c src/util.c
	cc -o build/a.out src/main.c src/util.c
	build/a.out
```

Build again:

```
$ rm build/a.out
$ make
cc -o build/a.out src/main.c src/util.c
build/a.out
Hi.make: *** [Makefile:3: build/a.out] Error 1
```

*This is correct despite the error message.*

### Explain Error 1

`make` expects the value returned by `build/a.out` to be 0.

A return status of **0** is, by convention, no error, and any
**non-zero** return value is, by convention, an error code. The
return value in this is case is `1`, so make reports `Error 1`.

Why does the program return 1?

`main.c` calls:

```c
    return util(argc);
```

- `util()` returns its input value, `argc`
    - `argc` is the number of command line arguments
    - `build/a.out` counts as one argument
- when `build/a.out` exits, it returns with the value of
`argc`
    - with no arguments, `argc` is 1

Check this by appending two args:

```make
build/a.out: src/main.c src/util.c
	cc -o build/a.out src/main.c src/util.c
	build/a.out arg2 arg3
```

```bash
$ rm build/a.out
$ make
cc -o build/a.out src/main.c src/util.c
build/a.out arg2 arg3
Hi.make: *** [Makefile:3: build/a.out] Error 3
```

*With three args, `make` reports `Error 3`.*

There is nothing wrong with `build/a.out`. Run it on its own with
the inputs arg2 and arg3 and it still just prints `Hi.`:

```bash
$ build/a.out arg2 arg3
Hi.
```

As a final demonstration of the return status and `Error`
message, change `util.c` to subtract 3, so that it returns 0 when
there are three args:

```c
int util(int input)
{
    return input-3;
}
```

And build again:

```bash
$ make
cc -o build/a.out src/main.c src/util.c
build/a.out arg2 arg3
Hi.
```

- I do not need to delete `build/a.out.`
- `make` recognizes that prerequisite `util.c` changed
    - the target `build/a.out` is no longer up to date
    - target `build/a.out` must be rebuilt

Run `build/a.out` without additional arguments. When the return
value is non-zero, the shell reports the return value, though it
does not call it an `Error` like `make` does.

Expect the non-zero return value is the result of subtracting `3`
from `1`:

```
$ build/a.out
Hi.
shell returned 254
```

Although the datatype is an `int` in `util.c`, on my system,
the shell decided the return value datatype is an **unsigned
byte**.

### Return values when piping and redirecting streams

It is common for a `make` recipe to run an executable. Often the
result is piped or redirected.

If the executable is piped to another executable with `|`, the
return value is swallowed. The value returned to the shell is the
value from the last executable in the pipe chain.

If the executable generates output streams on `stdout` and/or
`stderr`, and those streams are redirected to files with `>` and
`2>`, the return value is not swallowed.

Pipe output of `build/a.out` to `less` (a pager utility):

```make
build/a.out: src/main.c src/util.c
	cc -o build/a.out src/main.c src/util.c
	build/a.out | less
```

And build.

But this time, instead of deleting `build/a.out`, trigger the
rebuild using utility `touch` to trick `make` into thinking
`src/main.c` has changed.

```bash
$ touch src/main.c
$ make
cc -o build/a.out src/main.c src/util.c
build/a.out | less
```

The pager runs and displays `Hi.`, hit `q` to exit.

The pager swallowed the non-zero return value, so no error.

Now redirect `stdout` to a file:

```bash
$ touch src/main.c
$ make
cc -o build/a.out src/main.c src/util.c
build/a.out > a.md
make: *** [Makefile:3: build/a.out] Error 254
```

The file contains `Hi.`, but the return value is not swallowed.

Redirect both stdout and stderr:

```bash
$ build/a.out > a.md 2> err.md
```

`err.md` is empty.

The return value is not in `stdout` or `stderr`.

## Restore files to good behavior

Fix the source files so the executable returns 0.

`main.c`:

```c
#include <stdio.h>

extern int util(int);

int main(int argc, char **argv)
{
    printf("nargs: %d\n", util(argc));
    return 0;
}
```

`util.c`:

```c
int util(int input)
{
    int nargs = input-1;
    return nargs;
}
```

And revise the `Makefile`:

```make
build/exe: src/main.c src/util.c
	cc -o build/exe src/main.c src/util.c
```

Build:

```bash
$ make
cc -o build/exe src/main.c src/util.c
```

And run:

```bash
$ build/exe.exe
nargs: 0
```

## Second Makefile

Change all `.c` in the **prerequisites** *and* the **recipe** to
`.o`:

```make
build/exe: src/main.o src/util.o
	cc -o build/exe src/main.o src/util.o
```

`make` knows how to build `.o` files from `.c` files; explicit
recipes are not necessary.

```bash
$ make
cc    -c -o src/main.o src/main.c
cc    -c -o src/util.o src/util.c
cc -o build/exe src/main.o src/util.o
```

The first two recipes that are printed are not explicitly in the
Makefile. These are **implicit rules**.

Change `main.c` and build again:

```bash
$ touch src/main.c
$ make
cc    -c -o src/main.o src/main.c
cc -o build/exe src/main.o src/util.o
```

Note that `make` only:

* recompiles `main.o`
* and links `build/exe` from `main.o` and `util.o`

`make` **does not** recompile `util.o` because `util.c` did not
change.

The downside to relying on the implicit recipe for making object
files from source code is that the object files `main.o` and
`util.o` are placed in the `src` folder. It is cleaner to place
these in the `build` folder.

```make
build/exe: build/main.o build/util.o
	cc -o build/exe build/main.o build/util.o
```

But now the implicit rule breaks because `make` cannot find the
source files:

```bash
$ make
make: *** No rule to make target 'build/main.o', needed by 'build/exe'.  Stop.
```

Make the recipe explicit to put object files in the `build`
folder.

```make
build/exe: build/main.o build/util.o
	cc -o build/exe build/main.o build/util.o

build/main.o: src/main.c
	cc -c -o build/main.o src/main.c
build/util.o: src/util.c
	cc -c -o build/util.o src/util.c
```

//Note the recipes for building object files requires flag `-c`
to tell gcc to stop after compiling, do not run the linker.//

And build:

```bash
$ make
cc -c -o build/main.o src/main.c
cc -c -o build/util.o src/util.c
cc -o build/exe build/main.o build/util.o
```

The repetition is tedious to read and hideous to maintain.
Replace it with a pattern rule using `%` as the stem:

```make
build/exe: build/main.o build/util.o
	cc -o build/exe build/main.o build/util.o

build/%.o: src/%.c
	cc -c -o $@ $^
```

Variables in `make` start with `$`. The variables `$@` and `$^`
are *automatic variables*. These are built-in variables:

* `$@` is the target
* `$^` is all prerequisites, space separated
* `$<` is just the first prerequisite

If the variable is more than one character, it is enclosed in
parentheses or curly braces, for example, `$(myvar)` or
`${myvar}`. By convention, user-defined variables also use
parentheses, even if they are just one character.

The build behaves the same:

```bash
$ touch src/main.c
$ touch src/util.c
$ make
cc -c -o build/main.o src/main.c
cc -c -o build/util.o src/util.c
cc -o build/exe build/main.o build/util.o
```

## Third Makefile

Move the `util` function signature from `main.c` into a header
file:

`util.h`

```c
#ifndef _UTIL_H
#define _UTIL_H

int util(int input);

#endif // _UTIL_H
```

Include this header in both `util.h` and `main.c`.

`main.c`

```c
#include <stdio.h>
#include "util.h"

int main(int argc, char **argv)
{
    printf("nargs: %d\n", util(argc));
    return 0;
}
```

`util.c`

```c
#include "util.h"
int util(int input)
{
    int nargs = input-1;
    return nargs;
}
```

Headers are not compiled. But I list the header as a prerequisite
to force a rebuild of the object files that depend on the header.

```make
build/exe: build/main.o build/util.o
	cc -o build/exe build/main.o build/util.o

build/%.o: src/%.c src/util.h
	cc -c -o $@ $<
```

Touch the header and rebuild:

```bash
$ touch src/util.h
$ make
cc -c -o build/main.o src/main.c
cc -c -o build/util.o src/util.c
cc -o build/exe build/main.o build/util.o
```

If I decide later that only `util.c` depends on `util.h`, move it
out of the pattern rule:

```make
build/exe: build/main.o build/util.o
	cc -o build/exe build/main.o build/util.o

build/%.o: src/%.c
	cc -c -o $@ $<

build/util.o: src/util.h
```

## Fourth Makefile

Create a tags file.

```make
build/exe: build/main.o build/util.o
	cc -o build/exe build/main.o build/util.o

build/%.o: src/%.c
	cc -c -o $@ $<

build/util.o: src/util.h

ctags:
	ctags --c-kinds=+l --exclude=Makefile -R .
```

Install `ctags` with the Cygwin package manager.

By default, `ctags` outputs a tags file named `tags`.

By default, the Vim `tag` command looks for `./tags,tags`. Check
this with `:set tags`.

This tags file is only for C symbols in the project. For example,
there is a tag for `main`, but no tag for `printf`.

I remedy this later. I show a recipe using `gcc` with the `-M`
flag to determine the header dependencies for generating a list
of header prerequisites.

Using this same `-M` flag, I generate a file that lists library
dependencies, such as `stdio`, and use ctags flag `-L` to read
this file. I output this as a `lib-tags` file, a special tags
file just for library dependencies. I append `lib-tags` to the Vim
`tags` search path, giving search precedence to the project
`tags` file first.
