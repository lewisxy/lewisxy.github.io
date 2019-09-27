---
title:  Simple Infix Evaluation
layout: post
date:   2019-09-20
tag:    [programming languages, java]
uuid:   F9BE27BC-B185-4EE5-B84F-D9D6D79059BA
---

TL;DR: check out [this repo][2].

Few weeks ago, a friend asked me to help on his project of an intro level
programming course. It was of nothing complicated, a program that reproduce
 some features of a scientific calculator that evaluates arithmetic
expressions with `+`, `-`, `*`, `/` and parenthesis `(`, `)` with the
correct precedence. He dealt with it in naive ways and come to me because he
found himself surrounded by unfixable bugs. This sort of reminded me of my
failed attempt of creating a very similar thing in the early days of my
programming experiences. To revisit that failed project and to help my
friend, I decided to write a proof of concept for this problem.

## Planning
This problem is essentially creating a interpreter for a language with
numbers and different operators similar to any other programming languages.
To write any interpreter, we need a **tokenizer** to convert string input to
language tokens and a **parser** that evaluates the token to designated
results. The parser usually consist of **lexier?** that build the logical
representation of the expression, usually in the form of a tree commonly
known as AST, and **evaluator** that evaluate the expression based upon
that. Our language is simple enough that we can reduce the parser to
just evaluator.

## Implementation

### Tokenizer
Since we will evaluate the simplest arithmetic expressions with only binary
operators and parenthesis (for the sake of simplicity, `-` in the language
only have a unambiguous meaning of *minus*, ignoring negative numbers for
the moment) without any fancy syntatical sugars unlike other programming
languages, the tokenizers only need to remove white spaces in the string and
 convert known operators to operator tokens and parse the numbers to double.
The numbers are slightly trickier. But since the project is not about
parsing numbers, we will use the have built-in method of
 `Double.parseDouble(str)` to save all the troubles.

```java
public static List<Token> tokenize(String str) {
    List<Token> rtn = new ArrayList<>();
    Scanner input = new Scanner(str);
    input.useDelimiter("[\t ]+");
    while (input.hasNext()) {
        String tmp = input.next();
        if (isNumeric(tmp)) {
            rtn.add(new Num(Double.parseDouble(tmp)));
        } else {
            if (tmp.equals("+")) {
                rtn.add(Symbol.PLUS);
            } else if (tmp.equals("-")) {
                rtn.add(Symbol.MINUS);
            } else if (tmp.equals("*")) {
                rtn.add(Symbol.TIMES);
            } else if (tmp.equals("/")) {
                rtn.add(Symbol.DIVIDED_BY);
            } else if (tmp.equals("=")) {
                rtn.add(Symbol.EQUAL);
            } else if (tmp.equals("(")) {
                rtn.add(Symbol.LPAREN);
            } else if (tmp.equals(")")) {
                rtn.add(Symbol.RPAREN);
            }
            ...
        }
    }
    return rtn;
}
```

### Evaluator
Evaluator is the key of the interpreter. An evaluator for infix expression
isn't particularly straightforward to come up with. To avoid the pitfall
of rolling up my own algorithms, I implemented [this][1] algorithm to evaluate infix expressions with two stacks: one for *operators*, and one for *operands*.

The main idea is to push operators and operands into corresponding stacks in
order, and reduce the stack by repeating the process of popping 2 operands
and 1 operator and push the result back in until only one element left in
the operand stack, which is the final answer. Of course, the precedence has
to be handled carefully. In general, an operator with higher precedence
always evaluate *before* the lower one, so the stack will be reduced until
the operator on the top of the stack has a lower precedence than the one
about to be added (Note: the precedence must be strictly lower because the
expression is evaluated from left to right if operators has the same
precedence). The parenthesis also need extra work. In this case, we will use
operator stack to temporarily store *left parenthesis* and when we meet the
first *right parenthesis*, we will reduce the stack until we pop the first
left parenthesis since what in the parenthesis always have a higher
priority. A simplified version of evaluator looks like this.

```java
public static Token evalUnderEnv(List<Token> tokenList, Map<String, Double> env) {
    Stack<Token> operators = new Stack<>();
    Stack<Token> operands = new Stack<>();

    while (tokenList.size() != 0) {
        Token tmp = tokenList.remove(0);
        if (!(tmp instanceof Symbol)) {
            operands.push(tmp);
        } else if (tmp == Symbol.LPAREN) {
            operators.push(tmp);
        } else if (tmp == Symbol.RPAREN) {
            while (!operators.empty() && operators.peek() != Symbol.LPAREN) {
                process(operators, operands, env);
            }
            operators.pop(); // pop the "("
        } else { // symbols
            if (operators.empty() || operators.peek() == Symbol.LPAREN) {
                operators.push(tmp);
            } else {
                while (!operators.empty() && precedence.get(operators.peek()) >= precedence.get(tmp)) {
                    process(operators, operands, env);
                }
                operators.push(tmp);
            }
        }
    }
    while (!operators.empty() && operands.size() >= 2) {
        process(operators, operands, env);
    }
    return operands.peek();
}
```

This is only half the job of an evaluator, as a good interpreter will catch
errors and print a reasonable error message. Pinpoint the errors is not a
difficult tasks in this case and will not be discussed in detail here. There
is a complete version of this method in [this repo][2].

And here you have it, a simple interpreter for infix expressions, first
tokenize the string to a list of tokens, then evaluate the tokens to answers.
Of course, this interpreter is still far from being fully featured or
consider usable. In fact, there is a lot need to be done. The tokenizer so
far can only tokenize strings separated by white spaces, but you never
needed to enter any white space between characters on an actual scientific
calculator. Also, some readers may noticed that the name of the evaluator
method is called `evalUnderEnv`, and there is a `env` passed in as an
argument but never showed up in the method body. This is done for purpose
and is needed when we introduce variables to our language, which advanced
scientific calculators does support. Those topics will be covered in a
future post.

[1]:http://csis.pace.edu/~murthy/ProgrammingProblems/16_Evaluation_of_infix_expressions
[2]:https://github.com/lewisxy/InfixEvaluator
